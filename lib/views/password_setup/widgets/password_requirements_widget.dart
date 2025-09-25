import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PasswordRequirementsWidget extends StatelessWidget {
  final String password;
  final bool isExpanded;
  final VoidCallback onToggle;

  const PasswordRequirementsWidget({
    Key? key,
    required this.password,
    required this.isExpanded,
    required this.onToggle,
  }) : super(key: key);

  bool get hasMinLength => password.length >= 8;
  bool get hasUppercase => password.contains(RegExp(r'[A-Z]'));
  bool get hasLowercase => password.contains(RegExp(r'[a-z]'));
  bool get hasNumber => password.contains(RegExp(r'[0-9]'));
  bool get hasSpecialChar =>
      password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderSubtle,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  Icon(
                    Icons.security,
                    color: AppTheme.accentTeal,
                    size: 20,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      'Password Requirements',
                      style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: isExpanded ? null : 0,
            child:
                isExpanded ? _buildRequirementsList() : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementsList() {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.w),
      child: Column(
        children: [
          Divider(
            color: AppTheme.borderSubtle,
            height: 1,
          ),
          SizedBox(height: 3.w),
          _buildRequirementItem('At least 8 characters', hasMinLength),
          SizedBox(height: 2.w),
          _buildRequirementItem('One uppercase letter (A-Z)', hasUppercase),
          SizedBox(height: 2.w),
          _buildRequirementItem('One lowercase letter (a-z)', hasLowercase),
          SizedBox(height: 2.w),
          _buildRequirementItem('One number (0-9)', hasNumber),
          SizedBox(height: 2.w),
          _buildRequirementItem(
              'One special character (!@#\$%^&*)', hasSpecialChar),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isValid) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: isValid ? AppTheme.successGreen : Colors.transparent,
            border: Border.all(
              color: isValid ? AppTheme.successGreen : AppTheme.borderSubtle,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: isValid
              ? Icon(
                  Icons.check,
                  color: AppTheme.textPrimary,
                  size: 12,
                )
              : null,
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Text(
            text,
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: isValid ? AppTheme.successGreen : AppTheme.textSecondary,
              fontWeight: isValid ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
