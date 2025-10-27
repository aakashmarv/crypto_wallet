import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';
import '../../constants/app_keys.dart';
import '../../servieces/multi_wallet_service.dart';
import '../../servieces/secure_mnemonic_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/helper_util.dart';

class ViewKeysScreen extends StatefulWidget {
  const ViewKeysScreen({super.key});

  @override
  State<ViewKeysScreen> createState() => _ViewKeysScreenState();
}

class _ViewKeysScreenState extends State<ViewKeysScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _blurController;

  bool _isUnlocked = false;
  String _decryptedMnemonic = '';
  String _decryptedPrivateKey = '';

  @override
  void initState() {
    super.initState();
    _fadeController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _blurController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _blurController.dispose();
    super.dispose();
  }

  /// 🔐 Verify password & decrypt mnemonic + derive private key
  Future<bool> _verifyAndUnlock() async {
    final storage = const FlutterSecureStorage();
    final savedPassword = await storage.read(key: AppKeys.userPassword);

    if (savedPassword == null || savedPassword.isEmpty) {
      Get.snackbar("Error", "No password found. Please re-login.",
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    final input = await _showPasswordDialog();
    if (input == null) return false;

    if (input != savedPassword) {
      Get.snackbar("Invalid Password", "Password does not match.",
          backgroundColor: Colors.red.shade700,
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white);
      return false;
    }

    // ✅ Get decrypted value (could be mnemonic OR private key)
    final secureService = SecureMnemonicService();
    final decrypted = await secureService.getDecryptedMnemonic(savedPassword);

    if (decrypted == null || decrypted.isEmpty) {
      Get.snackbar("Error", "Failed to decrypt stored data.",
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    final walletService = MultiWalletService(secureService);

    // 🔍 Check if decrypted value is mnemonic or private key
    final isPrivateKey = RegExp(r'^(0x)?[0-9a-fA-F]{64}$').hasMatch(decrypted);

    String mnemonic = '';
    String privateKey = '';

    if (isPrivateKey) {
      // 🟢 Case: User imported a private key wallet (non-HD)
      privateKey = decrypted.startsWith('0x') ? decrypted : '0x$decrypted';
      mnemonic = "Not available (Single Private Key Wallet)";
    } else {
      // 🟢 Case: HD Wallet — decrypt mnemonic and derive private key
      mnemonic = decrypted;
      final derivedKey = await walletService.derivePrivateKey(mnemonic, 0);
      privateKey =
      "0x${derivedKey.privateKeyInt.toRadixString(16).padLeft(64, '0')}";
    }

    setState(() {
      _isUnlocked = true;
      _decryptedMnemonic = mnemonic;
      _decryptedPrivateKey = privateKey;
    });

    _blurController.forward(from: 0);

    Get.snackbar(
      "Unlocked ✅",
      "Sensitive data visible temporarily.",
      backgroundColor: AppTheme.accentTeal,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );

    return true;
  }



  /// 🔑 Password dialog
  Future<String?> _showPasswordDialog() async {
    final controller = TextEditingController();
    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Enter Password",
          style: GoogleFonts.inter(
              color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: controller,
          obscureText: true,
          style: TextStyle(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: "Your wallet password",
            hintStyle: TextStyle(color: AppTheme.textSecondary),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.borderSubtle),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.accentTeal),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel",
                  style: TextStyle(color: AppTheme.textSecondary))),
          ElevatedButton(
              style:
              ElevatedButton.styleFrom(backgroundColor: AppTheme.accentTeal),
              onPressed: () {
                HelperUtil.closeKeyboard(context);
                Navigator.pop(context, controller.text.trim());
              },
              child:
              const Text("Verify", style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  /// 🔹 Key Card UI (for both mnemonic & private key)
  Widget _buildKeyCard({
    required String title,
    required String subtitle,
    required String animationAsset,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 4.w),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 18.w,
              height: 9.h,
              child: Lottie.asset(animationAsset, repeat: false),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.inter(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp)),
                  SizedBox(height: 0.8.h),
                  Text(subtitle,
                      style: GoogleFonts.inter(
                          color: AppTheme.textSecondary, fontSize: 10.sp)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  /// 🧊 Premium blurred reveal animation
  Widget _buildBlurReveal({required Widget child}) {
    return AnimatedBuilder(
      animation: _blurController,
      builder: (context, _) {
        final blurValue = (1 - _blurController.value) * 20;
        return Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue),
                child: AnimatedOpacity(
                  opacity: _blurController.value,
                  duration: const Duration(milliseconds: 300),
                  child: child,
                ),
              ),
            ),
            if (_blurController.value < 1)
              Opacity(
                opacity: 1 - _blurController.value,
                child: Lottie.asset(
                  "assets/lottie/unlock.json",
                  width: 40.w,
                  repeat: false,
                ),
              ),
          ],
        );
      },
    );
  }

  /// 🔒 Unlocked content
  Widget _buildUnlockedContent() {
    return _buildBlurReveal(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Mnemonic Phrase",
                style: GoogleFonts.inter(
                    color: AppTheme.accentTeal,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp)),
            SizedBox(height: 1.h),
            SelectableText(
              _decryptedMnemonic,
              style: GoogleFonts.jetBrainsMono(
                color: AppTheme.textPrimary,
                fontSize: 11.sp,
                height: 1.4,
              ),
            ),
            SizedBox(height: 3.h),
            Text("Private Key",
                style: GoogleFonts.inter(
                    color: AppTheme.accentTeal,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp)),
            SizedBox(height: 1.h),
            SelectableText(
              _decryptedPrivateKey,
              style: GoogleFonts.jetBrainsMono(
                color: AppTheme.textPrimary,
                fontSize: 11.sp,
                height: 1.4,
              ),
            ),
            SizedBox(height: 4.h),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorRed,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  setState(() {
                    _isUnlocked = false;
                    _decryptedMnemonic = '';
                    _decryptedPrivateKey = '';
                    _blurController.reset();
                  });
                },
                icon: const Icon(Icons.lock_outline, color: Colors.white),
                label: const Text("Hide Keys",
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDark,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text("View Sensitive Keys",
            style: GoogleFonts.inter(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            )),
      ),
      body: FadeTransition(
        opacity: _fadeController,
        child: Column(
          children: [
            SizedBox(height: 2.h),
            _buildKeyCard(
              title: "View Mnemonic Phrase",
              subtitle: "See your 12/24-word recovery phrase securely.",
              animationAsset: "assets/lottie/phrase.json",
              onTap: _verifyAndUnlock,
            ),
            _buildKeyCard(
              title: "View Private Key",
              subtitle: "View your private key securely.",
              animationAsset: "assets/lottie/privatekey.json",
              onTap: _verifyAndUnlock,
            ),
            SizedBox(height: 2.h),
            Expanded(
              child: Center(
                child: _isUnlocked
                    ? _buildUnlockedContent()
                    : Lottie.asset("assets/lottie/lock.json",
                    width: 60.w, repeat: false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

