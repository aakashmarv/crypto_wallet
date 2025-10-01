import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:local_auth/local_auth.dart';

import '../constants/app_keys.dart';
import '../routes/app_routes.dart';
import '../theme/app_theme.dart';

class PasswordUnlockScreen extends StatefulWidget {
  const PasswordUnlockScreen({super.key});

  @override
  State<PasswordUnlockScreen> createState() => _PasswordUnlockScreenState();
}

class _PasswordUnlockScreenState extends State<PasswordUnlockScreen>
    with SingleTickerProviderStateMixin {
  final _passwordController = TextEditingController();
  final storage = FlutterSecureStorage();
  final LocalAuthentication auth = LocalAuthentication();
  String _error = '';
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      setState(() {}); // Rebuild to enable/disable button
    });

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = '';
    });

    await Future.delayed(Duration(milliseconds: 300));

    final storedPassword = await storage.read(key: AppKeys.userPassword);
    final enteredPassword = _passwordController.text.trim();

    if (enteredPassword.isEmpty) {
      setState(() {
        _error = 'Please enter valid password';
        _isLoading = false;
      });
      _shakeAnimation();
    } else if (enteredPassword == storedPassword) {
      setState(() => _isLoading = false);
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      setState(() {
        _error = 'Incorrect password';
        _isLoading = false;
      });
      _shakeAnimation();
    }
  }

  void _shakeAnimation() {
    _animationController.reset();
    _animationController.forward();
  }

  bool get _isButtonEnabled =>
      _passwordController.text.trim().isNotEmpty && !_isLoading;

  Future<void> _authenticateWithFingerprint() async {
    try {
      bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to unlock',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (didAuthenticate) {
        Get.offAllNamed(AppRoutes.dashboard);
      }
    } catch (e) {
      setState(() {
        _error = 'Fingerprint authentication failed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: SafeArea(
            child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
              SizedBox(height: 8.h),
              // App Logo
                                FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: Center(
                                    child: Container(
                                      width: 25.w, // container width
                                      height: 25.w, // container height
                                      decoration: BoxDecoration(
                                        color: Color(0xFF4CAF50),
                                        borderRadius: BorderRadius.circular(6.w),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0xFF4CAF50).withOpacity(0.3),
                                            blurRadius: 20,
                                            offset: Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.account_balance_wallet_rounded,
                                          size: 12.w, // slightly smaller than container
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 8.h),
              // Welcome Back Text
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Text(
                    'Welcome Back',
                    style: GoogleFonts.inter(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1a1a1a),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Enter your password to continue',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              SizedBox(height: 5.h),
              // Password Field
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _error.isEmpty ? AppTheme.borderSubtle : AppTheme.errorRed, width: 1,),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.black.withOpacity(0.04),
                    //     blurRadius: 10,
                    //     offset: Offset(0, 4),
                    //   ),
                    // ],
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14.sp,
                      letterSpacing: 2,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter password',
                      hintStyle: TextStyle(
                        color: AppTheme.hintTextColor,
                        letterSpacing: 0.5,
                      ),
                      prefixIcon: Icon(
                        Icons.lock_outline_rounded,
                        color: AppTheme.textSecondary,
                        size: 6.w,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(top: 12
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.fingerprint,
                          color: AppTheme.textPrimary,
                          size: 6.w,
                        ),
                        onPressed: _authenticateWithFingerprint,
                      ),
                    ),
                    onSubmitted: (_) {
                      if (_isButtonEnabled) _unlock();
                    },
                  ),
                ),
              ),
              if (_error.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 1.h, left: 1.w),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _error,
                      style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 1.h),
              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    // Navigate to Forgot Password Screen
                    // Get.toNamed(AppRoutes.forgotPassword);
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppTheme.accentTeal,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5.h),
              // Unlock Button
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: double.infinity,
                  height: 6.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3.w),
                    boxShadow: _isButtonEnabled
                        ? [
                      BoxShadow(
                        color: AppTheme.accentTeal.withOpacity(0.3),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ]
                        : [],
                  ),
                  child: ElevatedButton(
                    onPressed: _isButtonEnabled ? _unlock : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isButtonEnabled
                          ? AppTheme.accentTeal
                          : AppTheme.borderSubtle,
                      disabledBackgroundColor: AppTheme.borderSubtle,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                      height: 3.w,
                      width: 3.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Text(
                      'Unlock',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: _isButtonEnabled
                            ? Colors.white
                            : AppTheme.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
              Spacer(),
              // Footer
              FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 2.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 4.w,
                        color: Color(0xFF9CA3AF),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Secured with encryption',
                        style: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  );
                },
            ),
        ),
    );
  }
}
