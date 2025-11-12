import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class WalletNameInputWidget extends StatefulWidget {
  final Function(String) onNameChanged;
  final String? initialValue;

  const WalletNameInputWidget({
    Key? key,
    required this.onNameChanged,
    this.initialValue,
  }) : super(key: key);

  @override
  State<WalletNameInputWidget> createState() => _WalletNameInputWidgetState();
}

class _WalletNameInputWidgetState extends State<WalletNameInputWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  static const int _maxLength = 30;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    widget.onNameChanged(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wallet Name',
            style: Theme.of(context).textTheme.titleMedium?.copyWith( //change
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            maxLength: _maxLength,
            textInputAction: TextInputAction.done,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'My Crypto Wallet',
              hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(4.w),
              counterText: '',
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Give your wallet a memorable name',
                style: Theme.of(context).textTheme.bodySmall?.copyWith( //change
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${_controller.text.length}/$_maxLength',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: _controller.text.length > _maxLength * 0.8
                      ? AppTheme.warningOrange
                      : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
