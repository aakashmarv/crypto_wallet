import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../theme/app_theme.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;
  final Widget? trailingIcon;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = (enabled || isLoading)
        ? AppTheme.accentTeal
        : AppTheme.borderSubtle;
    final textColor = enabled ? AppTheme.primaryDark : AppTheme.textSecondary;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 3.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: enabled
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: enabled && !isLoading ? onPressed : null,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 3.5.w),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryDark,
                  ),
                ),
              )
                  : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: AppTheme.darkTheme.textTheme.titleMedium
                        ?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    SizedBox(width: 2.w),
                    trailingIcon!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
