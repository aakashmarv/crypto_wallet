import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OnboardingPageWidget extends StatelessWidget {
  final String title;
  final String description;
  final List<String> features;
  final String iconName;
  final Color iconColor;
  // final LinearGradient backgroundGradient;

  const OnboardingPageWidget({
    Key? key,
    required this.title,
    required this.description,
    required this.features,
    required this.iconName,
    required this.iconColor,
    // required this.backgroundGradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconMap = {
      'security': Icons.security,
      'web': Icons.web,
      'account_balance_wallet': Icons.account_balance_wallet,
      'check_circle': Icons.check_circle,
    };
    return Container(
      width: double.infinity,
      height: double.infinity,
      // decoration: BoxDecoration(
      //   gradient: backgroundGradient,
      // ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Section
              Container(
                width: 25.w,
                height: 25.w,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20.w),
                  border: Border.all(
                    color: iconColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    iconMap[iconName] ?? Icons.help_outline, // fallback
                    color: iconColor,
                    size: 12.w,
                  ),
                ),
              ),

              SizedBox(height: 6.h),

              // Title
              Text(
                title,
                style: AppTheme.darkTheme.textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 3.h),

              // Description
              Text(
                description,
                style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 8.h),

              // Features List
              Column(
                children: features
                    .map((feature) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 1.h),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: AppTheme.successGreen,
                                size: 5.w,
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: AppTheme.darkTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
