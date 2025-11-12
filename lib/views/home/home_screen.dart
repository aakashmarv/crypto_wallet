import 'package:cryptovault_pro/views/home/widgets/action_buttons_row_widget.dart';
import 'package:cryptovault_pro/views/home/widgets/network_dropdown_widget.dart';
import 'package:cryptovault_pro/views/home/widgets/wallet_balance_card_widget.dart';
import 'package:cryptovault_pro/views/home/widgets/wallet_tabs_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'controller/home_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeController _homeController;

  @override
  void initState() {
    super.initState();
    _homeController = Get.find<HomeController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(7.h),
        child: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                              _homeController.walletName.value,
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              'Not Connected',
                              style: GoogleFonts.inter(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w400,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
              color: Theme.of(context).colorScheme.outline,
              height: 1,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            /// balance card
            WalletBalanceCardWidget(),
            Obx(() => ActionButtonsRowWidget(
                walletAddress: _homeController.walletAddress.value)),
            SizedBox(height: 2.h),
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
