import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BrowserNavigationControls extends StatelessWidget {
  final bool canGoBack;
  final bool canGoForward;
  final VoidCallback onBack;
  final VoidCallback onForward;
  final VoidCallback onHome;
  final VoidCallback onBookmark;
  final bool isBookmarked;
  final bool isSecure;

  const BrowserNavigationControls({
    Key? key,
    required this.canGoBack,
    required this.canGoForward,
    required this.onBack,
    required this.onForward,
    required this.onHome,
    required this.onBookmark,
    this.isBookmarked = false,
    this.isSecure = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Back Button
          _buildNavigationButton(
            context,
            iconData: LucideIcons.chevronLeft,
            onTap: canGoBack ? onBack : null,
            isEnabled: canGoBack,
          ),
          // Forward Button
          _buildNavigationButton(
            context,
            iconData: LucideIcons.chevronRight,
            onTap: canGoForward ? onForward : null,
            isEnabled: canGoForward,
          ),
          // Home Button
          _buildNavigationButton(
            context,
            iconData: LucideIcons.house,
            onTap: onHome,
            isEnabled: true,
          ),
          // Bookmark Button
          _buildNavigationButton(
            context,
            iconData: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            onTap: onBookmark,
            isEnabled: true,
            color: isBookmarked ? AppTheme.accentTeal : null,
          ),
          // Security Indicator
          // Container(
          //   padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          //   decoration: BoxDecoration(
          //     color: isSecure
          //         ? AppTheme.successGreen.withValues(alpha: 0.1)
          //         : AppTheme.warningOrange.withValues(alpha: 0.1),
          //     borderRadius: BorderRadius.circular(8),
          //     border: Border.all(
          //       color:
          //           isSecure ? AppTheme.successGreen : AppTheme.warningOrange,
          //       width: 1,
          //     ),
          //   ),
          //   child: Row(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       Icon(
          //        isSecure ? Icons.lock : Icons.lock_open,
          //         size: 4.w,
          //         color:
          //             isSecure ? AppTheme.successGreen : AppTheme.warningOrange,
          //       ),
          //       SizedBox(width: 1.w),
          //       Text(
          //         isSecure ? 'Secure' : 'Unsecure',
          //         style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
          //           fontSize: 10.sp,
          //           color: isSecure
          //               ? AppTheme.successGreen
          //               : AppTheme.warningOrange,
          //           fontWeight: FontWeight.w500,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton(
      BuildContext context,
      {
    required IconData iconData,
    required VoidCallback? onTap,
    required bool isEnabled,
    Color? color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 12.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: isEnabled
              ? (isDark
              ? Theme.of(context).colorScheme.surfaceContainerHighest
              : AppTheme.secondaryLight)
              : (isDark
              ? Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5)
              : AppTheme.secondaryLight.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(8),
          // border: Border.all(
          //   color: AppTheme.borderSubtle,
          //   width: 1,
          // ),
        ),
        child: Icon(
          iconData,
          size: 5.w,
          color: color ??
              (isEnabled
                  ? (isDark
                  ? Colors.white // change
                  : AppTheme.textPrimary)
                  : (isDark
                  ? Colors.white.withOpacity(0.4) // change
                  : AppTheme.textSecondary.withOpacity(0.5))),
        ),
      ),
    );
  }
}
