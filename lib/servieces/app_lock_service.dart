import 'package:cryptovault_pro/servieces/sharedpreferences_service.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../constants/app_keys.dart';
import '../routes/app_routes.dart';

class AppLockService extends GetxService with WidgetsBindingObserver {
  bool _shouldLock = false;

  Future<AppLockService> init() async {
    WidgetsBinding.instance.addObserver(this);
    return this;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final prefs = await SharedPreferencesService.getInstance();
    if (state == AppLifecycleState.paused) {
      _shouldLock = true; // App background me gaya
      await prefs.setBool(AppKeys.lockPending, true);
    }

    if (state == AppLifecycleState.resumed && _shouldLock) {
      _shouldLock = false; // App wapas aaya
      final isBiometricEnabled = await prefs.getBool(AppKeys.isBiometricEnable) ?? false;

      // Already lock screen par ho to ignore
      if (Get.currentRoute == AppRoutes.appLock || Get.currentRoute == AppRoutes.passwordUnlockScreen) return;

      if (isBiometricEnabled == true) {
        Get.toNamed(AppRoutes.appLock);
      } else {
        Get.toNamed(AppRoutes.passwordUnlockScreen);
      }
    }
  }
}

