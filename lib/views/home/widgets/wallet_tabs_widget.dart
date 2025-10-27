import 'package:cryptovault_pro/views/home/widgets/send_token_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/responses/token_list_response.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/helper_util.dart';
import '../../../viewmodels/token_list_controller.dart';
import 'import_token_sheet.dart';

class WalletTabsWidget extends StatelessWidget {
  final TabController tabController;
  final int selectedIndex;

  const WalletTabsWidget({
    super.key,
    required this.tabController,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Bar
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: BoxDecoration(
            color: AppTheme.secondaryDark.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderSubtle, width: 1),
          ),
          child: TabBar(
            controller: tabController,
            indicator: BoxDecoration(
              color: AppTheme.accentTeal,
              borderRadius: BorderRadius.circular(12),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: EdgeInsets.all(0.5.w),
            dividerColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor: AppTheme.textSecondary,
            labelStyle: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'Coins'),
              Tab(text: 'NFTs'),
            ],
          ),
        ),
        SizedBox(height: 1.h),

        // Tab Content Placeholder
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              _CoinsTabContent(),
              _NFTsTabContent(),
            ],
          ),
        ),
      ],
    );
  }
}
class _CoinsTabContent extends StatelessWidget {
  final TokenListController controller = Get.put(TokenListController());

  _CoinsTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Token',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // ✅ Scrollable Content (prevents overflow)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.5,
                  ),
                  child: Column(
                    children: [
                      // Token List
                      Obx(() {
                        if (controller.isLoading.value) {
                          // 🔹 Loading shimmer placeholder
                          return ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: 4,
                            itemBuilder: (_, i) => Container(
                              margin: EdgeInsets.symmetric(vertical: 1.h),
                              height: 8.h,
                              decoration: BoxDecoration(
                                color: AppTheme.borderSubtle.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }

                        if (controller.tokenList.isEmpty) {
                          // 🔹 Empty state
                          return Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.account_balance_wallet_outlined,
                                    size: 8.w, color: Colors.grey.shade600),
                                SizedBox(height: 2.h),
                                Text(
                                  'No tokens found',
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  'Import your first token to get started',
                                  style: GoogleFonts.inter(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        // ✅ Token List
                        return ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: controller.tokenList.length,
                          itemBuilder: (context, index) {
                            final token = controller.tokenList[index];
                            return TokenItemCard(token: token);
                          },
                        );
                      }),
                      SizedBox(height: 3.h),

                      // 📥 Import Token Button
                      GestureDetector(
                        onTap: () => showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (_) => const ImportTokenSheet(),
                        ),
                        child: Container(
                          width: double.infinity,
                          margin:
                          EdgeInsets.only(bottom: 3.w, left: 4.w, right: 4.w),
                          padding: EdgeInsets.symmetric(vertical: 1.2.h),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.accentTeal.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Import Token',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _NFTsTabContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 8.w,
              color: Colors.grey.shade600,
            ),
            SizedBox(height: 2.h),
            Text(
              'No NFTs found',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Your NFT collection will appear here',
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TokenItemCard extends StatelessWidget {
  final TokenInfo token;

  const TokenItemCard({super.key, required this.token});

  String _formatBalance(String? value) {
    if (value == null || value.isEmpty) return "0.00";
    try {
      final num parsed = num.parse(value);
      if (parsed >= 1) return parsed.toStringAsFixed(2);
      if (parsed >= 0.01) return parsed.toStringAsFixed(3);
      return parsed.toStringAsFixed(4);
    } catch (_) {
      return "0.00";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Row(
        children: [
          // ✅ Token Info (Name + Address)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  token.name ?? 'Unknown Token',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  HelperUtil.shortAddress(token.contractAddress ?? ''),
                  style: GoogleFonts.inter(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // ✅ Token Balance
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatBalance(token.balance),
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                'RUBY',
                style: GoogleFonts.inter(
                  fontSize: 9.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(width: 3.w),

          // ✅ Send Button
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.accentTeal,
              padding:
              EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (_) => SendTokenSheet(
                  tokenName: token.name ?? 'Unknown Token',
                  tokenAddress: token.contractAddress ?? '',
                ),
              );
            },
            child: Text(
              'Send',
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

