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
        color: AppTheme.surfaceElevated,
        border: Border(
          top: BorderSide(
            color: AppTheme.borderSubtle,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Back Button
          _buildNavigationButton(
            iconData: LucideIcons.chevronLeft,
            onTap: canGoBack ? onBack : null,
            isEnabled: canGoBack,
          ),
          // Forward Button
          _buildNavigationButton(
            iconData: LucideIcons.chevronRight,
            onTap: canGoForward ? onForward : null,
            isEnabled: canGoForward,
          ),
          // Home Button
          _buildNavigationButton(
            iconData: LucideIcons.house,
            onTap: onHome,
            isEnabled: true,
          ),
          // Bookmark Button
          _buildNavigationButton(
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
          //         style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
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

  Widget _buildNavigationButton({
    required IconData iconData,
    required VoidCallback? onTap,
    required bool isEnabled,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 12.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: isEnabled
              ? AppTheme.secondaryDark
              : AppTheme.secondaryDark.withValues(alpha: 0.5),
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
                  ? AppTheme.textPrimary
                  : AppTheme.textSecondary.withValues(alpha: 0.5)),
        ),
      ),
    );
  }
}
