import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_theme.dart';

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
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 8.w,
                    color: Colors.grey.shade600,
                  ),
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
            ),
          ),

          // Import Token Button
          GestureDetector(
            onTap: () => _handleImportToken(context),
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 3.w,left: 4.w,right: 4.w),
              padding: EdgeInsets.symmetric(vertical: 1.4.h, horizontal: 4.w),
              decoration: BoxDecoration(
                color: AppTheme.accentTeal,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2), // soft shadow
                    offset: const Offset(0, 3),           // x=0, y=3
                    blurRadius: 6,                        // blur for smoothness
                    spreadRadius: 1,                      // little spread
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Import token',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.surfaceElevated,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleImportToken(BuildContext context) {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text('Import token functionality coming soon!')),
    // );
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
