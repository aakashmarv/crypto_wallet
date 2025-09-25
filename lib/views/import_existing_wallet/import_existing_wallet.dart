import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/import_progress_widget.dart';
import './widgets/mnemonic_input_widget.dart';
import './widgets/qr_scanner_button_widget.dart';
import './widgets/security_tips_widget.dart';
import './widgets/wallet_name_input_widget.dart';

class ImportExistingWallet extends StatefulWidget {
  const ImportExistingWallet({Key? key}) : super(key: key);

  @override
  State<ImportExistingWallet> createState() => _ImportExistingWalletState();
}

class _ImportExistingWalletState extends State<ImportExistingWallet> {
  final ScrollController _scrollController = ScrollController();

  String _mnemonicPhrase = '';
  String _walletName = '';
  bool _isMnemonicValid = false;
  bool _isImporting = false;
  int _currentStep = 1;
  final int _totalSteps = 3;

  // Mock credentials for demonstration
  final Map<String, dynamic> _mockWalletData = {
    'validMnemonic':
        'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about',
    'walletAddress': '0x742d35Cc6634C0532925a3b8D4C9db96C4b4Df8d',
    'balance': {
      'BTC': '0.00234567',
      'ETH': '1.23456789',
      'USDT': '1,234.56',
    },
  };

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onMnemonicChanged(String mnemonic) {
    setState(() {
      _mnemonicPhrase = mnemonic.trim();
    });
  }

  void _onMnemonicValidationChanged(bool isValid) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _isMnemonicValid = isValid;
        _currentStep = isValid ? 2 : 1;
      });
    });
  }


  void _onWalletNameChanged(String name) {
    setState(() {
      _walletName = name.trim();
    });
  }

  void _onQrCodeScanned(String qrContent) {
    setState(() {
      _mnemonicPhrase = qrContent;
    });

    // ✅ delay validation so it won’t run during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _onMnemonicValidationChanged(_validateMnemonic(qrContent));
    });
  }


  bool _validateMnemonic(String mnemonic) {
    final words = mnemonic.trim().toLowerCase().split(RegExp(r'\s+'));
    return (words.length == 12 || words.length == 24) &&
        words.every((word) => word.isNotEmpty);
  }

  Future<void> _handlePasteFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null && clipboardData!.text!.isNotEmpty) {
        _showPasteConfirmationDialog(clipboardData.text!);
      } else {
        _showToast('Clipboard is empty', isError: true);
      }
    } catch (e) {
      _showToast('Failed to access clipboard', isError: true);
    }
  }

  void _showPasteConfirmationDialog(String clipboardText) {
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
              Icons.warning,
              color: AppTheme.warningOrange,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Security Warning',
              style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are about to paste sensitive wallet information. Make sure:',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 2.h),
            _buildSecurityCheckItem('You are in a secure environment'),
            _buildSecurityCheckItem('No one can see your screen'),
            _buildSecurityCheckItem(
                'The clipboard content is from a trusted source'),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryDark,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.borderSubtle,
                  width: 1,
                ),
              ),
              child: Text(
                clipboardText.length > 100
                    ? '${clipboardText.substring(0, 100)}...'
                    : clipboardText,
                style: AppTheme.monoTextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _onQrCodeScanned(clipboardText);
              _showToast('Recovery phrase pasted successfully');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentTeal,
              foregroundColor: AppTheme.primaryDark,
            ),
            child: Text('Paste'),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCheckItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: AppTheme.successGreen,
            size: 16,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              text,
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _importWallet() async {
    // if (!_isMnemonicValid) {
    //   _showToast('Please enter a valid recovery phrase', isError: true);
    //   return;
    // }
    //
    // // Check if the mnemonic matches our mock valid mnemonic
    // if (_mnemonicPhrase.toLowerCase().trim() !=
    //     _mockWalletData['validMnemonic']) {
    //   _showToast('Invalid recovery phrase. Please check and try again.',
    //       isError: true);
    //   return;
    // }

    setState(() {
      _isImporting = true;
      _currentStep = 3;
    });

    try {
      // Simulate import process with realistic delays
      await _simulateImportProcess();

      // Show success message
      _showToast('Wallet imported successfully!');

      // Add haptic feedback
      HapticFeedback.lightImpact();

      // Navigate to dashboard after a short delay
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        Get.offAllNamed(AppRoutes.dashboard);
      }
    } catch (e) {
      _showToast('Import failed: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
          _currentStep = 2;
        });
      }
    }
  }

  Future<void> _simulateImportProcess() async {
    // Simulate validation
    await Future.delayed(const Duration(milliseconds: 800));

    // Simulate blockchain connection
    await Future.delayed(const Duration(milliseconds: 1200));

    // Simulate wallet creation
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  void _showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isError ? AppTheme.errorRed : AppTheme.successGreen,
      textColor: AppTheme.textPrimary,
      fontSize: 14,
    );
  }

  String _getCurrentStepDescription() {
    switch (_currentStep) {
      case 1:
        return 'Enter your 12 or 24 word recovery phrase';
      case 2:
        return 'Optionally name your wallet and review details';
      case 3:
        return 'Importing wallet and connecting to blockchain...';
      default:
        return 'Preparing wallet import...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ImportProgressWidget(
                      currentStep: _currentStep,
                      totalSteps: _totalSteps,
                      currentStepDescription: _getCurrentStepDescription(),
                    ),
                    SizedBox(height: 3.h),
                    const SecurityTipsWidget(),
                    SizedBox(height: 3.h),
                    MnemonicInputWidget(
                      onMnemonicChanged: _onMnemonicChanged,
                      onValidationChanged: _onMnemonicValidationChanged,
                      initialValue: _mnemonicPhrase,
                    ),
                    SizedBox(height: 3.h),
                    // QrScannerButtonWidget(
                    //   onQrCodeScanned: _onQrCodeScanned,
                    // ),
                    // SizedBox(height: 2.h),
                    _buildPasteButton(),
                    // SizedBox(height: 3.h),
                    // WalletNameInputWidget(
                    //   onNameChanged: _onWalletNameChanged,
                    //   initialValue: _walletName,
                    // ),
                    SizedBox(height: 4.h),
                    _buildImportButton(),
                    SizedBox(height: 2.h),
                    _buildHelpText(),
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        // color: AppTheme.secondaryDark,
        // boxShadow: [
        //   BoxShadow(
        //     color: AppTheme.shadowColor,
        //     blurRadius: 4,
        //     offset: const Offset(0, 2),
        //   ),
        // ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.secondaryDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.borderSubtle,
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.arrow_back,
                color: AppTheme.textPrimary,
                size: 24,
              ),
            )
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              'Import Wallet',
              style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.accentTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.accentTeal.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.security,
                  color: AppTheme.accentTeal,
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  'Secure',
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.accentTeal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasteButton() {
    return GestureDetector(
      onTap: _handlePasteFromClipboard,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.secondaryDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.borderSubtle,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.content_paste,
              color: AppTheme.textSecondary,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Text(
              'Paste from Clipboard',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildImportButton() {
  //   return SizedBox(
  //     width: double.infinity,
  //     child: ElevatedButton(
  //       onPressed: _isMnemonicValid && !_isImporting ? _importWallet : null,
  //       style: ElevatedButton.styleFrom(
  //         backgroundColor: _isMnemonicValid && !_isImporting
  //             ? AppTheme.accentTeal
  //             : AppTheme.borderSubtle,
  //         foregroundColor: _isMnemonicValid && !_isImporting
  //             ? AppTheme.primaryDark
  //             : AppTheme.textSecondary,
  //         padding: EdgeInsets.symmetric(vertical: 4.h),
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(16),
  //         ),
  //         elevation: _isMnemonicValid && !_isImporting ? 2 : 0,
  //       ),
  //       child: _isImporting
  //           ? Row(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 SizedBox(
  //                   width: 20,
  //                   height: 20,
  //                   child: CircularProgressIndicator(
  //                     strokeWidth: 2,
  //                     color: AppTheme.primaryDark,
  //                   ),
  //                 ),
  //                 SizedBox(width: 3.w),
  //                 Text(
  //                   'Importing Wallet...',
  //                   style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
  //                     color: AppTheme.primaryDark,
  //                     fontWeight: FontWeight.w600,
  //                   ),
  //                 ),
  //               ],
  //             )
  //           : Row(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 CustomIconWidget(
  //                   iconName: 'download',
  //                   color: _isMnemonicValid
  //                       ? AppTheme.primaryDark
  //                       : AppTheme.textSecondary,
  //                   size: 20,
  //                 ),
  //                 SizedBox(width: 3.w),
  //                 Text(
  //                   'Import Wallet',
  //                   style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
  //                     color: _isMnemonicValid
  //                         ? AppTheme.primaryDark
  //                         : AppTheme.textSecondary,
  //                     fontWeight: FontWeight.w600,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //     ),
  //   );
  // }
  Widget _buildImportButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isMnemonicValid && !_isImporting ? _importWallet : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentTeal, // ✅ always solid teal
          foregroundColor: AppTheme.primaryDark,
          disabledBackgroundColor: AppTheme.borderSubtle, // ✅ even when disabled
          disabledForegroundColor: AppTheme.primaryDark,
          padding: EdgeInsets.symmetric(vertical: 4.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        child: _isImporting
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.primaryDark,
              ),
            ),
            SizedBox(width: 3.w),
            Text(
              'Importing Wallet...',
              style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.primaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.download,
              color: AppTheme.primaryDark,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Text(
              'Import Wallet',
              style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.primaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpText() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.accentTeal.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentTeal.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.help_outline,
                color: AppTheme.accentTeal,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Need Help?',
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.accentTeal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'Your recovery phrase is typically 12 or 24 words long. Make sure to enter them in the correct order with spaces between each word.',
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Mock credentials for testing:\nRecovery phrase: abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about',
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.warningOrange,
              height: 1.4,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
