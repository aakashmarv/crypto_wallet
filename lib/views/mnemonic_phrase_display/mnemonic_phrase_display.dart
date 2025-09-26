import 'dart:io';

import 'package:cryptovault_pro/widgets/custome_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/app_button.dart';
import './widgets/backup_verification_dialog.dart';
import './widgets/mnemonic_phrase_grid.dart';
import './widgets/security_checklist.dart';
import './widgets/security_warning_banner.dart';

class MnemonicPhraseDisplay extends StatefulWidget {
  const MnemonicPhraseDisplay({Key? key}) : super(key: key);

  @override
  State<MnemonicPhraseDisplay> createState() => _MnemonicPhraseDisplayState();
}

class _MnemonicPhraseDisplayState extends State<MnemonicPhraseDisplay>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool _isPhraseRevealed = false;
  bool _allChecklistCompleted = false;
  bool _isBackupVerified = false;

  // Mock mnemonic phrase data
  final List<String> _mnemonicWords = [
    'abandon',
    'ability',
    'able',
    'about',
    'above',
    'absent',
    'absorb',
    'abstract',
    'absurd',
    'abuse',
    'access',
    'accident'
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _preventScreenshots();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _enableScreenshots();
    super.dispose();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
  }

  void _preventScreenshots() {
    // Enable screenshot prevention on Android
    try {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
      );
    } catch (e) {
      // Handle silently for platforms that don't support this
    }
  }

  void _enableScreenshots() {
    try {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } catch (e) {
      // Handle silently for platforms that don't support this
    }
  }

  void _togglePhraseVisibility() {
    setState(() {
      _isPhraseRevealed = !_isPhraseRevealed;
    });

    if (_isPhraseRevealed) {
      _showSecurityReminder();
    }
  }

  void _showSecurityReminder() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.security,
              color: AppTheme.accentTeal,
              size: 6.w,
            ),
            SizedBox(width: 3.w),
            Text(
              'Security Reminder',
              style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.accentTeal,
              ),
            ),
          ],
        ),
        content: Text(
          'Make sure no one is looking at your screen. Your recovery phrase is now visible and should be kept completely private.',
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textPrimary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'I Understand',
              style: TextStyle(color: AppTheme.accentTeal),
            ),
          ),
        ],
      ),
    );
  }

  void _onChecklistCompleted(bool allCompleted) {
    setState(() {
      _allChecklistCompleted = allCompleted;
    });
  }

  void _startBackupVerification() {
    if (!_isPhraseRevealed || !_allChecklistCompleted) {
      _showIncompleteBackupDialog();
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackupVerificationDialog(
        mnemonicWords: _mnemonicWords,
        onVerificationComplete: _onVerificationComplete,
      ),
    );
  }

  void _showIncompleteBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: AppTheme.warningOrange,
              size: 6.w,
            ),
            SizedBox(width: 3.w),
            Text(
              'Incomplete Backup',
              style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.warningOrange,
              ),
            ),
          ],
        ),
        content: Text(
          !_isPhraseRevealed
              ? 'Please reveal and review your recovery phrase first.'
              : 'Please complete all security checklist items before proceeding.',
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it',
              style: TextStyle(color: AppTheme.accentTeal),
            ),
          ),
        ],
      ),
    );
  }

  void _onVerificationComplete() {
    setState(() {
      _isBackupVerified = true;
    });

    // Navigate to DApp browser after successful verification
    Future.delayed(const Duration(milliseconds: 500), () {
      Get.offAllNamed(AppRoutes.dashboard);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!_isBackupVerified) {
          _showExitWarningDialog();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppTheme.primaryDark,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // app bar
                CustomeAppbar(
                  title: 'Secure Your Wallet',
                  subtitle: 'Step 3 of 3',
                  onBack: _showExitWarningDialog,
                ),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        SizedBox(height: 2.h),
                        // Security warning banner
                        const SecurityWarningBanner(),
                        SizedBox(height: 2.h),
                        // Mnemonic phrase grid
                        MnemonicPhraseGrid(
                          mnemonicWords: _mnemonicWords,
                          isRevealed: _isPhraseRevealed,
                          onRevealToggle: _togglePhraseVisibility,
                        ),
                        SizedBox(height: 3.h),
                        // Security checklist
                        if (_isPhraseRevealed)
                          SecurityChecklist(
                            onAllChecked: _onChecklistCompleted,
                          ),

                        SizedBox(height: 4.h),
                      ],
                    ),
                  ),
                ),
                // Bottom action button
                _buildBottomAction(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isPhraseRevealed && !_allChecklistCompleted)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    color: AppTheme.textSecondary,
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Complete all checklist items to continue',
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          AppButton(
            label: "I've Backed Up My Phrase",
            enabled: (_isPhraseRevealed && _allChecklistCompleted),
            onPressed: _startBackupVerification,
            trailingIcon: Icon(
              Icons.arrow_forward,
              color: AppTheme.primaryDark,
              size: 5.w,
            ),
          )

        ],
      ),
    );
  }

  void _showExitWarningDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: AppTheme.warningOrange,
              size: 6.w,
            ),
            SizedBox(width: 3.w),
            Text(
              'Exit Warning',
              style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.warningOrange,
              ),
            ),
          ],
        ),
        content: Text(
          'If you exit now without completing the backup verification, you may lose access to your wallet. Are you sure you want to continue?',
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textPrimary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Stay Here',
              style: TextStyle(color: AppTheme.accentTeal),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'Exit Anyway',
              style: TextStyle(color: AppTheme.errorRed),
            ),
          ),
        ],
      ),
    );
  }
}
