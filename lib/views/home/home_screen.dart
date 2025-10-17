import 'package:cryptovault_pro/theme/app_theme.dart';
import 'package:cryptovault_pro/views/home/widgets/action_buttons_row_widget.dart';
import 'package:cryptovault_pro/views/home/widgets/network_dropdown_widget.dart';
import 'package:cryptovault_pro/views/home/widgets/wallet_balance_card_widget.dart';
import 'package:cryptovault_pro/views/home/widgets/wallet_tabs_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'controller/home_controller.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    return _buildUI(controller);
  }

  Widget _buildUI(HomeController controller) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(7.h),
        child: AppBar(
          backgroundColor: AppTheme.primaryDark,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 2.w),
                    child: Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          controller.walletName.value,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'Not Connected',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    )),
                  ),
                  NetworkDropdownWidget(),
                ],
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              color: AppTheme.borderSubtle,
              height: 1,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Obx(() => WalletBalanceCardWidget(balance: controller.walletBalance.value)),
            Obx(() => ActionButtonsRowWidget(walletAddress: controller.walletAddress.value)),
            SizedBox(height: 2.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Obx(() => Row(
                children: [
                  Expanded(
                    child: Text(
                      controller.walletAddress.value.isEmpty
                          ? 'Loading...'
                          : controller.walletAddress.value,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  IconButton(
                    icon: Icon(Icons.copy, color: AppTheme.successGreen, size: 4.w),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: controller.walletAddress.value));
                    },
                  ),
                ],
              )),
            ),
            SizedBox(height: 1.h),
            // ✅ Proper TabController using GetX-friendly pattern
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Builder(
                  builder: (context) {
                    final tabController = DefaultTabController.of(context);
                    return WalletTabsWidget(
                      tabController: tabController,
                      selectedIndex: tabController.index,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
