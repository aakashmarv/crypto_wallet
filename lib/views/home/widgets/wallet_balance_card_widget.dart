import 'dart:math' as math;
import 'package:cryptovault_pro/utils/helper_util.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../theme/app_theme.dart';
import '../../../viewmodels/coin_controller.dart';
import '../../../widgets/watermark_painter.dart';
import '../controller/home_controller.dart';

class WalletBalanceCardWidget extends StatelessWidget {
  final HomeController homeController = Get.find<HomeController>();
  final CoinPriceController coinPriceController = Get.find<CoinPriceController>();

  WalletBalanceCardWidget({super.key});

  String _formatBalance(String? value) {
    if (value == null || value.isEmpty) return "0.0000";
    try {
      final num parsed = num.parse(value);
      String formatted;
      if (parsed >= 1) {
        formatted = parsed.toStringAsFixed(4);
      } else if (parsed >= 0.01) {
        formatted = parsed.toStringAsFixed(6);
      } else {
        formatted = parsed.toStringAsFixed(8);
      }
      formatted =
          formatted.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
      return formatted;
    } catch (_) {
      return "0.0000";
    }
  }

  String _formatUSD(double amount) {
    if (amount < 0.01) return "<\$0.01";
    return "\$${amount.toStringAsFixed(2)}";
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = homeController.isLoadingBalance.value;
      final balanceStr = homeController.walletBalance.value;
      final coinPrice = coinPriceController.coinPrice.value;

      double parsedBalance = double.tryParse(balanceStr) ?? 0.0;
      double usdValue = parsedBalance * coinPrice;

      // --- 🔹 Premium animated UI
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
          width: double.infinity,
          height: 150,
          padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 3.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                AppTheme.accentTeal,
                const Color(0xFF6375FF),
                const Color(0xFF9BA7FF),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Watermark background pattern
                Positioned.fill(
                  child: CustomPaint(
                    painter: WatermarkPainter(),
                  ),
                ),
                // Main content
                isLoading
                    ? _buildShimmerLoader()
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildAnimatedBalance(parsedBalance, usdValue),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Obx(() => Row(
                        children: [
                          Text(
                            homeController.walletAddress.value.isEmpty
                                ? 'Loading...'
                                : HelperUtil.shortAddress(
                                homeController.walletAddress.value),
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(width: 2.w),
                          IconButton(
                            icon: Icon(Icons.copy,
                                color: Colors.white.withOpacity(0.9),
                                size: 4.w),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              HelperUtil.copyToClipboard(
                                  homeController.walletAddress.value);
                            },
                          ),
                        ],
                      )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }


  // --- ✨ Shimmer-style premium loader
  Widget _buildShimmerLoader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _animatedShimmer(width: 40.w, height: 3.h),
        _animatedShimmer(width: 20.w, height: 2.h),
      ],
    );
  }

  Widget _animatedShimmer({required double width, required double height}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
      builder: (context, value, _) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.25),
                Colors.white.withOpacity(0.6),
                Colors.white.withOpacity(0.25),
              ],
              stops: [0.0, value, 1.0],
            ),
          ),
        );
      },
    );
  }

  // --- 💎 Animated number transitions for Ruby + USD
  Widget _buildAnimatedBalance(double rubyBalance, double usdValue) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(
            begin: 0,
            end: rubyBalance,
          ),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Text(
              "Ruby ${_formatBalance(value.toString())}",
              style: GoogleFonts.inter(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            );
          },
        ),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(
            begin: 0,
            end: usdValue,
          ),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Text(
              _formatUSD(value),
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.9),
              ),
            );
          },
        ),
      ],
    );
  }
}



