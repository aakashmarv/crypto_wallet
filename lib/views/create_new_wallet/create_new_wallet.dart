import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../constants/app_keys.dart';
import '../../core/app_export.dart';
import '../../servieces/sharedpreferences_service.dart';
import '../../viewmodels/wallet_setup_controller.dart';
import './widgets/generate_wallet_button_widget.dart';
import './widgets/loading_animation_widget.dart';
import './widgets/progress_indicator_widget.dart';
import './widgets/security_info_card_widget.dart';
import './widgets/wallet_name_input_widget.dart';

class CreateNewWallet extends StatefulWidget {
  const CreateNewWallet({Key? key}) : super(key: key);

  @override
  State<CreateNewWallet> createState() => _CreateNewWalletState();
}

class _CreateNewWalletState extends State<CreateNewWallet>
    with TickerProviderStateMixin {
  final _walletName = ''.obs;
  final _isNameValid = false.obs;
  final _isGenerating = false.obs;
  final _generationProgress = 0.0.obs;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset:
            true, // ✅ allow safe scrolling when keyboard opens
        backgroundColor: AppTheme.primaryLight,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryLight,
                AppTheme.secondaryLight.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    // ✅ Only scrolls if content overflows
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      // ✅ Ensures it fills full height for same design look
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            // 🟩 App Bar
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4.w, vertical: 2.h),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Create New Wallet',
                                      style: AppTheme
                                          .lightTheme.textTheme.headlineSmall
                                          ?.copyWith(
                                        color: AppTheme.textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 🟩 Progress Indicator
                            ProgressIndicatorWidget(
                              currentStep: 1,
                              totalSteps: 3,
                            ),

                            // 🟩 Main Content
                            Expanded(
                              child: Obx(() {
                                return _isGenerating.value
                                    ? Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(4.w),
                                          child: LoadingAnimationWidget(
                                            message:
                                                'Creating your secure wallet...',
                                            progress: _generationProgress.value,
                                          ),
                                        ),
                                      )
                                    : Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 4.w),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 2.h),
                                            // Welcome Text
                                            Text(
                                              'Let\'s create your wallet',
                                              style: AppTheme.lightTheme
                                                  .textTheme.headlineMedium
                                                  ?.copyWith(
                                                color: AppTheme.textPrimary,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            SizedBox(height: 1.h),
                                            Text(
                                              'Your wallet will be secured with industry-standard encryption and stored safely on your device.',
                                              style: AppTheme.lightTheme
                                                  .textTheme.bodyMedium
                                                  ?.copyWith(
                                                color: AppTheme.textSecondary,
                                                height: 1.5,
                                              ),
                                            ),
                                            SizedBox(height: 4.h),
                                            // Wallet Name Input
                                            WalletNameInputWidget(
                                              onNameChanged: _onNameChanged,
                                              onValidationChanged:
                                                  _onValidationChanged,
                                            ),
                                            SizedBox(height: 3.h),
                                            // Security Information Card
                                            const SecurityInfoCardWidget(),
                                            SizedBox(height: 4.h),
                                          ],
                                        ),
                                      );
                              }),
                            ),

                            // 🟩 Bottom Navigation  Button Area
                            Obx(() {
                              if (_isGenerating.value)
                                return const SizedBox.shrink();
                              return Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryLight,
                                  border: Border(
                                    top: BorderSide(
                                      color: AppTheme.borderSubtle
                                          .withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Obx(() => GenerateWalletButtonWidget(
                                          isEnabled: _isNameValid.value,
                                          isLoading: _isGenerating.value,
                                          onPressed: _generateWallet,
                                        )),
                                    SizedBox(height: 2.h),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Already have a wallet? ',
                                          style: AppTheme
                                              .lightTheme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pushNamed(context,
                                                AppRoutes.importExistingWallet);
                                          },
                                          child: Text(
                                            'Import it',
                                            style: AppTheme
                                                .lightTheme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: AppTheme.accentTeal,
                                              fontWeight: FontWeight.w600,
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor:
                                                  AppTheme.accentTeal,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return WillPopScope(
  //     onWillPop: _onWillPop,
  //     child: Scaffold(
  //       resizeToAvoidBottomInset: false,
  //       backgroundColor: AppTheme.primaryLight,
  //       body: Container(
  //         decoration: BoxDecoration(
  //           gradient: LinearGradient(
  //             begin: Alignment.topCenter,
  //             end: Alignment.bottomCenter,
  //             colors: [
  //               AppTheme.primaryLight,
  //               AppTheme.secondaryLight.withValues(alpha: 0.8),
  //             ],
  //           ),
  //         ),
  //         child: SafeArea(
  //           child: FadeTransition(
  //             opacity: _fadeAnimation,
  //             child: Column(
  //               children: [
  //                 // App Bar
  //                 Padding(
  //                   padding:
  //                   EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
  //                   child: Row(
  //                     children: [
  //                       Expanded(
  //                         child: Text(
  //                           'Create New Wallet',
  //                           style: AppTheme.lightTheme.textTheme.headlineSmall
  //                               ?.copyWith(
  //                             color: AppTheme.textPrimary,
  //                             fontWeight: FontWeight.w700,
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 // Progress Indicator
  //                 ProgressIndicatorWidget(
  //                   currentStep: 1,
  //                   totalSteps: 3,
  //                 ),
  //                 // Main Content
  //                 Expanded(
  //                   child: Obx(() {
  //                     return _isGenerating.value
  //                         ? Center(
  //                       child:
  //                       Padding(
  //                         padding: EdgeInsets.all(4.w),
  //                         child: LoadingAnimationWidget(
  //                           message: 'Creating your secure wallet...',
  //                           progress: _generationProgress.value,
  //                         ),
  //                       ),
  //                     )
  //                         : SingleChildScrollView(
  //                       padding: EdgeInsets.symmetric(horizontal: 4.w),
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           SizedBox(height: 2.h),
  //                           // Welcome Text
  //                           Text(
  //                             'Let\'s create your wallet',
  //                             style: AppTheme
  //                                 .darkTheme.textTheme.headlineMedium
  //                                 ?.copyWith(
  //                               color: AppTheme.textPrimary,
  //                               fontWeight: FontWeight.w700,
  //                             ),
  //                           ),
  //                           SizedBox(height: 1.h),
  //                           Text(
  //                             'Your wallet will be secured with industry-standard encryption and stored safely on your device.',
  //                             style: AppTheme.lightTheme.textTheme.bodyMedium
  //                                 ?.copyWith(
  //                               color: AppTheme.textSecondary,
  //                               height: 1.5,
  //                             ),
  //                           ),
  //                           SizedBox(height: 4.h),
  //                           // Wallet Name Input
  //                           WalletNameInputWidget(
  //                             onNameChanged: _onNameChanged,
  //                             onValidationChanged: _onValidationChanged,
  //                           ),
  //                           SizedBox(height: 3.h),
  //                           // Security Information Card
  //                           const SecurityInfoCardWidget(),
  //                           SizedBox(height: 4.h),
  //                         ],
  //                       ),
  //                     );
  //                   }),
  //                 ),
  //                 // Bottom Navigation  Button Area
  //                 Obx(() {
  //                   if (_isGenerating.value) return const SizedBox.shrink();
  //                   return Container(
  //                     padding: EdgeInsets.all(4.w),
  //                     decoration: BoxDecoration(
  //                       color: AppTheme.primaryLight,
  //                       border: Border(
  //                         top: BorderSide(
  //                           color: AppTheme.borderSubtle.withValues(alpha: 0.3),
  //                           width: 1,
  //                         ),
  //                       ),
  //                     ),
  //                     child: Column(
  //                       mainAxisSize: MainAxisSize.min,
  //                       children: [
  //                         Obx(() => GenerateWalletButtonWidget(
  //                           isEnabled: _isNameValid.value,
  //                           isLoading: _isGenerating.value,
  //                           onPressed: _generateWallet,
  //                         )),
  //                         SizedBox(height: 2.h),
  //                         Row(
  //                           mainAxisAlignment: MainAxisAlignment.center,
  //                           children: [
  //                             Text(
  //                               'Already have a wallet? ',
  //                               style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
  //                                 color: AppTheme.textSecondary,
  //                               ),
  //                             ),
  //                             GestureDetector(
  //                               onTap: () {
  //                                 Navigator.pushNamed(context, AppRoutes.importExistingWallet);
  //                               },
  //                               child: Text(
  //                                 'Import it',
  //                                 style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
  //                                   color: AppTheme.accentTeal,
  //                                   fontWeight: FontWeight.w600,
  //                                   decoration: TextDecoration.underline,
  //                                   decorationColor: AppTheme.accentTeal,
  //                                 ),
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ],
  //                     ),
  //                   );
  //                 }),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  void _onNameChanged(String name) {
    _walletName.value = name;
  }

  void _onValidationChanged(bool isValid) {
    _isNameValid.value = isValid;
  }

  Future<void> _generateWallet() async {
    if (!_isNameValid.value || _isGenerating.value) return;
    HapticFeedback.mediumImpact();
    _isGenerating.value = true;
    _generationProgress.value = 0.0;

    try {
      // Simulate secure wallet generation process
      await _simulateWalletGeneration();
      final prefs = await SharedPreferencesService.getInstance();
      await prefs.setString(AppKeys.currentWalletName, _walletName.value);
      // Navigate to mnemonic phrase display
      if (mounted) {
        Get.toNamed(
          AppRoutes.passwordSetup,
          arguments: {'fromImport': false},
        );
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        _showErrorDialog('Failed to generate wallet. Please try again.');
      }
    } finally {
      if (mounted) {
        _isGenerating.value = false;
        _generationProgress.value = 0.0;
      }
    }
  }

  Future<void> _simulateWalletGeneration() async {
    // Simulate secure generation steps with realistic timing
    final steps = [
      {'progress': 0.2, 'delay': 500},
      {'progress': 0.4, 'delay': 800},
      {'progress': 0.6, 'delay': 600},
      {'progress': 0.8, 'delay': 700},
      {'progress': 1.0, 'delay': 500},
    ];

    for (final step in steps) {
      await Future.delayed(Duration(milliseconds: step['delay'] as int));
      if (mounted) {
        _generationProgress.value = step['progress'] as double;
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.error,
              color: AppTheme.errorRed,
              size: 24,
            ),
            SizedBox(width: 3.w),
            Text(
              'Error',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.accentTeal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_isGenerating.value) {
      // Show confirmation dialog if generation is in progress
      final shouldExit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.surfaceElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning,
                color: AppTheme.warningOrange,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Text(
                'Cancel Generation?',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            'Wallet generation is in progress. Are you sure you want to cancel?',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Continue',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Cancel',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.errorRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
      return shouldExit ?? false;
    }
    return true;
  }
}
