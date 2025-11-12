import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:cryptovault_pro/core/app_export.dart';
import '../../../utils/helper_util.dart';

class DepositBottomSheet extends StatelessWidget {
  final String walletAddress;

  const DepositBottomSheet({super.key, required this.walletAddress});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false, // allow sheet to start under status bar
      child: DraggableScrollableSheet(
        initialChildSize: 0.45,
        minChildSize: 0.35,
        maxChildSize: 0.75,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: controller,
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag Handle
                Container(
                  width: 10.w,
                  height: 0.7.h,
                  margin: EdgeInsets.only(bottom: 2.h),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                Text(
                  "Deposit Address",
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 2.h),

                // QR Box
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: QrImageView(
                    data: walletAddress,
                    version: QrVersions.auto,
                    size: 50.w,
                    backgroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: 2.h),

                // Address + Copy Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        HelperUtil.shortAddress(walletAddress),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    IconButton(
                      icon: Icon(Icons.copy,
                          color: Theme.of(context).colorScheme.primary, size: 5.w),
                      onPressed: () =>
                          HelperUtil.copyToClipboard(walletAddress),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
