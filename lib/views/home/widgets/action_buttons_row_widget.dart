import 'dart:io';
import 'package:cryptovault_pro/core/app_export.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web3dart/credentials.dart';
import '../../../constants/app_keys.dart';
import '../../../servieces/multi_wallet_service.dart';
import '../../../servieces/secure_mnemonic_service.dart';
import '../../../servieces/send_service.dart';
import '../../../widgets/app_button.dart';

class ActionButtonsRowWidget extends StatelessWidget {
  final String? walletAddress;

  const ActionButtonsRowWidget({super.key, required this.walletAddress});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: [
          // Deposit Button
          Expanded(
            child: Padding(
              padding:  EdgeInsets.only(left: 3.w,right:3.w,top: 1.h),
              child: _ActionButton(
                label: 'Deposit',
                icon: Icons.download_rounded,
                onTap: () {
                  if (walletAddress != null) {
                    _handleDeposit(context, walletAddress!);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Wallet address not loaded",
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.black,
                      ),
                    );
                  }
                },
              ),
            ),
          ),

          SizedBox(width: 3.w),

          // Send Button
          Expanded(
            child: Padding(
              padding:EdgeInsets.only(left: 3.w,right:3.w,top: 1.h),
              child: _ActionButton(
                label: 'Send',
                icon: Icons.send_rounded,
                onTap: () => _handleSend(context),
              ),
            ),
          ),

          SizedBox(width: 3.w),

          // Swap Button
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 3.w,right:3.w,top: 1.h),
              child: _ActionButton(
                label: 'Transaction',
                icon: Icons.swap_horiz_rounded,
                onTap: () => _handleTransaction(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDeposit(BuildContext context, String address) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DepositBottomSheet(walletAddress: address),
    );
  }

  void _handleSend(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _SendBottomSheet(),
    );
  }

  void _handleTransaction(BuildContext context) {
    Get.toNamed(AppRoutes.transationHistory);
  }
}

class _DepositBottomSheet extends StatelessWidget {
  final String walletAddress;

  const _DepositBottomSheet({required this.walletAddress});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.35,
      maxChildSize: 0.75,
      builder: (_, controller) => Container(
        padding: EdgeInsets.fromLTRB(
          5.w,
          3.h,
          5.w,
          bottomPadding > 0 ? bottomPadding : 2.h,
        ),
        decoration: BoxDecoration(
          color: AppTheme.secondaryDark,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Handle bar
            Container(
              width: 10.w,
              height: 0.7.h,
              decoration: BoxDecoration(
                color: AppTheme.borderSubtle,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 2.h),

            Text(
              "Deposit Address",
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 2.h),

            // ✅ QR Code from actual address
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
              ),
              child: QrImageView(
                data: walletAddress,
                version: QrVersions.auto,
                size: 40.w,
                backgroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 2.h),

            // ✅ Wallet Address + Copy
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    walletAddress,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.copy, color: AppTheme.successGreen, size: 6.w),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: walletAddress));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SendBottomSheet extends StatefulWidget {
  const _SendBottomSheet();

  @override
  State<_SendBottomSheet> createState() => _SendBottomSheetState();
}

class _SendBottomSheetState extends State<_SendBottomSheet>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  String _selectedCoin = "Ruby";
  final Map<String, double> _balances = {
    "Ruby": 1250.50,
    "Ruby Testnet": 300.75,
    "Ruby Dev": 120.25,
  };

  bool _showCoins = false;
  bool _isSending = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _handleSendButton() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final recipient = _recipientController.text.trim();
    final amount = _amountController.text.trim();

    // 🪵 Print debug info for transparency
    debugPrint("🔹 Send button pressed");
    debugPrint("Recipient entered: $recipient");
    debugPrint("Amount entered: $amount $_selectedCoin");
    // Step 1️⃣ - Show GetX loading feedback
    Get.snackbar(
      "Processing Transaction",
      "⏳ Please wait while we send your transaction...",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blueGrey.shade800,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );

    try {
      // Step 2️⃣ - Read stored password securely
      const storage = FlutterSecureStorage();
      final storedPassword = await storage.read(key: AppKeys.userPassword);

      if (storedPassword == null || storedPassword.isEmpty) {
        debugPrint("⚠️ Password not found in secure storage.");
        Get.snackbar(
          "Authentication Failed",
          "⚠️ Password not found. Please re-login.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
        );
        return;
      }

      // Step 3️⃣ - Validate recipient address
      if (!_isValidEthereumAddress(recipient)) {
        debugPrint("❌ Invalid Ethereum address entered: $recipient");
        Get.snackbar(
          "Invalid Address",
          "❌ Please enter a valid Ethereum address.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
        );
        return;
      }

      // Step 4️⃣ - Initialize wallet and transaction services
      debugPrint("🔹 Initializing wallet and transaction services...");
      final secureService = SecureMnemonicService();
      final walletService = MultiWalletService(secureService);
      final txService = SendService(walletService, secureService);

      // Step 5️⃣ - Convert Ether amount safely → Wei
      final parsedAmount = double.tryParse(amount);
      if (parsedAmount == null || parsedAmount <= 0) {
        debugPrint("⚠️ Invalid amount entered: $amount");
        Get.snackbar(
          "Invalid Amount",
          "❌ Please enter a valid numeric amount.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
        );
        return;
      }

      final weiValue = BigInt.from(parsedAmount * 1e18); // ✅ proper conversion
      debugPrint("💰 Converted $amount ETH → $weiValue Wei");

      // Step 6️⃣ - Send the transaction
      debugPrint("🚀 Sending transaction → To: $recipient | Amount: $amount ETH");
      final txHash = await txService.sendTransaction(
        to: recipient,
        amount: weiValue.toString(), // ✅ send as string to match your service
        password: storedPassword,
      );

      debugPrint("✅ Transaction sent successfully. Hash: $txHash");

      // Step 7️⃣ - Success feedback with option to view transaction
      Get.snackbar(
        "Transaction Sent ✅",
        "Hash: $txHash",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        mainButton: TextButton(
          onPressed: () {
            final url = "https://etherscan.io/tx/$txHash";
            debugPrint("🌐 Opening Etherscan: $url");
            launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
          },
          child: const Text("View", style: TextStyle(color: Colors.white)),
        ),
      );

      // Step 8️⃣ - Close bottom sheet after success
      if (mounted) Get.back();
    } on SocketException catch (e) {
      debugPrint("🌐 Network error: $e");
      Get.snackbar(
        "Network Error",
        "🌐 Please check your internet connection.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    } on FormatException catch (e) {
      debugPrint("⚠️ Invalid amount format: $e");
      Get.snackbar(
        "Invalid Amount",
        "❌ Please enter a valid number for amount.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    } catch (e, stack) {
      debugPrint("❌ Transaction Error: $e\nStackTrace: $stack");
      Get.snackbar(
        "Transaction Failed",
        "❌ ${e.toString().replaceAll('Exception:', '').trim()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    }
  }

  /// ✅ Helper to validate Ethereum address
  bool _isValidEthereumAddress(String input) {
    final regex = RegExp(r'^0x[a-fA-F0-9]{40}$');
    return regex.hasMatch(input);
  }






  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.55,
        maxChildSize: 0.9,
        builder: (_, controller) => Container(
          padding: EdgeInsets.fromLTRB(
            5.w,
            3.h,
            5.w,
            bottomPadding > 0 ? bottomPadding : 2.h,
          ),
          decoration: BoxDecoration(
            color: AppTheme.secondaryDark,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ✅ Handle bar
              Container(
                width: 12.w,
                height: 0.8.h,
                margin: EdgeInsets.only(bottom: 2.h),
                decoration: BoxDecoration(
                  color: AppTheme.borderSubtle,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),

              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    controller: controller,
                    children: [
                      Text(
                        "Send Tokens",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 3.h),

                      // ✅ Recipient Address
                      TextFormField(
                        controller: _recipientController,
                        style: TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          labelText: "Recipient Address",
                          labelStyle: TextStyle(color: AppTheme.textSecondary),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.borderSubtle),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.accentTeal),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorBorder: OutlineInputBorder( // 🔴 error border
                            borderSide: BorderSide(color: Colors.red, width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedErrorBorder: OutlineInputBorder( // 🔴 error border while typing
                            borderSide: BorderSide(color: Colors.red, width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorStyle: TextStyle( // 🔴 error text styling
                            color: Colors.red,
                            fontSize: 10.sp,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.copy, color: AppTheme.textSecondary),
                            onPressed: () async {
                              final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
                              if (clipboardData != null && clipboardData.text != null && clipboardData.text!.isNotEmpty) {
                                _recipientController.text = clipboardData.text!.trim();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Clipboard is empty")),
                                );
                              }
                            },
                          ),

                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter recipient address";
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 1.5.h),
                      // ✅ Amount
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          labelText: "Amount",
                          labelStyle: TextStyle(color: AppTheme.textSecondary),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.borderSubtle),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.accentTeal),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red, width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red, width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorStyle: TextStyle(
                            color: Colors.red,
                            fontSize: 10.sp,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Enter amount";
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) return "Invalid amount";
                          if (amount > _balances[_selectedCoin]!) return "Insufficient balance";
                          return null;
                        },
                      ),
                      SizedBox(height: 1.5.h),
                      // ✅ Custom Dropdown
                      InkWell(
                        onTap: () => setState(() => _showCoins = !_showCoins),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.borderSubtle),
                            borderRadius: BorderRadius.circular(16),
                            color: AppTheme.secondaryDark.withOpacity(0.5),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(2.w),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentTeal.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.monetization_on,
                                    color: AppTheme.accentTeal, size: 22),
                              ),
                              SizedBox(width: 3.w),
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
                                turns: _showCoins ? 0.5 : 0,
                                duration: const Duration(milliseconds: 300),
                                child: Icon(Icons.keyboard_arrow_down,
                                    color: AppTheme.accentTeal, size: 24),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ✅ Coin List (expandable)
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        firstChild: const SizedBox.shrink(),
                        secondChild: Column(
                          children: _balances.keys.map((coin) {
                            return ListTile(
                              onTap: () {
                                setState(() {
                                  _selectedCoin = coin;
                                  _showCoins = false;
                                });
                              },
                              title: Text(
                                coin,
                                style: TextStyle(color: AppTheme.textPrimary),
                              ),
                              trailing: Text(
                                _balances[coin].toString(),
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 11.sp),
                              ),
                            );
                          }).toList(),
                        ),
                        crossFadeState:
                        _showCoins ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                      ),

                      SizedBox(height: 2.h),
                    ],
                  ),
                ),
              ),

              // ✅ Send Button pinned at bottom
              SafeArea(
                top: false,
                child: AppButton(
                  label: _isSending ? "" : "Send",
                  enabled: !_isSending,
                  onPressed: _isSending ? null : _handleSendButton,
                  trailingIcon: _isSending
                      ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : null,
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}


class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        decoration: BoxDecoration(
          color: AppTheme.accentTherd,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppTheme.textPrimary,
              size: 5.w,
            ),
            SizedBox(height: 1.h),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 9.5.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
