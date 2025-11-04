import 'package:cryptovault_pro/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../constants/app_keys.dart';
import '../../theme/app_theme.dart';
import '../../utils/logger.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Validate current password against stored password
  Future<bool> _validateCurrentPassword(String enteredPassword) async {
    try {
      final storedPassword = await storage.read(key: AppKeys.userPassword);
      appLog('🔐 [ChangePassword] Validating current password...');

      if (storedPassword == null) {
        appLog('⚠️ [ChangePassword] No stored password found.');
        return false;
      }

      final isValid = storedPassword == enteredPassword;
      appLog(
          '🔐 [ChangePassword] Password validation: ${isValid ? "SUCCESS" : "FAILED"}');
      return isValid;
    } catch (e) {
      appLog('❌ [ChangePassword] Error validating password: $e');
      return false;
    }
  }

  // Password strength validator
  String? _validatePasswordStrength(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Validate current password
      final isCurrentPasswordValid = await _validateCurrentPassword(
          _currentPasswordController.text.trim());

      if (!isCurrentPasswordValid) {
        setState(() => _isLoading = false);
        HapticFeedback.heavyImpact();
        Get.snackbar(
          'Invalid Password',
          'Current password is incorrect',
          backgroundColor: Colors.redAccent.withOpacity(0.1),
          colorText: Colors.redAccent,
          snackPosition: SnackPosition.TOP,
          icon: Icon(Icons.error_outline, color: Colors.redAccent),
          margin: EdgeInsets.all(4.w),
        );
        return;
      }

      // Save new password
      final newPassword = _newPasswordController.text.trim();
      appLog('🔑 [ChangePassword] Updating password...');

      await storage.write(key: AppKeys.userPassword, value: newPassword);
      appLog('💾 [SecureStorage] Password updated successfully.');

      setState(() => _isLoading = false);
      HapticFeedback.heavyImpact();

      // Show success message
      Fluttertoast.showToast(msg: "Password changed");

      // Navigate back after short delay
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.pop(context);
    } catch (e, stack) {
      appLog('❌ [ChangePassword] Error: $e');
      appLog(stack);
      setState(() => _isLoading = false);

      Get.snackbar(
        'Error',
        'Failed to change password. Please try again.',
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.redAccent,
        snackPosition: SnackPosition.BOTTOM,
        icon: Icon(Icons.error_outline, color: Colors.redAccent),
        margin: EdgeInsets.all(4.w),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDark,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Change Password",
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info text
                  Text(
                    'Create a strong password to keep your wallet secure',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4.h),

                  // Current Password Field
                  _buildPasswordField(
                    controller: _currentPasswordController,
                    label: 'Current Password',
                    obscureText: _obscureCurrentPassword,
                    onToggleVisibility: () {
                      setState(() =>
                          _obscureCurrentPassword = !_obscureCurrentPassword);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Current password is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 3.h),

                  // New Password Field
                  _buildPasswordField(
                    controller: _newPasswordController,
                    label: 'New Password',
                    obscureText: _obscureNewPassword,
                    onToggleVisibility: () {
                      setState(
                          () => _obscureNewPassword = !_obscureNewPassword);
                    },
                    showVisibilityToggle: false,
                    validator: _validatePasswordStrength,
                  ),
                  SizedBox(height: 3.h),

                  // Confirm Password Field
                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    label: 'Confirm New Password',
                    obscureText: _obscureConfirmPassword,
                    onToggleVisibility: () {
                      setState(() =>
                          _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 3.h),

                  // Password Requirements
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryDark.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Password Requirements:',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        _buildRequirement('At least 8 characters'),
                        _buildRequirement('One uppercase letter'),
                        _buildRequirement('One lowercase letter'),
                        _buildRequirement('One number'),
                      ],
                    ),
                  ),
                  SizedBox(height: 5.h),
                  // button
                  AppButton(
                    label: "Save New Password",
                    onPressed: _isLoading ? null : _handleChangePassword,
                    isLoading: _isLoading,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
    bool showVisibilityToggle = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: AppTheme.textPrimary,
          ),
          decoration: InputDecoration(
            filled: true,
            // fillColor: AppTheme.secondaryDark.withOpacity(0.3),
            hintText: '••••••••',
            hintStyle:
                TextStyle(color: AppTheme.textSecondary.withOpacity(0.5)),
            suffixIcon: showVisibilityToggle
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: AppTheme.textSecondary,
                      size: 5.w,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onToggleVisibility();
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.borderSubtle.withOpacity(0.3),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.accentTeal,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.redAccent,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.redAccent,
                width: 1.5,
              ),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.5.h),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 4.w,
            color: AppTheme.textSecondary.withOpacity(0.6),
          ),
          SizedBox(width: 2.w),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 9.sp,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
