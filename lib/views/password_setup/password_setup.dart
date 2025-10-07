import 'dart:io';
import 'package:cryptovault_pro/constants/app_keys.dart';
import 'package:cryptovault_pro/servieces/sharedpreferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';
import '../../widgets/app_button.dart';
import './widgets/biometric_setup_widget.dart';
import './widgets/password_requirements_widget.dart';
import './widgets/password_strength_indicator_widget.dart';

class PasswordSetup extends StatefulWidget {
  const PasswordSetup({super.key});

  @override
  State<PasswordSetup> createState() => _PasswordSetupState();
}

class _PasswordSetupState extends State<PasswordSetup>
    with TickerProviderStateMixin {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isRequirementsExpanded = false;
  bool _isBiometricEnabled = false;
  bool _isLoading = false;

  String _passwordError = '';
  String _confirmPasswordError = '';

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
    _confirmPasswordController.addListener(_onConfirmPasswordChanged);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _onPasswordChanged() {
    setState(() {
      _passwordError = '';
      if (_confirmPasswordController.text.isNotEmpty) {
        _validateConfirmPassword();
      }
    });
  }

  void _onConfirmPasswordChanged() {
    setState(() {
      _validateConfirmPassword();
    });
  }

  void _validateConfirmPassword() {
    if (_confirmPasswordController.text.isEmpty) {
      _confirmPasswordError = '';
    } else if (_passwordController.text != _confirmPasswordController.text) {
      _confirmPasswordError = 'Passwords do not match';
    } else {
      _confirmPasswordError = '';
    }
  }

  bool get _isPasswordValid {
    final password = _passwordController.text;
    return password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[0-9]')) &&
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }

  bool get _canSetPassword {
    return _isPasswordValid &&
        _confirmPasswordController.text.isNotEmpty &&
        _confirmPasswordError.isEmpty &&
        !_isLoading;
  }

  Future<void> _handleSetPassword() async {
    if (!_canSetPassword) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Provide haptic feedback
      HapticFeedback.lightImpact();

      // 🔹 Save password securely
      final password = _passwordController.text.trim();
      if (password.isNotEmpty) {
        final storage = const FlutterSecureStorage();
        await storage.write(
          key: AppKeys.userPassword,
          value: password,
        );
      }

      // Debug logs
      // debugPrint("AppKeys.userPassword = ${AppKeys.userPassword}");
      // debugPrint("Password = ${_passwordController.text}");

      // Simulate password setup process
      await Future.delayed(const Duration(seconds: 2));

      // Navigate to mnemonic phrase display
      if (mounted) {
        Get.toNamed(AppRoutes.mnemonicPhraseDisplay);
      }
    } catch (e) {
      setState(() {
        _passwordError = 'Failed to set password. Please try again.';
      });
      debugPrint("Password save error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  Future<bool> _onWillPop() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.surfaceElevated,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Leave Password Setup?',
              style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            content: Text(
              'Your progress will be lost if you go back now.',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Stay',
                  style: TextStyle(color: AppTheme.accentTeal),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Leave',
                  style: TextStyle(color: AppTheme.errorRed),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppTheme.primaryDark,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryDark,
                AppTheme.secondaryDark.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 3.h),
                        _buildProgressIndicator(),
                        SizedBox(height: 4.h),
                        _buildTitle(),
                        SizedBox(height: 3.h),
                        PasswordRequirementsWidget(
                          password: _passwordController.text,
                          isExpanded: _isRequirementsExpanded,
                          onToggle: () {
                            setState(() {
                              _isRequirementsExpanded =
                                  !_isRequirementsExpanded;
                            });
                          },
                        ),
                        SizedBox(height: 3.h),
                        _buildPasswordField(),
                        PasswordStrengthIndicatorWidget(
                          password: _passwordController.text,
                        ),
                        SizedBox(height: 3.h),
                        _buildConfirmPasswordField(),
                        SizedBox(height: 3.h),
                        /// biometric setup
                        BiometricSetupWidget(
                          isBiometricEnabled: _isBiometricEnabled,
                          onBiometricToggle: (value) async {
                            setState(() {
                              _isBiometricEnabled = value;
                            });
                            final prefs = await SharedPreferencesService.getInstance();
                            await prefs.setBool(AppKeys.isBiometricEnable, value);
                          },
                        ),
                        SizedBox(height: 4.h),
                        _buildSetPasswordButton(),
                        SizedBox(height: 3.h),
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
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          InkWell(
            onTap: () async {
              if (await _onWillPop()) {
                Navigator.pop(context);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.secondaryDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.borderSubtle,
                  width: 1,
                ),
              ),
              child: Icon(
                Platform.isIOS ? Icons.arrow_back_ios_new_rounded : Icons.arrow_back_rounded,
                color: AppTheme.textPrimary,
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Password Setup',
                style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step 2 of 3',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.accentTeal,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.accentTeal,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create a Strong Password',
            style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Your password will be used to unlock your wallet and authorize transactions. Make it strong and memorable.',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          TextFormField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            obscureText: !_isPasswordVisible,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              _confirmPasswordFocusNode.requestFocus();
            },
            decoration: InputDecoration(
              hintText: 'Enter your password',
              hintStyle: TextStyle(color: AppTheme.hintTextColor,),
              errorText: _passwordError.isNotEmpty ? _passwordError : null,
              // suffixIcon: IconButton(
              //   onPressed: () {
              //     setState(() {
              //       _isPasswordVisible = !_isPasswordVisible;
              //     });
              //   },
              //   icon: Icon(
              //    _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              //     color: AppTheme.textSecondary,
              //     size: 20,
              //   ),
              // ),
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: Icon(
                  Icons.lock_outline,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
              ),
            ),
            style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Confirm Password',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          TextFormField(
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocusNode,
            obscureText: !_isConfirmPasswordVisible,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) {
              if (_canSetPassword) {
                _handleSetPassword();
              }
            },
            decoration: InputDecoration(
              hintText: 'Confirm your password',
              hintStyle: TextStyle(color: AppTheme.hintTextColor,),
              errorText: _confirmPasswordError.isNotEmpty
                  ? _confirmPasswordError
                  : null,
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_confirmPasswordController.text.isNotEmpty &&
                      _confirmPasswordError.isEmpty)
                    Padding(
                      padding: EdgeInsets.only(right: 2.w),
                      child: Icon(
                        Icons.check_circle,
                        color: AppTheme.successGreen,
                        size: 20,
                      ),
                    ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                  ),
                ],
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: Icon(
                 Icons.lock_outline,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
              ),
            ),
            style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetPasswordButton() {
    return AppButton(
      label: "Set Password",
      enabled: _canSetPassword,
      isLoading: _isLoading,
      onPressed: _handleSetPassword,
    );
  }
}
