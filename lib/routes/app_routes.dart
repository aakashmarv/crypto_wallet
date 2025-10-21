// import 'package:flutter/material.dart';
// import '../views/password_setup/password_setup.dart';
// import '../views/d_app_browser/d_app_browser.dart';
// import '../views/create_new_wallet/create_new_wallet.dart';
// import '../views/import_existing_wallet/import_existing_wallet.dart';
// import '../views/onboarding_flow/onboarding_flow.dart';
// import '../views/mnemonic_phrase_display/mnemonic_phrase_display.dart';
//
// class AppRoutes {
//   // TODO: Add your routes here
//   static const String initial = '/';
//   static const String passwordSetup = '/password-setup';
//   static const String dAppBrowser = '/d-app-browser';
//   static const String createNewWallet = '/create-new-wallet';
//   static const String importExistingWallet = '/import-existing-wallet';
//   static const String onboardingFlow = '/onboarding-flow';
//   static const String mnemonicPhraseDisplay = '/mnemonic-phrase-display';
//
//   static Map<String, WidgetBuilder> routes = {
//     initial: (context) => const OnboardingFlow(),
//     passwordSetup: (context) => const PasswordSetup(),
//     dAppBrowser: (context) => const DAppBrowser(),
//     createNewWallet: (context) => const CreateNewWallet(),
//     importExistingWallet: (context) => const ImportExistingWallet(),
//     onboardingFlow: (context) => const OnboardingFlow(),
//     mnemonicPhraseDisplay: (context) => const MnemonicPhraseDisplay(),
//     // TODO: Add your other routes here
//   };
// }


import 'package:cryptovault_pro/splashscreen.dart';
import 'package:cryptovault_pro/views/address_book/address_book_screen.dart';
import 'package:cryptovault_pro/views/app_lock_screen.dart';
import 'package:cryptovault_pro/views/dashboard/dashboard_screen.dart';
import 'package:cryptovault_pro/views/home/swap_screen.dart';
import 'package:cryptovault_pro/views/home/transaction_history_screen.dart';
import 'package:cryptovault_pro/views/password_unlock_screen.dart';
import 'package:get/get.dart';
import '../views/change_password/change_password_screen.dart';
import '../views/create_new_wallet/create_new_wallet.dart';
import '../views/d_app_browser/d_app_browser.dart';
import '../views/import_existing_wallet/import_existing_wallet.dart';
import '../views/mnemonic_phrase_display/mnemonic_phrase_display.dart';
import '../views/onboarding_flow/onboarding_flow.dart';
import '../views/password_setup/password_setup.dart';


class AppRoutes {
  // Route names
  static const String initial = '/';
  static const String onboarding = '/onboarding';
  static const String dashboard = '/dashboard';
  static const String passwordSetup = '/password-setup';
  static const String dAppBrowser = '/d-app-browser';
  static const String createNewWallet = '/create-new-wallet';
  static const String importExistingWallet = '/import-existing-wallet';
  static const String onboardingFlow = '/onboarding-flow';
  static const String mnemonicPhraseDisplay = '/mnemonic-phrase-display';
  static const String swap = '/swap';
  static const String transationHistory = '/transactionHistory';
  static const String appLock = '/appLock';
  static const String passwordUnlockScreen = '/passwordUnlockScreen';
  static const String addressBook = '/address-book';
  static const String changePassword= '/changePassword';

  // Default transition settings
  static const _defaultTransition = Transition.cupertino;
  static const _transitionDuration = Duration(milliseconds: 400);

  // Helper method to build pages
  static GetPage _buildPage({
    required String name,
    required GetPageBuilder page,
  }) {
    return GetPage(
      name: name,
      page: page,
      transition: _defaultTransition,
      transitionDuration: _transitionDuration,
    );
  }

  // All routes list
  static List<GetPage> getRoutes() {
    return [
      _buildPage(name: initial, page: () => const SplashScreen()),
      _buildPage(name: onboarding, page: () => const OnboardingFlow()),
      _buildPage(name: dashboard, page: () =>  DashboardScreen()),
      _buildPage(name: passwordSetup, page: () => const PasswordSetup()),
      _buildPage(name: dAppBrowser, page: () => const DAppBrowser()),
      _buildPage(name: createNewWallet, page: () => const CreateNewWallet()),
      _buildPage(name: importExistingWallet, page: () => const ImportExistingWallet()),
      _buildPage(name: onboardingFlow, page: () => const OnboardingFlow()),
      _buildPage(name: mnemonicPhraseDisplay, page: () => const MnemonicPhraseDisplay()),
      _buildPage(name: swap, page: () => const SwapScreen()),
      _buildPage(name: transationHistory, page: () => const TransactionHistoryScreen()),
      _buildPage(name: appLock, page: () => AppLockScreen()),
      _buildPage(name: passwordUnlockScreen, page: () => PasswordUnlockScreen()),
      _buildPage(name: addressBook, page: () => AddressBookScreen()),
      _buildPage(name: changePassword, page: () => ChangePasswordScreen()),
      // TODO: add other screens here when needed
    ];
  }
}
