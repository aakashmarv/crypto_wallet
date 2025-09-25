import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const ProgressIndicatorWidget({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step $currentStep of $totalSteps',
                style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${((currentStep / totalSteps) * 100).round()}%',
                style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.accentTeal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: List.generate(totalSteps, (index) {
              final stepNumber = index + 1;
              final isCompleted = stepNumber < currentStep;
              final isCurrent = stepNumber == currentStep;
              final isUpcoming = stepNumber > currentStep;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: isCompleted || isCurrent
                              ? AppTheme.accentTeal
                              : AppTheme.borderSubtle,
                        ),
                        child: isCurrent
                            ? Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.accentTeal,
                                      AppTheme.successGreen,
                                    ],
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                    if (index < totalSteps - 1) SizedBox(width: 1.w),
                  ],
                ),
              );
            }),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepLabel('Create', 1),
              _buildStepLabel('Secure', 2),
              _buildStepLabel('Verify', 3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepLabel(String label, int stepNumber) {
    final isCompleted = stepNumber < currentStep;
    final isCurrent = stepNumber == currentStep;
    final isUpcoming = stepNumber > currentStep;

    Color textColor;
    if (isCompleted) {
      textColor = AppTheme.successGreen;
    } else if (isCurrent) {
      textColor = AppTheme.accentTeal;
    } else {
      textColor = AppTheme.textSecondary;
    }

    return Column(
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted || isCurrent
                ? (isCompleted ? AppTheme.successGreen : AppTheme.accentTeal)
                : AppTheme.borderSubtle,
            border: Border.all(
              color: isCompleted || isCurrent
                  ? (isCompleted ? AppTheme.successGreen : AppTheme.accentTeal)
                  : AppTheme.borderSubtle,
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted
                ? CustomIconWidget(
                    iconName: 'check',
                    color: AppTheme.primaryDark,
                    size: 16,
                  )
                : Text(
                    stepNumber.toString(),
                    style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                      color: isCompleted || isCurrent
                          ? AppTheme.primaryDark
                          : AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          label,
          style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
            color: textColor,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
