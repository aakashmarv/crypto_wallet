import 'package:cryptovault_pro/views/import_existing_wallet/widgets/import_progress_widget.dart';
import 'package:cryptovault_pro/views/import_existing_wallet/widgets/security_tips_widget.dart';
import 'package:cryptovault_pro/views/import_existing_wallet/widgets/wallet_name_input_widget.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../constants/app_keys.dart';
import '../../core/app_export.dart';
import '../../servieces/mnemonic_service.dart';
import '../../servieces/sharedpreferences_service.dart';
import '../../utils/logger.dart';
import './widgets/mnemonic_input_widget.dart';

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

  Future<void> _onImportStart() async {
    final input = _mnemonicPhrase.trim();

    if (input.isEmpty) {
      _showToast('Please enter recovery phrase or private key', isError: true);
      return;
    }

    // ✅ Detect type of import: Mnemonic vs Private Key
    final wordCount = input.split(RegExp(r'\s+')).length;
    final isMnemonic = input.split(RegExp(r'\s+')).length >= 12 &&
        MnemonicService.validateMnemonic(input);
    final isPrivateKey = RegExp(r'^(0x)?[0-9a-fA-F]{64}$').hasMatch(input);
    appLog('🧩 [Detection] Word count: $wordCount');
    appLog('🧠 [Detection] isMnemonic: $isMnemonic');
    appLog('🔑 [Detection] isPrivateKey: $isPrivateKey');

    if (!isMnemonic && !isPrivateKey) {
      _showToast('Invalid mnemonic or private key format', isError: true);
      return;
    }

    final walletNameToSave = _walletName.isEmpty ? 'Imported' : _walletName;
    final prefs = await SharedPreferencesService.getInstance();
    await prefs.setString(AppKeys.currentWalletName, walletNameToSave);
    appLog('💾 [Saved] Wallet name saved: $walletNameToSave');
    appLog('➡️ [Navigation] Navigating to password setup with arguments:');
    appLog('   fromImport: true');
    appLog('   mnemonic/privateKey: $input');
    appLog('   isPrivateKey: $isPrivateKey');
    // ✅ Navigate to password setup, passing type information
    Get.toNamed(
      AppRoutes.passwordSetup,
      arguments: {
        'fromImport': true,
        'mnemonic': input, // can be mnemonic or private key
        'isPrivateKey': isPrivateKey,
      },
    );
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
    if (_mnemonicPhrase.trim().startsWith('0x') ||
        RegExp(r'^(0x)?[0-9a-fA-F]{64}$').hasMatch(_mnemonicPhrase.trim())) {
      return 'Enter or paste your private key';
    }

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
      backgroundColor: AppTheme.primaryLight,
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
                    WalletNameInputWidget(
                      onNameChanged: _onWalletNameChanged,
                      initialValue: _walletName,
                    ),
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
      decoration: BoxDecoration(),
      child: Row(
        children: [
          GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryLight,
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
              )),
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              'Import Wallet',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
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
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
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

  Widget _buildImportButton() {
    final bool isActive = _isMnemonicValid && !_isImporting;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isActive ? _onImportStart : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentTeal,
          foregroundColor: AppTheme.primaryLight,
          disabledBackgroundColor: AppTheme.borderSubtle,
          disabledForegroundColor: AppTheme.primaryLight,
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
                      color: AppTheme.secondaryLight,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Importing Wallet...',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.secondaryLight,
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
                    color: isActive
                        ? AppTheme.secondaryLight
                        : AppTheme.textSecondary,
                    size: 20,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Import Wallet',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: isActive
                          ? AppTheme.secondaryLight
                          : AppTheme.textSecondary,
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
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.accentTeal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'Your recovery phrase is typically 12 or 24 words long. Make sure to enter them in the correct order with spaces between each word.',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Mock credentials for testing:\nRecovery phrase: abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
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
