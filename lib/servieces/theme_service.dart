import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_keys.dart';
import '../servieces/sharedpreferences_service.dart';

class ThemeService extends GetxService {
  final Rx<ThemeMode> themeMode = ThemeMode.light.obs;

  Future<ThemeService> init() async {
    final prefs = await SharedPreferencesService.getInstance();
    final isDark = prefs.getBool(AppKeys.isDarkMode) ?? false;
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
    return this;
  }

  Future<void> toggleTheme(bool isDark) async {
    final prefs = await SharedPreferencesService.getInstance();
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
    await prefs.setBool(AppKeys.isDarkMode, isDark);
  }
}
