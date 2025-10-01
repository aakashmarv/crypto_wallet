import 'package:cryptovault_pro/constants/app_keys.dart';
import 'package:cryptovault_pro/servieces/sharedpreferences_service.dart';
import 'package:cryptovault_pro/views/password_unlock_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../routes/app_routes.dart';
import 'package:local_auth/local_auth.dart';

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
          _goToHome();
          return;
        }
      } catch (e) {
        debugPrint("Biometric auth error: $e");
        // fallback to password
      }
    }

    // fallback: show password screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => PasswordUnlockScreen()),
    );
  }

  void _goToHome() {
    Get.offAllNamed(AppRoutes.dashboard); // or your main app route
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