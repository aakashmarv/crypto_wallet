import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_theme.dart';
import '../../../viewmodels/token_list_controller.dart';

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
          // Token Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Token',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color:  AppTheme.textPrimary,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Empty State or Token List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                // 🔄 Shimmer or Loading Indicator
                return ListView.builder(
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
                // 📭 Empty State
                return Center(
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
                itemCount: controller.tokenList.length,
                padding: EdgeInsets.only(bottom: 3.h),
                itemBuilder: (context, index) {
                  final token = controller.tokenList[index];

                  return Container(
                    margin: EdgeInsets.only(bottom: 1.5.h),
                    padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryDark.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        // Token Icon Placeholder
                        Container(
                          width: 9.w,
                          height: 9.w,
                          decoration: BoxDecoration(
                            color: AppTheme.accentTeal.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.token,
                            color: AppTheme.accentTeal,
                            size: 18.sp,
                          ),
                        ),

                        SizedBox(width: 3.w),

                        // Token Info
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
                                token.contractAddress ?? 'No address',
                                style: GoogleFonts.inter(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w400,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Token Balance
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              token.balance ?? '0',
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

                        SizedBox(width: 2.w),

                        // Send Button
                        GestureDetector(
                          onTap: () {
                            Get.snackbar(
                              'Send ${token.name}',
                              'This will open the send screen soon.',
                              backgroundColor: AppTheme.secondaryDark,
                              colorText: Colors.white,
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 1.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accentTeal,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Send',
                              style: GoogleFonts.inter(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),

          // 📥 Import Token Button
          GestureDetector(
            onTap: () => controller.getTokenList(),
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 3.w, left: 4.w, right: 4.w),
              padding: EdgeInsets.symmetric(vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated, // light background
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
