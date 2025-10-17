import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_theme.dart';

class WalletBalanceCardWidget extends StatelessWidget {
  final String? balance;
  const WalletBalanceCardWidget({super.key, this.balance});

  String _formatBalance(String? value) {
    if (value == null || value.isEmpty) return "---";
    try {
      final num parsed = num.parse(value);
      if (parsed == 0) return "0.00";
      return parsed.toStringAsFixed(2);
    } catch (_) {
      return "---";
    }
  }


  @override
  Widget build(BuildContext context) {
    final isLoading = balance == null;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w,vertical: 1.5.h),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Text(
        isLoading ? "---" : _formatBalance(balance),
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
