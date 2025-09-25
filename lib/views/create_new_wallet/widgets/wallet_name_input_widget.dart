import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class WalletNameInputWidget extends StatefulWidget {
  final Function(String) onNameChanged;
  final Function(bool) onValidationChanged;

  const WalletNameInputWidget({
    Key? key,
    required this.onNameChanged,
    required this.onValidationChanged,
  }) : super(key: key);

  @override
  State<WalletNameInputWidget> createState() => _WalletNameInputWidgetState();
}

class _WalletNameInputWidgetState extends State<WalletNameInputWidget> {
  final TextEditingController _nameController = TextEditingController();
  String? _errorText;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateInput);
  }

  void _validateInput() {
    final name = _nameController.text.trim();
    String? error;
    bool isValid = false;

    if (name.isEmpty) {
      error = null;
      isValid = false;
    } else if (name.length < 3) {
      error = 'Wallet name must be at least 3 characters';
      isValid = false;
    } else if (name.length > 20) {
      error = 'Wallet name must be less than 20 characters';
      isValid = false;
    } else if (!RegExp(r'^[a-zA-Z0-9\s_-]+$').hasMatch(name)) {
      error = 'Only letters, numbers, spaces, hyphens and underscores allowed';
      isValid = false;
    } else {
      error = null;
      isValid = true;
    }

    setState(() {
      _errorText = error;
      _isValid = isValid;
    });

    widget.onNameChanged(name);
    widget.onValidationChanged(isValid);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderSubtle,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wallet Name',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          TextFormField(
            controller: _nameController,
            style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'My Crypto Wallet',
              hintStyle: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary.withValues(alpha: 0.7),
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: Icon(
                  Icons.account_balance_wallet,
                  color:
                      _isValid ? AppTheme.accentTeal : AppTheme.textSecondary,
                  size: 20,
                ),
              ),
              suffixIcon: _nameController.text.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.all(3.w),
                      child: Icon(
                        _isValid ? Icons.check_circle : Icons.error,
                        color: _isValid
                            ? AppTheme.successGreen
                            : AppTheme.errorRed,
                        size: 20,
                      ),
                    )
                  : null,
              errorText: _errorText,
              errorStyle: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.errorRed,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.borderSubtle,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.borderSubtle,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.accentTeal,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.errorRed,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.errorRed,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: AppTheme.primaryDark,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 2.h,
              ),
            ),
          ),
          if (_isValid) ...[
            SizedBox(height: 1.h),
            Row(
              children: [
                Icon(
                  Icons.info,
                  color: AppTheme.accentTeal,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Great! Your wallet name looks good.',
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.accentTeal,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
