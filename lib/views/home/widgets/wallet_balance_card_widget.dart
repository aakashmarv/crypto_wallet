import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_theme.dart';

class WalletBalanceCardWidget extends StatelessWidget {
  const WalletBalanceCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.h),
      padding: EdgeInsets.all(3.w),
      // decoration: BoxDecoration(
      //   gradient: LinearGradient(
      //     begin: Alignment.topLeft,
      //     end: Alignment.bottomRight,
      //     colors: [
      //       AppTheme.accentTeal.withOpacity(0.1), // slight alpha
      //       AppTheme.successGreen.withOpacity(0.05),
      //     ],
      //   ),
      //   borderRadius: BorderRadius.circular(12),
      //   border: Border.all(color: AppTheme.borderSubtle, width: 1),
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '\$0.00',               // Amount
            style: GoogleFonts.sourceSans3(
              fontSize: 36.sp,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          // Bottom change text
          Text(
            '+\$0(+0.00%)',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary, // grey color
            ),
          ),

          SizedBox(height: 2.h),
          // Wallet Address
          Row(
            children: [
              Expanded(
                child: Text(
                  'rA99b007d6a2...D06dE1948746',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 4.w),
              IconButton(
                icon: Icon(Icons.copy, color: AppTheme.successGreen, size: 4.w),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text:  'rA99b007d6a2...D06dE1948746'));

                },
              ),
              // Icon(Icons.copy, size: 5.w, color: AppTheme.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}
