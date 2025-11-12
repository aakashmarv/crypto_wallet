import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:cryptovault_pro/core/app_export.dart';
import 'deposit_bottomsheet.dart';
import 'send_bottomsheet.dart';

class ActionButtonsRowWidget extends StatelessWidget {
  final String? walletAddress;

  const ActionButtonsRowWidget({super.key, required this.walletAddress});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: [
          // Deposit Button
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              child: _ActionButton(
                label: 'Deposit',
                icon: Icons.download_rounded,
                onTap: () {
                  if (walletAddress != null) {
                    _handleDeposit(context, walletAddress!);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Wallet address not loaded"),
                        backgroundColor: Colors.black,
                      ),
                    );
                  }
                },
              ),
            ),
          ),

          // Send Button
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              child: _ActionButton(
                label: 'Send',
                icon: Icons.send_rounded,
                onTap: () => _handleSend(context),
              ),
            ),
          ),

          // Transaction Button
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              child: _ActionButton(
                label: 'Transaction',
                icon: Icons.swap_horiz_rounded,
                onTap: () => _handleTransaction(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDeposit(BuildContext context, String address) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DepositBottomSheet(walletAddress: address),
    );
  }

  void _handleSend(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SendBottomSheet(),
    );
  }

  void _handleTransaction() {
    Get.toNamed(AppRoutes.transationHistory);
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final Color bgColor = Theme.of(context).brightness == Brightness.dark
        ? AppTheme.surfaceElevatedDark
        : AppTheme.accentTherd;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: cs.onSurface, size: 5.w),
            SizedBox(height: 1.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.5.sp,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
