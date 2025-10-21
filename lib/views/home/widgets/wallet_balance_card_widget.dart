import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_theme.dart';

class WalletBalanceCardWidget extends StatelessWidget {
  final RxString balance;
  const WalletBalanceCardWidget({super.key, required this.balance});

  String _formatBalance(String? value) {
    if (value == null || value.isEmpty) return "---";
    try {
      final num parsed = num.parse(value);

      // dynamic formatting based on amount size
      String formatted;
      if (parsed >= 1) {
        formatted = parsed.toStringAsFixed(4); // 4 decimals for normal balances
      } else if (parsed >= 0.01) {
        formatted = parsed.toStringAsFixed(6); // 6 decimals for small balances
      } else {
        formatted = parsed.toStringAsFixed(8); // show more for very tiny balances
      }

      // remove trailing zeros like 0.340000 → 0.34
      formatted = formatted.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');

      return formatted;
    } catch (_) {
      return "---";
    }
  }




  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = balance.value.isEmpty;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        child: SizedBox(
          width: double.infinity,
          child: Text(
            "Ruby ${isLoading ? '---' : _formatBalance(balance.value)}",
            style: GoogleFonts.inter(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
      );
    });
  }
}

