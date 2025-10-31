import 'package:cryptovault_pro/viewmodels/token_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../constants/api_constants.dart';
import '../../../constants/app_keys.dart';
import '../../../servieces/sharedpreferences_service.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/logger.dart';
import '../../../viewmodels/coin_controller.dart';
import '../controller/home_controller.dart';

class NetworkDropdownWidget extends StatefulWidget {
  const NetworkDropdownWidget({super.key});

  @override
  State<NetworkDropdownWidget> createState() => _NetworkDropdownWidgetState();
}

class _NetworkDropdownWidgetState extends State<NetworkDropdownWidget> {
  String _selected = "Ruby"; // default
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _loadSavedNetwork();
  }

  Future<void> _loadSavedNetwork() async {
    final prefs = await SharedPreferencesService.getInstance();
    final saved = prefs.getString(AppKeys.selectedNetwork) ?? "ruby";

    setState(() => _selected = saved == "testnet" ? "Ruby Testnet" : "Ruby");

    ApiConstants.setNetwork(saved == "testnet");
  }

  Future<void> _saveNetwork(String network) async {
    final prefs = await SharedPreferencesService.getInstance();
    await prefs.setString(AppKeys.selectedNetwork, network);

    // ✅ Apply network config
    ApiConstants.setNetwork(network == "testnet");

    // ✅ Refresh Balance
    Get.find<HomeController>().loadBalance();
    // ✅ Refresh Coin Price (IMPORTANT)
    Get.find<CoinPriceController>().fetchCoinPrice();
    Get.find<TokenListController>().getTokenList();

    Fluttertoast.showToast(msg: "Network Switched: ${network == "testnet" ? "Ruby Testnet Active" : "Ruby Mainnet Active"}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,);
    appLog("🌐 Network switched → $network");
  }


  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onOpened: () => setState(() => _isMenuOpen = true),
      onCanceled: () => setState(() => _isMenuOpen = false),
      onSelected: (val) async {
        setState(() {
          _selected = val;
          _isMenuOpen = false;
        });
        await _saveNetwork(val == "Ruby" ? "ruby" : "testnet");
      },
      offset: const Offset(0, 40),
      color: AppTheme.secondaryDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.borderSubtle, width: 1.2),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: "Ruby",
          child: Row(
            children: [
              Icon(_selected == "Ruby" ? Icons.circle : Icons.circle_outlined, size: 14, color: AppTheme.successGreen),
              SizedBox(width: 2.w),
              Text("Ruby", style: GoogleFonts.inter(color: AppTheme.textPrimary)),
            ],
          ),
        ),
        PopupMenuItem(
          value: "Ruby Testnet",
          child: Row(
            children: [
              Icon( _selected == "Ruby Testnet" ? Icons.circle : Icons.circle_outlined, size: 14, color: AppTheme.successGreen),
              SizedBox(width: 2.w),
              Text("Ruby Testnet", style: GoogleFonts.inter(color: AppTheme.textPrimary)),
            ],
          ),
        ),
      ],
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: AppTheme.accentTeal, width: 1.2),
        ),
        child: Row(
          children: [
            Icon(Icons.shield_rounded, size: 16, color: AppTheme.accentTeal),
            SizedBox(width: 1.w),
            Text(
              _selected,
              style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accentTeal),
            ),
            SizedBox(width: 1.w),
            AnimatedRotation(
              turns: _isMenuOpen ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(Icons.keyboard_arrow_down,
                  color: AppTheme.accentTeal, size: 5.w),
            ),
          ],
        ),
      ),
    );
  }
}

