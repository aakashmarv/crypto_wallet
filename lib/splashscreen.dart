import 'dart:async';
import 'package:cryptovault_pro/routes/app_routes.dart';
import 'package:cryptovault_pro/servieces/sharedpreferences_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'constants/app_keys.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
    _initialize();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferencesService.getInstance();
    final isOnboardingComplete = prefs.getBool(AppKeys.onboardingComplete) ?? false;
    final bool isLogged = prefs.getBool(AppKeys.isLogin) ?? false;
    final isBiometricEnabled = prefs.getBool(AppKeys.isBiometricEnable) ?? false;
    print("isOnboardingComplete splash :: $isOnboardingComplete ");
    print("isLogged splash :: $isLogged ");
    print("isBiometricEnable splash :: $isBiometricEnabled ");

    await Future.delayed(const Duration(seconds: 3));

    if (!isOnboardingComplete) {
      // Onboarding not completed
      Get.offAllNamed(AppRoutes.onboarding);
      return;
    }

    if (!isLogged) {
      // Onboarding done but user not logged in
      Get.offAllNamed(AppRoutes.createNewWallet);
      return;
    }

    if (isBiometricEnabled) {
      // Logged in + Biometric enabled
      Get.offAllNamed(AppRoutes.appLock);
    } else {
      // Logged in + Biometric disabled
      Get.offAllNamed(AppRoutes.dashboard);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = screenWidth * 0.35; // 45% of screen width

    return Scaffold(
      // backgroundColor: const Color(0xFF5B8EFF), // Modern blue matching your logo
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6B9FFF), // Light blue
              const Color(0xFF4B7EEF), // Medium blue
              const Color(0xFF3D6FE8), // Darker blue
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(imageSize * 0.25), // proportional border radius
                child: Image.asset(
                  'assets/images/applogo.png',
                  height: imageSize,
                  width: imageSize,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

