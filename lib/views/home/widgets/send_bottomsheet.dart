import 'dart:io';
import 'package:cryptovault_pro/core/app_export.dart';
import 'package:cryptovault_pro/servieces/sharedpreferences_service.dart';
import 'package:cryptovault_pro/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web3dart/web3dart.dart';
import '../../../constants/api_constants.dart';
import '../../../constants/app_keys.dart';
import '../../../models/address_entry.dart';
import '../../../servieces/multi_wallet_service.dart';
import '../../../servieces/secure_mnemonic_service.dart';
import '../../../servieces/send_service.dart';
import '../../../utils/helper_util.dart';
import '../../../viewmodels/address_book_controller.dart';
import '../../../widgets/app_button.dart';
import 'package:http/http.dart';
import '../../address_book/widget/address_book_picker.dart';
import '../controller/home_controller.dart';

class SendBottomSheet extends StatefulWidget {
  const SendBottomSheet({super.key});

  @override
  State<SendBottomSheet> createState() => _SendBottomSheetState();
}

class _SendBottomSheetState extends State<SendBottomSheet>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();

  final RxBool _isSending = false.obs;
  final RxBool _showCoins = false.obs;
  String _selectedCoin = "Ruby";

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _animController.dispose();
    super.dispose();
  }

  bool _isValidEthereumAddress(String input) =>
      RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(input);

  Future<void> _handleSendButton() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final recipient = _recipientController.text.trim();
    final amountStr = _amountController.text.trim();
    _isSending.value = true;

    try {
      appLog("🔹 Send button pressed — Recipient: $recipient | Amount: $amountStr $_selectedCoin");

      const storage = FlutterSecureStorage();
      final storedPassword = await storage.read(key: AppKeys.userPassword);
      if (storedPassword == null || storedPassword.isEmpty) {
        appLog("⚠️ Password not found in secure storage.");
        return;
      }

      if (!_isValidEthereumAddress(recipient)) {
        appLog("❌ Invalid Ethereum address entered.");
        return;
      }

      final secureService = SecureMnemonicService();
      final walletService = MultiWalletService(secureService);
      final txService = SendService(walletService, secureService);

      final prefs = await SharedPreferencesService.getInstance();
      final senderWalletAddress = prefs.getString(AppKeys.walletAddress) ?? "";
      if (senderWalletAddress.isEmpty) {
        appLog("❌ No wallet address found in SharedPreferences.");
        return;
      }

      final ethAddress = HelperUtil.toEthereumAddress(senderWalletAddress);
      final senderAddress = EthereumAddress.fromHex(ethAddress);

      final client = Web3Client(ApiConstants.rpcUrl, Client());
      final balanceWei = await client.getBalance(senderAddress);
      final balanceEth = balanceWei.getValueInUnit(EtherUnit.ether);

      final parsedAmount = double.tryParse(amountStr);
      if (parsedAmount == null || parsedAmount <= 0) {
        Get.snackbar("Invalid Amount", "❌ Please enter a valid numeric amount.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade700,
            colorText: Colors.white);
        return;
      }

      final weiValue = BigInt.parse((parsedAmount * 1e18).toStringAsFixed(0));
      final totalNeeded =
          weiValue + BigInt.from(21000) * BigInt.from(10e9.toInt());

      if (balanceWei.getInWei < totalNeeded) {
        Get.snackbar(
          "Insufficient Balance",
          "💸 Not enough funds. Available: ${balanceEth.toStringAsFixed(6)} ETH",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
        );
        return;
      }

      final txHash = await txService.sendTransaction(
        to: recipient,
        amount: weiValue.toString(),
        password: storedPassword,
      );

      Get.snackbar(
        "Transaction Sent ✅",
        "Hash: $txHash",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        mainButton: TextButton(
          onPressed: () {
            final url = "https://rubyscan.io/tx/$txHash";
            launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
          },
          child: const Text("View", style: TextStyle(color: Colors.white)),
        ),
      );

      _recipientController.clear();
      _amountController.clear();

      final homeController = Get.find<HomeController>();
      await homeController.loadBalance();

      if (mounted) {
        Future.delayed(const Duration(milliseconds: 200), () {
          Navigator.of(context).pop();
        });
      }
    } on SocketException {
      Get.snackbar("Network Error", "🌐 Please check your connection.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white);
    } catch (e, stack) {
      appLog("❌ Transaction Error: $e\n$stack");
      Get.snackbar("Transaction Failed", "❌ ${e.toString()}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white);
    } finally {
      _isSending.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.55,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppTheme.secondaryDark,
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            bottom: false, // ⛔ prevent double bottom padding
            child: Column(
              children: [
                // 🔹 Handle bar
                Container(
                  width: 12.w,
                  height: 0.8.h,
                  margin: EdgeInsets.only(top: 1.5.h, bottom: 2.h),
                  decoration: BoxDecoration(
                    color: AppTheme.borderSubtle,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),

                // 🔹 Scrollable form content
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Send Ruby",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 3.h),

                          // 🧾 Recipient field
                          TextFormField(
                            controller: _recipientController,
                            style: TextStyle(color: AppTheme.textPrimary),
                            decoration: _inputDecoration(
                              label: "Recipient Address",
                              suffix: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // 📋 Paste from clipboard
                                  IconButton(
                                    icon: Icon(Icons.paste, color: AppTheme.textSecondary),
                                    tooltip: "Paste from clipboard",
                                    onPressed: () async {
                                      final data = await Clipboard.getData(Clipboard.kTextPlain);
                                      if (data?.text?.isNotEmpty ?? false) {
                                        _recipientController.text = data!.text!.trim();
                                      } else {
                                      }
                                    },
                                  ),
                                  // 📖 Open Address Book
                                  IconButton(
                                    icon: Icon(Icons.contacts_rounded, color: AppTheme.accentTeal),
                                    tooltip: "Select from Address Book",
                                    onPressed: _openAddressBookPicker,
                                  ),
                                ],
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return "Enter recipient address";
                              if (!_isValidEthereumAddress(v)) return "Invalid Ethereum address";
                              return null;
                            },
                          ),

                          SizedBox(height: 1.5.h),

                          // Amount
                          TextFormField(
                            controller: _amountController,
                            keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                            style: TextStyle(color: AppTheme.textPrimary),
                            decoration: _inputDecoration(label: "Amount"),
                            validator: (v) {
                              if (v == null || v.isEmpty) return "Enter amount";
                              final amount = double.tryParse(v);
                              if (amount == null || amount <= 0) {
                                return "Invalid amount";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 4.h),

                          // Coin dropdown
                          InkWell(
                            onTap: () =>
                                setState(() => _showCoins.value = !_showCoins.value),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 3.w, vertical: 3.w),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppTheme.borderSubtle),
                                borderRadius: BorderRadius.circular(14),
                                color: AppTheme.secondaryDark.withOpacity(0.5),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _selectedCoin,
                                      style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                  AnimatedRotation(
                                    turns: _showCoins.value ? 0.5 : 0,
                                    duration:
                                    const Duration(milliseconds: 300),
                                    child: Icon(Icons.keyboard_arrow_down,
                                        color: AppTheme.accentTeal, size: 24),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h), // 👇 gives space above button
                        ],
                      ),
                    ),
                  ),
                ),

                // 🔹 Send button always pinned bottom
                SafeArea(
                  top: false,
                  child: Obx(
                        () => IgnorePointer(
                      ignoring: _isSending.value,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AppButton(
                          label: _isSending.value ? "" : "Send",
                          enabled: !_isSending.value,
                          onPressed:
                          _isSending.value ? null : _handleSendButton,
                          trailingIcon: _isSending.value
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  /// 📘 Opens Address Book Picker (reusable)
  Future<void> _openAddressBookPicker() async {
    try {
      final selected = await showModalBottomSheet<AddressEntry>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => AddressBookPicker(
          onSelect: (entry) {
            _recipientController.text = entry.address.trim();
          },
        ),
      );

      if (selected != null) {
        _recipientController.text = selected.address.trim();
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to open Address Book: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    }
  }



  InputDecoration _inputDecoration({required String label, Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppTheme.textSecondary),
      suffixIcon: suffix,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppTheme.borderSubtle),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppTheme.accentTeal),
        borderRadius: BorderRadius.circular(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      errorStyle: TextStyle(color: Colors.red, fontSize: 10.sp),
    );
  }
}
