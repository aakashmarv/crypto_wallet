import 'package:cryptovault_pro/theme/app_theme.dart';
import 'package:cryptovault_pro/views/home/widgets/action_buttons_row_widget.dart';
import 'package:cryptovault_pro/views/home/widgets/network_dropdown_widget.dart';
import 'package:cryptovault_pro/views/home/widgets/wallet_balance_card_widget.dart';
import 'package:cryptovault_pro/views/home/widgets/wallet_tabs_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedIndex = _tabController.index;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(7.h), // AppBar height adjust karo
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
                    padding:  EdgeInsets.only(left: 2.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'amandev',
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
                    ),
                  ),
                  // Dropdown
                  NetworkDropdownWidget(),
                ],
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1), // Divider height
            child: Container(
              color: AppTheme.borderSubtle, // Divider color
              height: 1,
            ),
          ),
        ),
      ),

      body: Container(
        decoration: BoxDecoration(
          // gradient: LinearGradient(
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomCenter,
          //   colors: [
          //     AppTheme.primaryDark,
          //     AppTheme.secondaryDark.withValues(alpha: 0.9),
          //   ],
          // ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ✅ Wallet Balance Card
              const WalletBalanceCardWidget(),
              // ✅ Action Buttons
              const ActionButtonsRowWidget(),
              SizedBox(height: 2.h),
              // ✅ Tabs
              Expanded(
                child: WalletTabsWidget(
                  tabController: _tabController,
                  selectedIndex: _selectedIndex,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
