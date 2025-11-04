import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../utils/logger.dart';

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
  final RxString _errorText = RxString('');
  final RxBool _isValid = false.obs;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateInput);
    _validateInput();
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

    _errorText.value = error ?? '';
    _isValid.value = isValid;

    widget.onNameChanged(name);
    widget.onValidationChanged(isValid);
  }
  @override
  void dispose() {
    // Inform parent that this child is gone and the name should be considered empty.
    // This helps when popping the screen or the widget being removed from the tree.
    try {
      widget.onValidationChanged(false);
    } catch (e) {
      // ignore: avoid_print
      appLog('onValidationChanged dispose error: $e');
    }

    _nameController.removeListener(_validateInput);
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.accentTherd.withOpacity(0.4),
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
            'Wallet',
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
              hintText: 'Please enter Wallet name',
              hintStyle: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary.withValues(alpha: 0.7),
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: _isValid.value
                      ? AppTheme.accentTeal
                      : AppTheme.textSecondary,
                  size: 20,
                ),
              ),
              suffixIcon: _nameController.text.isNotEmpty
                  ? Padding(
                padding: EdgeInsets.all(3.w),
                child: Icon(
                  _isValid.value ? Icons.check_circle : Icons.error,
                  color: _isValid.value
                      ? AppTheme.successGreen
                      : AppTheme.errorRed,
                  size: 20,
                ),
              )
                  : null,
              errorText: _errorText.value.isEmpty ? null : _errorText.value,
              errorStyle:
              AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
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
          if (_isValid.value) ...[
            SizedBox(height: 1.h),
            Row(
              children: [
                Icon(
                  Icons.info,
                  color: AppTheme.successGreen,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Great! Your wallet name looks good.',
                    style:
                    AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.successGreen,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ));
  }
}

