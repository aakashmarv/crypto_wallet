import 'package:cryptovault_pro/core/app_export.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SnackbarUtil {
  static void showSuccess(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppTheme.successGreen,
      colorText: AppTheme.surfaceElevated,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
      snackStyle: SnackStyle.FLOATING,
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOut,
      reverseAnimationCurve: Curves.easeIn,
    );
  }

  static void showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppTheme.errorRed,
      colorText: AppTheme.surfaceElevated,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
      snackStyle: SnackStyle.FLOATING,
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOut,
      reverseAnimationCurve: Curves.easeIn,
    );
  }


}
