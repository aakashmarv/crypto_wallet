import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppStateController extends GetxController {
  // Reactive ThemeMode
  Rx<ThemeMode> themeMode = ThemeMode.light.obs;

  // Toggle between light and dark
  void toggleTheme() {
    if (themeMode.value == ThemeMode.light) {
      themeMode.value = ThemeMode.dark;
      Get.changeThemeMode(ThemeMode.dark);
    } else {
      themeMode.value = ThemeMode.light;
      Get.changeThemeMode(ThemeMode.light);
    }
  }
}
