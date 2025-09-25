import 'package:cryptovault_pro/views/setting/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/selectedIndex_controller.dart';
import '../../widgets/custom_icon_widget.dart';
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

    return true; // Double back press within 3 sec → app closes
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Obx(() {
        return Scaffold(
          key: _scaffoldKey,

          // appBar: CustomAppBar(
          //   title: _titles[index],
          //   showMenu: index == 0,
          //   onMenuTap: () {
          //     _scaffoldKey.currentState?.openDrawer();
          //   },
          // ),
          body: _screens[_selectedIndexController.selectedIndex.value],
            bottomNavigationBar:  BottomNavigationBar(
                currentIndex: _selectedIndexController.selectedIndex.value,
                onTap: _selectedIndexController.changeTab,
                backgroundColor: AppTheme.surfaceElevated,
                selectedItemColor: AppTheme.accentTeal,
                unselectedItemColor: AppTheme.textSecondary,
                type: BottomNavigationBarType.fixed,
                items: [
                  BottomNavigationBarItem(
                    icon: CustomIconWidget(
                      iconName: 'home',
                      size: 6.w,
                      color: _selectedIndexController.selectedIndex.value == 0
                          ? AppTheme.accentTeal
                          : AppTheme.textSecondary,
                    ),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: CustomIconWidget(
                      iconName: 'web',
                      size: 6.w,
                      color: _selectedIndexController.selectedIndex.value == 1
                          ? AppTheme.accentTeal
                          : AppTheme.textSecondary,
                    ),
                    label: 'Browser',
                  ),
                  BottomNavigationBarItem(
                    icon: CustomIconWidget(
                      iconName: 'settings',
                      size: 6.w,
                      color: _selectedIndexController.selectedIndex.value == 2
                          ? AppTheme.accentTeal
                          : AppTheme.textSecondary,
                    ),
                    label: 'Settings',
                  ),
                ],
              ), );
      }),
    );


    // return WillPopScope(
    //   onWillPop: _onWillPop,
    //   child: Scaffold(
    //     body: Obx(
    //           () => _screens[_selectedIndexController.selectedIndex.value],
    //     ),
    //     bottomNavigationBar: Obx(
    //           () => BottomNavigationBar(
    //         currentIndex: _selectedIndexController.selectedIndex.value,
    //         onTap: _selectedIndexController.changeTab,
    //         backgroundColor: AppTheme.surfaceElevated,
    //         selectedItemColor: AppTheme.accentTeal,
    //         unselectedItemColor: AppTheme.textSecondary,
    //         type: BottomNavigationBarType.fixed,
    //         items: [
    //           BottomNavigationBarItem(
    //             icon: CustomIconWidget(
    //               iconName: 'home',
    //               size: 6.w,
    //               color: _selectedIndexController.selectedIndex.value == 0
    //                   ? AppTheme.accentTeal
    //                   : AppTheme.textSecondary,
    //             ),
    //             label: 'Home',
    //           ),
    //           BottomNavigationBarItem(
    //             icon: CustomIconWidget(
    //               iconName: 'web',
    //               size: 6.w,
    //               color: _selectedIndexController.selectedIndex.value == 1
    //                   ? AppTheme.accentTeal
    //                   : AppTheme.textSecondary,
    //             ),
    //             label: 'DApp Browser',
    //           ),
    //           BottomNavigationBarItem(
    //             icon: CustomIconWidget(
    //               iconName: 'settings',
    //               size: 6.w,
    //               color: _selectedIndexController.selectedIndex.value == 2
    //                   ? AppTheme.accentTeal
    //                   : AppTheme.textSecondary,
    //             ),
    //             label: 'Settings',
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }
}




// class DashboardScreen extends StatelessWidget {
//   DashboardScreen({super.key});
//
//   final SelectedIndexController controller = Get.put(SelectedIndexController());
//
//   final List<Widget> _screens = const [
//     HomeScreen(),
//     DAppBrowser(),
//     SettingsScreen(),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: controller.onWillPop,
//       child: Obx(() => Scaffold(
//         key: controller.scaffoldKey,
//         backgroundColor: AppTheme.primaryDark,
//         body: _screens[controller.selectedIndex.value],
//         bottomNavigationBar: BottomNavigationBar(
//           currentIndex: controller.selectedIndex.value,
//           backgroundColor: AppTheme.surfaceElevated,
//           selectedItemColor: AppTheme.accentTeal,
//           unselectedItemColor: AppTheme.textSecondary,
//           type: BottomNavigationBarType.fixed,
//           onTap: (index) => controller.changeTab(index),
//           items: [
//             BottomNavigationBarItem(
//               icon: CustomIconWidget(
//                 iconName: 'home',
//                 size: 6.w,
//                 color: controller.selectedIndex.value == 0
//                     ? AppTheme.accentTeal
//                     : AppTheme.textSecondary,
//               ),
//               label: 'Home',
//             ),
//             BottomNavigationBarItem(
//               icon: CustomIconWidget(
//                 iconName: 'web',
//                 size: 6.w,
//                 color: controller.selectedIndex.value == 1
//                     ? AppTheme.accentTeal
//                     : AppTheme.textSecondary,
//               ),
//               label: 'DApp Browser',
//             ),
//             BottomNavigationBarItem(
//               icon: CustomIconWidget(
//                 iconName: 'settings',
//                 size: 6.w,
//                 color: controller.selectedIndex.value == 2
//                     ? AppTheme.accentTeal
//                     : AppTheme.textSecondary,
//               ),
//               label: 'Settings',
//             ),
//           ],
//         ),
//       )),
//     );
//   }
// }
