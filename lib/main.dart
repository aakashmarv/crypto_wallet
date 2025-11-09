import 'package:cryptovault_pro/servieces/app_lock_service.dart';
import 'package:cryptovault_pro/servieces/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../core/app_export.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync(() => AppLockService().init());
  await Get.putAsync(() => ThemeService().init());
  // CRITICAL: Device orientation lock - DO NOT REMOVE
  Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
  ]).then((value) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, screenType) {
        return Obx(() {
          final themeService = Get.find<ThemeService>();

          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Ruby wallet & dapp browser',

            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeService.themeMode.value,

            // CRITICAL: NEVER REMOVE OR MODIFY
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.0),
                ),
                child: child!,
              );
            },

            initialRoute: AppRoutes.initial,
            getPages: AppRoutes.getRoutes(),
          );
        });
      },
    );
  }
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Sizer(builder: (context, orientation, screenType) {
//       return GetMaterialApp(
//         debugShowCheckedModeBanner: false,
//         title: 'Ruby wallet & dapp browser',
//         theme: AppTheme.lightTheme,
//         darkTheme: AppTheme.lightTheme,
//         themeMode: ThemeMode.system,
//         // CRITICAL: NEVER REMOVE OR MODIFY
//         builder: (context, child) {
//           return MediaQuery(
//             data: MediaQuery.of(context).copyWith(
//               textScaler: const TextScaler.linear(1.0),
//             ),
//             child: child!,
//           );
//         },
//         initialRoute: AppRoutes.initial,
//         getPages: AppRoutes.getRoutes(),
//       );
//     });
//   }
// }
