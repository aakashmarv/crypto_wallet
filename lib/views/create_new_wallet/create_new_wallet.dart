import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
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
  String _walletName = '';
  bool _isNameValid = false;
  bool _isGenerating = false;
  double _generationProgress = 0.0;

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

  void _onNameChanged(String name) {
    setState(() {
      _walletName = name;
    });
  }

  void _onValidationChanged(bool isValid) {
    setState(() {
      _isNameValid = isValid;
    });
  }

  Future<void> _generateWallet() async {
    if (!_isNameValid || _isGenerating) return;

    // Haptic feedback
    HapticFeedback.mediumImpact();

    setState(() {
      _isGenerating = true;
      _generationProgress = 0.0;
    });

    try {
      // Simulate secure wallet generation process
      await _simulateWalletGeneration();

      // Navigate to mnemonic phrase display
      if (mounted) {
        Get.toNamed(AppRoutes.passwordSetup);
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        _showErrorDialog('Failed to generate wallet. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _generationProgress = 0.0;
        });
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
        setState(() {
          _generationProgress = step['progress'] as double;
        });
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
              style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
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
    if (_isGenerating) {
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
                style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            'Wallet generation is in progress. Are you sure you want to cancel?',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Continue',
                style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Cancel',
                style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppTheme.primaryDark,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryDark,
                AppTheme.secondaryDark.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // App Bar
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    child: Row(
                      children: [
                        // GestureDetector(
                        //   onTap: () async {
                        //     final canPop = await _onWillPop();
                        //     if (canPop && mounted) {
                        //       Navigator.of(context).pop();
                        //     }
                        //   },
                        //   child: Container(
                        //     padding: EdgeInsets.all(2.w),
                        //     decoration: BoxDecoration(
                        //       color: AppTheme.secondaryDark,
                        //       borderRadius: BorderRadius.circular(12),
                        //       border: Border.all(
                        //         color: AppTheme.borderSubtle,
                        //         width: 1,
                        //       ),
                        //     ),
                        //     child: CustomIconWidget(
                        //       iconName: 'arrow_back',
                        //       color: AppTheme.textPrimary,
                        //       size: 24,
                        //     ),
                        //   ),
                        // ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            'Create New Wallet',
                            style: AppTheme.darkTheme.textTheme.headlineSmall
                                ?.copyWith(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Progress Indicator
                  ProgressIndicatorWidget(
                    currentStep: 1,
                    totalSteps: 3,
                  ),

                  // Main Content
                  Expanded(
                    child: _isGenerating
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.all(4.w),
                              child: LoadingAnimationWidget(
                                message: 'Creating your secure wallet...',
                                progress: _generationProgress,
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 2.h),

                                // Welcome Text
                                Text(
                                  'Let\'s create your wallet',
                                  style: AppTheme
                                      .darkTheme.textTheme.headlineMedium
                                      ?.copyWith(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  'Your wallet will be secured with industry-standard encryption and stored safely on your device.',
                                  style: AppTheme.darkTheme.textTheme.bodyLarge
                                      ?.copyWith(
                                    color: AppTheme.textSecondary,
                                    height: 1.5,
                                  ),
                                ),

                                SizedBox(height: 4.h),

                                // Wallet Name Input
                                WalletNameInputWidget(
                                  onNameChanged: _onNameChanged,
                                  onValidationChanged: _onValidationChanged,
                                ),

                                SizedBox(height: 3.h),

                                // Security Information Card
                                const SecurityInfoCardWidget(),

                                SizedBox(height: 4.h),
                              ],
                            ),
                          ),
                  ),

                  // Bottom Button Area
                  if (!_isGenerating)
                    Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryDark,
                        border: Border(
                          top: BorderSide(
                            color: AppTheme.borderSubtle.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Generate Wallet
                          GenerateWalletButtonWidget(
                            isEnabled: _isNameValid,
                            isLoading: _isGenerating,
                            onPressed: _generateWallet,
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have a wallet? ',
                                style: AppTheme.darkTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, AppRoutes.importExistingWallet);
                                },
                                child: Text(
                                  'Import it',
                                  style: AppTheme.darkTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    color: AppTheme.accentTeal,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppTheme.accentTeal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
