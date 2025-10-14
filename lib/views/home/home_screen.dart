import 'package:cryptovault_pro/theme/app_theme.dart';
import 'package:cryptovault_pro/views/home/widgets/action_buttons_row_widget.dart';
import 'package:cryptovault_pro/views/home/widgets/network_dropdown_widget.dart';
import 'package:cryptovault_pro/views/home/widgets/wallet_balance_card_widget.dart';
import 'package:cryptovault_pro/views/home/widgets/wallet_tabs_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:web3dart/web3dart.dart';
import '../../constants/app_keys.dart';
import '../../servieces/multi_wallet_service.dart';
import '../../servieces/secure_mnemonic_service.dart';
import '../../servieces/sharedpreferences_service.dart';
import 'package:http/http.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  String? _walletName;
  String? _walletAddress;
  String? _walletBalance;
  static const String rpcUrl = "https://sepolia.infura.io/v3/YOUR_INFURA_PROJECT_ID";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedIndex = _tabController.index;
        });
      }
    });
    _loadWalletName();
    _loadWalletInfo();
  }
  Future<void> _loadWalletName() async {
    final prefs = await SharedPreferencesService.getInstance();
    final name = prefs.getString(AppKeys.currentWalletName) ?? 'My Wallet';
    print("wallet name:: $name");
    setState(() {
      _walletName = name;
    });
  }
  Future<void> _loadWalletInfo() async {
    print('[DEBUG] _loadWalletInfo() called');
    try {
      final address = await getCurrentAddress();
      final balance = await getCurrentBalance();
      print('[DEBUG] Wallet Address: $address');
      print('[DEBUG] Wallet Balance: $balance');

      setState(() {
        _walletAddress = address;
        _walletBalance = balance;
      });
    } catch (e, st) {
      print('[ERROR] Failed to load wallet info: $e');
      print(st); // stacktrace
    }
  }

  // Future<void> _loadWalletInfo() async {
  //   try {
  //     final address = await getCurrentAddress();
  //     final balance = await getCurrentBalance();
  //     setState(() {
  //       _walletAddress = address;
  //       _walletBalance = balance;
  //     });
  //   } catch (e) {
  //     print("Failed to load wallet info: $e");
  //   }
  // }
  Future<String?> getCurrentAddress() async {
    final secureService = SecureMnemonicService();
    final storage = FlutterSecureStorage();
    final storedPassword = await storage.read(key: AppKeys.userPassword);
    print('[DEBUG] Stored password: $storedPassword');
    if (storedPassword == null) return null;

    final mnemonic = await secureService.getDecryptedMnemonic(storedPassword);
    print('[DEBUG] Decrypted mnemonic: $mnemonic');
    final walletService = MultiWalletService(secureService);
    final wallet = await walletService.deriveWalletFromMnemonic(mnemonic!, 0);
    print('[DEBUG] Derived wallet address: ${wallet.address}');
    return wallet.address;
  }

  Future<String> getCurrentBalance() async {
    final secureService = SecureMnemonicService();
    final storage = FlutterSecureStorage();
    final storedPassword = await storage.read(key: AppKeys.userPassword);
    if (storedPassword == null) throw Exception("No password found");

    final mnemonic = await secureService.getDecryptedMnemonic(storedPassword);
    final walletService = MultiWalletService(secureService);
    final wallet = await walletService.deriveWalletFromMnemonic(mnemonic!, 0);

    final web3client = Web3Client(rpcUrl, Client());
    final address = EthereumAddress.fromHex(wallet.address);
    print('[DEBUG] Fetching balance for: ${wallet.address}');

    final balance = await web3client.getBalance(address);
    await web3client.dispose();

    print('[DEBUG] Raw balance (wei): $balance');
    final ether = balance.getValueInUnit(EtherUnit.ether).toStringAsFixed(4);
    print('[DEBUG] Ether balance: $ether');

    return ether;
    // return balance.getValueInUnit(EtherUnit.ether).toStringAsFixed(4);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(7.h),
        child: AppBar(
          backgroundColor: AppTheme.primaryDark,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding:  EdgeInsets.only(left: 2.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _walletName ?? 'My Wallet',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'Not Connected',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Dropdown
                  NetworkDropdownWidget(),
                ],
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1), // Divider height
            child: Container(
              color: AppTheme.borderSubtle, // Divider color
              height: 1,
            ),
          ),
        ),
      ),

      body: Container(
        decoration: BoxDecoration(
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ✅ Wallet Balance Card
              WalletBalanceCardWidget(balance: _walletBalance),
              // ✅ Action Buttons
              ActionButtonsRowWidget(walletAddress: _walletAddress),
              SizedBox(height: 2.h),
              // Wallet Address
              Padding(
                padding:  EdgeInsets.symmetric(horizontal: 4.w),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _walletAddress ?? 'Loading...',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    IconButton(
                      icon: Icon(Icons.copy, color: AppTheme.successGreen, size: 4.w),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _walletAddress ?? ''));

                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 1.h),
              // ✅ Tabs
              Expanded(
                child: WalletTabsWidget(
                  tabController: _tabController,
                  selectedIndex: _selectedIndex,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
