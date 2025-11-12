import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:local_auth/local_auth.dart';
import '../constants/app_keys.dart';
import '../routes/app_routes.dart';
import '../servieces/sharedpreferences_service.dart';
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
      return;
    }

    if (enteredPassword == storedPassword) {
      final prefs = await SharedPreferencesService.getInstance();
      final lockPending = prefs.getBool(AppKeys.lockPending) ?? false;

      // Clear flag on success
      await prefs.setBool(AppKeys.lockPending, false);

      setState(() => _isLoading = false);

      if (lockPending) {
        // Stack: <prevScreen> -> AppLockScreen -> PasswordUnlockScreen
        // Return to previous screen: pop 2 times
        Get.back(); // pop PasswordUnlockScreen
        Get.back(); // pop AppLockScreen
      } else {
        // First-open
        Get.offAllNamed(AppRoutes.dashboard);
      }
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
        final prefs = await SharedPreferencesService.getInstance();
        final lockPending = prefs.getBool(AppKeys.lockPending) ?? false;

        await prefs.setBool(AppKeys.lockPending, false);

        if (lockPending) {
          Get.back(); // pop PasswordUnlockScreen
          Get.back(); // pop AppLockScreen
        } else {
          Get.offAllNamed(AppRoutes.dashboard);
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Fingerprint authentication failed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                              width: 25.w,
                              height: 25.w,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6.w),
                                child: Image.asset(
                                  'assets/images/applogo.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
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
                                color: Theme.of(context).colorScheme.onSurface,
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
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        SizedBox(height: 5.h),
                        // Password Field
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: TextField(
                            controller: _passwordController,
                            obscureText: true,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 14.sp,
                              letterSpacing: 2,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter password',
                              hintStyle: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                                letterSpacing: 0.5,
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline_rounded,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                size: 6.w,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 13),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  Icons.fingerprint,
                                  color: Theme.of(context).colorScheme.primary,
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
                        SizedBox(height: 10.h),
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
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
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
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.outline,
                                disabledBackgroundColor: Theme.of(context).colorScheme.outline,
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
                                            AlwaysStoppedAnimation<Color>(
                                              Theme.of(context).colorScheme.onPrimary,),
                                      ),
                                    )
                                  : Text(
                                      'Unlock',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: _isButtonEnabled
                                            ? Theme.of(context).colorScheme.onPrimary
                                            : Theme.of(context).colorScheme.onSurfaceVariant,
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
