// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:sizer/sizer.dart';
//
// import '../core/app_export.dart';
// import '../widgets/custom_error_widget.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   bool _hasShownError = false;
//
//   // 🚨 CRITICAL: Custom error handling - DO NOT REMOVE
//   ErrorWidget.builder = (FlutterErrorDetails details) {
//     if (!_hasShownError) {
//       _hasShownError = true;
//
//       // Reset flag after 3 seconds to allow error widget on new screens
//       Future.delayed(Duration(seconds: 5), () {
//         _hasShownError = false;
//       });
//
//       return CustomErrorWidget(
//         errorDetails: details,
//       );
//     }
//     return SizedBox.shrink();
//   };
//
//   // 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE
//   Future.wait([
//     SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
//   ]).then((value) {
//     runApp(MyApp());
//   });
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Sizer(builder: (context, orientation, screenType) {
//       return MaterialApp(
//         title: 'cryptovault_pro',
//         theme: AppTheme.lightTheme,
//         darkTheme: AppTheme.darkTheme,
//         themeMode: ThemeMode.light,
//         // 🚨 CRITICAL: NEVER REMOVE OR MODIFY
//         builder: (context, child) {
//           return MediaQuery(
//             data: MediaQuery.of(context).copyWith(
//               textScaler: TextScaler.linear(1.0),
//             ),
//             child: child!,
//           );
//         },
//         // 🚨 END CRITICAL SECTION
//         debugShowCheckedModeBanner: false,
//         routes: AppRoutes.routes,
//         initialRoute: AppRoutes.initial,
//       );
//     });
//   }
// }

import 'package:cryptovault_pro/constants/app_keys.dart';
import 'package:cryptovault_pro/servieces/sharedpreferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:sizer/sizer.dart';
import '../core/app_export.dart';
import '../widgets/custom_error_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // final AppStateController appStateController = Get.put(AppStateController());
  // 🔹 (CHANGE 1) SharedPreferences instance load
  final prefs = await SharedPreferencesService.getInstance();
  final bool isBiometricEnabled = prefs.getBool(AppKeys.isBiometricEnable) ?? false;

  // 🔹 (CHANGE 2) Decide initial route based on lock setting
  final String initialRoute =
  isBiometricEnabled ? AppRoutes.appLock : AppRoutes.initial;
  bool _hasShownError = false;

  // 🚨 CRITICAL: Custom error handling - DO NOT REMOVE
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (!_hasShownError) {
      _hasShownError = true;

      // Reset flag after 3 seconds to allow error widget on new screens
      Future.delayed(const Duration(seconds: 5), () {
        _hasShownError = false;
      });

      return CustomErrorWidget(
        errorDetails: details,
      );
    }
    return const SizedBox.shrink();
  };

  // 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE
  Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
  ]).then((value) {
    runApp(MyApp(initialRoute: initialRoute));
  });
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, screenType) {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'cryptovault_pro',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        // 🚨 CRITICAL: NEVER REMOVE OR MODIFY
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0),
            ),
            child: child!,
          );
        },
        // 🚨 END CRITICAL SECTION
        initialRoute: initialRoute,
        getPages: AppRoutes.getRoutes(),
      );
    });
  }
}

