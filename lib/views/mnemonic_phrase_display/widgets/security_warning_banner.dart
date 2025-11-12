import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SecurityWarningBanner extends StatefulWidget {
  const SecurityWarningBanner({Key? key}) : super(key: key);

  @override
  State<SecurityWarningBanner> createState() => _SecurityWarningBannerState();
}

class _SecurityWarningBannerState extends State<SecurityWarningBanner> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.warningOrange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.warningOrange.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: AppTheme.warningOrange,
                    size: 6.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      'Critical Security Warning',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.warningOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppTheme.warningOrange,
                    size: 6.w,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            Divider(
              color: AppTheme.warningOrange.withValues(alpha: 0.3),
              height: 1,
            ),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your recovery phrase is the ONLY way to restore your wallet. If you lose it, your funds will be permanently lost.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  _buildSecurityTip('Never share your phrase with anyone'),
                  SizedBox(height: 1.h),
                  _buildSecurityTip('Store it offline in a secure location'),
                  SizedBox(height: 1.h),
                  _buildSecurityTip(
                      'Write it down on paper, don\'t save digitally'),
                  SizedBox(height: 1.h),
                  _buildSecurityTip('Verify your backup before proceeding'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSecurityTip(String tip) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 0.5.h),
          width: 1.w,
          height: 1.w,
          decoration: BoxDecoration(
            color: AppTheme.warningOrange,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Text(
            tip,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
