import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_theme.dart';

class WalletBalanceCardWidget extends StatelessWidget {
  const WalletBalanceCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w,vertical: 1.5.h),
      child: SizedBox(
        width: double.infinity,
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
              '\$75384.00',
              style: GoogleFonts.inter(
                fontSize: 32.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            // Bottom change text
            Text(
              '+\$0(+0.00%)',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary, // grey color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
