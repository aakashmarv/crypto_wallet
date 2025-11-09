import 'package:cryptovault_pro/constants/app_keys.dart';
import 'package:cryptovault_pro/servieces/sharedpreferences_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../routes/app_routes.dart';
import 'package:local_auth/local_auth.dart';

import '../utils/logger.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final storage = FlutterSecureStorage();
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticating = true;

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    final prefs = await SharedPreferencesService.getInstance();
    bool? biometricEnabled = prefs.getBool(AppKeys.isBiometricEnable) ?? false;

    if (biometricEnabled) {
      try {
        bool authenticated = await auth.authenticate(   // ✅ updated
          localizedReason: 'Please authenticate to access the app',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
            useErrorDialogs: true,
          ),
        );

        if (authenticated) {
          // _goToHome();
          await _onUnlockSuccess();
          return;
        }
      } catch (e) {
        appLog("Biometric auth error: $e");
        // fallback to password
      }
    }
    // ❗️Fallback: password screen par jana hai
    // First-open vs resume ko detect karke navigate karo:
    final lockPending = prefs.getBool(AppKeys.lockPending) ?? false;

    if (lockPending) {
      // Background-resume flow: stack preserve
      Get.toNamed(AppRoutes.passwordUnlockScreen);
    } else {
      // First-open flow: splash se aaya — stack clean
      Get.offAllNamed(AppRoutes.passwordUnlockScreen);
    }
  }


  Future<void> _onUnlockSuccess() async {
    final prefs = await SharedPreferencesService.getInstance();
    final lockPending = prefs.getBool(AppKeys.lockPending) ?? false;

    // Success pe flag clear
    await prefs.setBool(AppKeys.lockPending, false);

    if (lockPending) {
      // Background-resume: AppLockScreen ko pop kar do → pichhli screen dikhegi
      Get.back();
    } else {
      // First-open: Dashboard pe le jao
      Get.offAllNamed(AppRoutes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isAuthenticating
            ? const CircularProgressIndicator()
            : const Text('Authentication required'),
      ),
    );
  }
}