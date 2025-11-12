import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SecurityChecklist extends StatefulWidget {
  final Function(bool) onAllChecked;

  const SecurityChecklist({
    Key? key,
    required this.onAllChecked,
  }) : super(key: key);

  @override
  State<SecurityChecklist> createState() => _SecurityChecklistState();
}

class _SecurityChecklistState extends State<SecurityChecklist> {
  bool _writtenDown = false;
  bool _secureLocation = false;
  bool _neverShare = false;

  void _updateChecklistStatus() {
    final allChecked = _writtenDown && _secureLocation && _neverShare;
    widget.onAllChecked(allChecked);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.secondaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.accentTeal.withOpacity(0.1), // slight alpha
            AppTheme.successGreen.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security,
                color: AppTheme.accentTeal,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Security Checklist',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildChecklistItem(
            'I have written down all words in the correct order',
            _writtenDown,
            (value) => setState(() {
              _writtenDown = value ?? false;
              _updateChecklistStatus();
            }),
          ),
          SizedBox(height: 2.h),
          _buildChecklistItem(
            'I will store this phrase in a secure, offline location',
            _secureLocation,
            (value) => setState(() {
              _secureLocation = value ?? false;
              _updateChecklistStatus();
            }),
          ),
          SizedBox(height: 2.h),
          _buildChecklistItem(
            'I understand I should never share this with anyone',
            _neverShare,
            (value) => setState(() {
              _neverShare = value ?? false;
              _updateChecklistStatus();
            }),
          ),
          SizedBox(height: 3.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.warningOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.warningOrange.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning,
                  color: AppTheme.warningOrange,
                  size: 4.w,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Ruby wallet & Dapp browser cannot recover your wallet if you lose your recovery phrase. This is your responsibility.',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.warningOrange,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(
    String text,
    bool isChecked,
    Function(bool?) onChanged,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.scale(
          scale: 1.1,
          child: Checkbox(
            value: isChecked,
            onChanged: onChanged,
            activeColor: Theme.of(context).colorScheme.primary,
            checkColor: Theme.of(context).colorScheme.onPrimary,
            side: BorderSide(
              color: isChecked
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 1.h),
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isChecked
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
