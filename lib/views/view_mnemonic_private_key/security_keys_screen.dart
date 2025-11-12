import 'dart:async';
import 'dart:ui';
import 'package:cryptovault_pro/utils/helper_util.dart';
import 'package:cryptovault_pro/utils/logger.dart';
import 'package:cryptovault_pro/utils/secure_screen_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../constants/app_keys.dart';
import '../../servieces/multi_wallet_service.dart';
import '../../servieces/secure_mnemonic_service.dart';
import '../../servieces/sharedpreferences_service.dart';
import '../../theme/app_theme.dart';
import 'package:local_auth/local_auth.dart';

class SecurityKeysScreen extends StatefulWidget {
  const SecurityKeysScreen({super.key});

  @override
  State<SecurityKeysScreen> createState() => _SecurityKeysScreenState();
}

class _SecurityKeysScreenState extends State<SecurityKeysScreen> with SecureScreenMixin {
  bool _mnemonicUnlocked = false;
  bool _privateKeyUnlocked = false;

  String _decryptedMnemonic = '';
  String _decryptedPrivateKey = '';

  Timer? _mnemonicTimer;
  Timer? _privateKeyTimer;
  final LocalAuthentication auth = LocalAuthentication();

  void _startAutoHideTimer({
    required bool isMnemonic,
  }) {
    final timer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          if (isMnemonic) {
            _mnemonicUnlocked = false;
            _decryptedMnemonic = '';
          } else {
            _privateKeyUnlocked = false;
            _decryptedPrivateKey = '';
          }
        });
        Get.snackbar(
          "Hidden for Security",
          "Key was automatically hidden.",
          backgroundColor: AppTheme.borderSubtle,
          colorText: AppTheme.textPrimary,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    });

    if (isMnemonic) {
      _mnemonicTimer?.cancel();
      _mnemonicTimer = timer;
    } else {
      _privateKeyTimer?.cancel();
      _privateKeyTimer = timer;
    }
  }

  Future<void> _handleUnlock({required bool isMnemonic}) async {
    final prefs = await SharedPreferencesService.getInstance();
    final isBiometricEnabled =
        prefs.getBool(AppKeys.isBiometricEnable) ?? false;

    bool isAuthenticated = false;

    if (isBiometricEnabled) {
      isAuthenticated = await _authenticateWithFingerprint();
    } else {
      isAuthenticated = await _verifyPassword();
    }

    if (!isAuthenticated) return;

    if (isMnemonic) {
      _unlockMnemonic();
    } else {
      _unlockPrivateKey();
    }
  }

  Future<bool> _authenticateWithFingerprint() async {
    try {
      return await auth.authenticate(
        localizedReason: 'Authenticate to view sensitive key',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Biometric authentication failed");
      return false;
    }
  }

  Future<bool> _verifyPassword() async {
    final storage = const FlutterSecureStorage();
    final savedPassword = await storage.read(key: AppKeys.userPassword);

    final controller = TextEditingController();

    bool isLoading = false;
    bool obscureText = true;

    final input = await Get.bottomSheet<String>(
      SafeArea(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.secondaryLight,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
              6.w, 3.h, 6.w, MediaQuery.of(context).viewInsets.bottom + 2.h),
          child: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) {
                return IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppTheme.borderSubtle,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        "Enter Password",
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      TextField(
                        controller: controller,
                        obscureText: obscureText,
                        autofocus: true,
                        style: TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: "Wallet Password",
                          hintStyle: TextStyle(color: AppTheme.textSecondary),
                          filled: true,
                          fillColor: AppTheme.primaryLight,
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureText
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: AppTheme.textSecondary,
                            ),
                            onPressed: () =>
                                setState(() => obscureText = !obscureText),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppTheme.borderSubtle),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: AppTheme.accentTeal, width: 2),
                          ),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: isLoading ? null : () => Get.back(),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 11.sp),
                            ),
                          ),
                          SizedBox(width: 2.w),
                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    setState(() => isLoading = true);
                                    await Future.delayed(
                                        const Duration(milliseconds: 300));
                                    Get.back(result: controller.text.trim());
                                  },
                            child: isLoading
                                ? SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          AppTheme.accentTeal),
                                    ),
                                  )
                                : Text(
                                    "Verify Password",
                                    style: TextStyle(
                                        color: AppTheme.accentTeal,
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w600),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
      enableDrag: true,
      isDismissible: true,
    );

    if (input == null) return false;

    if (input != savedPassword) {
      Get.snackbar("Invalid Password", "Wrong password entered.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: EdgeInsets.all(4.w),
          borderRadius: 12);
      return false;
    }

    return true;
  }

  Future<void> _unlockMnemonic() async {
    if (_mnemonicUnlocked) {
      setState(() {
        _mnemonicUnlocked = false;
        _decryptedMnemonic = '';
      });
      return;
    }

    final storage = const FlutterSecureStorage();
    final password = await storage.read(key: AppKeys.userPassword);

    final secureService = SecureMnemonicService();
    final decrypted = await secureService.getDecryptedMnemonic(password!);

    if (decrypted == null || decrypted.trim().isEmpty) {
      Fluttertoast.showToast(
          msg: "This wallet does not contain a recovery phrase.");
      return;
    }

    // ✅ Check if it is actually a private key wallet
    if (_isPrivateKey(decrypted)) {
      setState(() {
        _decryptedMnemonic =
            "Mnemonic not available — This wallet was imported using a private key.";
        _mnemonicUnlocked = true;
      });
      _startAutoHideTimer(isMnemonic: true);
      return;
    }

    // ✅ It's a real mnemonic → unlock it
    setState(() {
      _decryptedMnemonic = decrypted;
      _mnemonicUnlocked = true;
    });

    _startAutoHideTimer(isMnemonic: true);
  }

  Future<void> _unlockPrivateKey() async {
    if (_privateKeyUnlocked) {
      setState(() {
        _privateKeyUnlocked = false;
        _decryptedPrivateKey = '';
      });
      return;
    }

    final storage = const FlutterSecureStorage();
    final password = await storage.read(key: AppKeys.userPassword);

    final secureService = SecureMnemonicService();
    final decrypted = await secureService.getDecryptedMnemonic(password!);

    if (decrypted == null || decrypted.trim().isEmpty) {
      Fluttertoast.showToast(
          msg: "This wallet does not contain a private key.");
      return;
    }

    String finalPrivateKey;

    // ✅ CASE 1: Wallet was imported using private key
    if (_isPrivateKey(decrypted)) {
      finalPrivateKey = decrypted.startsWith("0x") ? decrypted : "0x$decrypted";
    }
    // ✅ CASE 2: Wallet was created/imported using mnemonic
    else {
      final walletService = MultiWalletService(secureService);
      final derived = await walletService.derivePrivateKey(decrypted, 0);
      finalPrivateKey =
          "0x${derived.privateKeyInt.toRadixString(16).padLeft(64, '0')}";
      appLog("privatekey:: $finalPrivateKey");
    }

    setState(() {
      _decryptedPrivateKey = finalPrivateKey;
      _privateKeyUnlocked = true;
    });

    _startAutoHideTimer(isMnemonic: false);
  }

  Widget _buildSensitiveTile({
    required String label,
    required String value,
    required bool unlocked,
    required VoidCallback onUnlock,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label + Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface
                  )),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.6.h),
                decoration: BoxDecoration(
                  color: unlocked
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.15) // change
                      : Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  unlocked ? "Unlocked" : "Locked",
                  style: GoogleFonts.inter(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w500,
                    color: unlocked
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),

          // VALUE AREA (with correct blur)
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.outline,),
            ),
            padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
            child: Stack(
              children: [
                Stack(
                  children: [
                    // ✅ If unlocked → show real text
                    if (unlocked)
                      SelectableText(
                        value,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10.sp,
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 1.5,
                        ),
                      ),

                    // ✅ If locked → show placeholder masked text + blur
                    if (!unlocked)
                      ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                          child: Opacity(
                            opacity: 0.6,
                            child: Text(
                              "•••• •••• •••• •••• •••• ••••",
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10.sp,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                letterSpacing: 2,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                if (!unlocked)
                  ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: Colors.black.withOpacity(0.2),
                        height: null,
                        width: double.infinity,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(height: 1.h),

          // Action Row (Show/Hide + Copy)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onUnlock,
                child: Row(
                  children: [
                    Icon(
                      unlocked
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: AppTheme.accentTeal,
                      size: 16.sp,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      unlocked ? "Hide" : "Show",
                      style: TextStyle(
                          color: AppTheme.accentTeal, fontSize: 10.sp),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 4.w),
              InkWell(
                onTap: unlocked
                    ? () {
                        Clipboard.setData(ClipboardData(text: value));
                        HelperUtil.toast("copied to clipboard.");
                      }
                    : null,
                child: Row(
                  children: [
                    Icon(Icons.copy_rounded,
                        color: unlocked
                            ? AppTheme.accentTeal
                            : AppTheme.textSecondary,
                        size: 16.sp),
                    SizedBox(width: 1.w),
                    Text(
                      "Copy",
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: unlocked
                            ? AppTheme.accentTeal
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mnemonicTimer?.cancel();
    _privateKeyTimer?.cancel();
    super.dispose();
  }


  bool _isPrivateKey(String value) {
    final hexPattern = RegExp(r'^(0x)?[0-9a-fA-F]{64}$');
    return hexPattern.hasMatch(value.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).colorScheme.onSurface,),
          onPressed: () => Get.back(),
        ),
        title: Text("Security Keys",
            style: GoogleFonts.inter(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          SizedBox(height: 2.h),
          _buildSensitiveTile(
            label: "Mnemonic Phrase",
            value: _decryptedMnemonic,
            unlocked: _mnemonicUnlocked,
            onUnlock: () => _handleUnlock(isMnemonic: true),
          ),
          _buildSensitiveTile(
            label: "Private Key",
            value: _decryptedPrivateKey,
            unlocked: _privateKeyUnlocked,
            onUnlock: () => _handleUnlock(isMnemonic: false),
          ),
          SizedBox(height: 4.h),
        ]),
      ),
    );
  }
}
