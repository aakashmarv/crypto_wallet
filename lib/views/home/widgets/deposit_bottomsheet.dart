import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/services.dart';
import 'package:cryptovault_pro/core/app_export.dart';

import '../../../utils/helper_util.dart';

class DepositBottomSheet extends StatelessWidget {
  final String walletAddress;

  const DepositBottomSheet({super.key, required this.walletAddress});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.35,
      maxChildSize: 0.75,
      builder: (_, controller) => Container(
        padding: EdgeInsets.fromLTRB(
          5.w,
          3.h,
          5.w,
          bottomPadding > 0 ? bottomPadding : 2.h,
        ),
        decoration: BoxDecoration(
          color: AppTheme.secondaryDark,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 10.w,
              height: 0.7.h,
              decoration: BoxDecoration(
                color: AppTheme.borderSubtle,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 2.h),

            Text(
              "Deposit Address",
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 2.h),

            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
              ),
              child: QrImageView(
                data: walletAddress,
                version: QrVersions.auto,
                size: 50.w,
                backgroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 1.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  HelperUtil.shortAddress(walletAddress),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(width: 3.w,),
                IconButton(
                  icon: Icon(Icons.copy, color: AppTheme.successGreen, size: 5.w),
                  onPressed: () => HelperUtil.copyToClipboard(walletAddress),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
