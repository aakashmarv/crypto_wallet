import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_keys.dart';
import '../servieces/sharedpreferences_service.dart';

class ThemeService extends GetxService {
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  Future<ThemeService> init() async {
    final prefs = await SharedPreferencesService.getInstance();
    final isDark = prefs.getBool(AppKeys.isDarkMode);

    if (isDark == null) {
      themeMode.value = ThemeMode.system;
    } else if (isDark == true) {
      themeMode.value = ThemeMode.dark;
    } else {
      themeMode.value = ThemeMode.system;
    }

    return this;
  }

  Future<void> toggleTheme(bool isDark) async {
    final prefs = await SharedPreferencesService.getInstance();

    if (isDark) {
      themeMode.value = ThemeMode.dark;
      await prefs.setBool(AppKeys.isDarkMode, true);
    } else {
      themeMode.value = ThemeMode.system;
      await prefs.setBool(AppKeys.isDarkMode, false);
    }
  }
}

