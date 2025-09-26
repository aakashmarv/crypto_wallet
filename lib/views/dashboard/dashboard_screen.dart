import 'package:cryptovault_pro/views/setting/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/selectedIndex_controller.dart';
import '../d_app_browser/d_app_browser.dart';
import '../home/home_screen.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final SelectedIndexController _selectedIndexController = Get.put(SelectedIndexController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Rxn<DateTime> _lastBackPressed = Rxn<DateTime>();


  final List<Widget> _screens = const [
    HomeScreen(),
    DAppBrowser(),
    SettingsScreen(),
  ];

  Future<bool> _onWillPop() async {
    if (_selectedIndexController.selectedIndex.value != 0) {
      _selectedIndexController.changeTab(0);
      return false;
    }

    DateTime now = DateTime.now();
    if (_lastBackPressed.value == null ||
        now.difference(_lastBackPressed.value!) > const Duration(seconds: 3)) {
      _lastBackPressed.value = now;
      Fluttertoast.showToast(msg: "Press back again to exit");
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Obx(() {
        return Scaffold(
          key: _scaffoldKey,
          body: _screens[_selectedIndexController.selectedIndex.value],
            // bottomNavigationBar:  BottomNavigationBar(
            //     currentIndex: _selectedIndexController.selectedIndex.value,
            //     onTap: _selectedIndexController.changeTab,
            //     backgroundColor: AppTheme.surfaceElevated,
            //     selectedItemColor: AppTheme.accentTeal,
            //     unselectedItemColor: AppTheme.textSecondary,
            //     type: BottomNavigationBarType.fixed,
            //     items: [
            //       BottomNavigationBarItem(
            //         icon: Icon(
            //           Icons.home,
            //           size: 6.w,
            //           color: _selectedIndexController.selectedIndex.value == 0
            //               ? AppTheme.accentTeal
            //               : AppTheme.textSecondary,
            //         ),
            //         label: 'Home',
            //       ),
            //       BottomNavigationBarItem(
            //         icon: Icon(
            //           Icons.web,
            //           size: 6.w,
            //           color: _selectedIndexController.selectedIndex.value == 1
            //               ? AppTheme.accentTeal
            //               : AppTheme.textSecondary,
            //         ),
            //         label: 'Browser',
            //       ),
            //       BottomNavigationBarItem(
            //         icon: Icon(
            //           Icons.settings,
            //           size: 6.w,
            //           color: _selectedIndexController.selectedIndex.value == 2
            //               ? AppTheme.accentTeal
            //               : AppTheme.textSecondary,
            //         ),
            //         label: 'Settings',
            //       ),
            //     ],
            //   ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ Top Divider
              Container(
                height: 1,
                color: AppTheme.borderSubtle,
              ),
              BottomNavigationBar(
                currentIndex: _selectedIndexController.selectedIndex.value,
                onTap: _selectedIndexController.changeTab,
                backgroundColor: AppTheme.surfaceElevated,
                selectedItemColor: AppTheme.accentTeal,
                unselectedItemColor: AppTheme.textSecondary,
                type: BottomNavigationBarType.fixed,
                selectedLabelStyle: TextStyle(
                  fontSize: 11.sp, // Thoda bada text
                  fontWeight: FontWeight.bold, // Bold for selected
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 10.sp, // Same size, normal weight
                  fontWeight: FontWeight.normal,
                ),
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.home,
                      size: 6.w,
                      color: _selectedIndexController.selectedIndex.value == 0
                          ? AppTheme.accentTeal
                          : AppTheme.textSecondary,
                    ),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.web,
                      size: 6.w,
                      color: _selectedIndexController.selectedIndex.value == 1
                          ? AppTheme.accentTeal
                          : AppTheme.textSecondary,
                    ),
                    label: 'Browser',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.settings,
                      size: 6.w,
                      color: _selectedIndexController.selectedIndex.value == 2
                          ? AppTheme.accentTeal
                          : AppTheme.textSecondary,
                    ),
                    label: 'Settings',
                  ),
                ],
              ),
            ],
          ),

        );
      }),
    );
  }
}

