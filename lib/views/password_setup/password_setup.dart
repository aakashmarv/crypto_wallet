import 'dart:convert';
import 'dart:io';
import 'package:cryptovault_pro/constants/app_keys.dart';
import 'package:cryptovault_pro/servieces/sharedpreferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';
import '../../servieces/mnemonic_service.dart';
import '../../servieces/multi_wallet_service.dart';
import '../../servieces/secure_mnemonic_service.dart';
import '../../utils/helper_util.dart';
import '../../utils/logger.dart';
import '../../widgets/app_button.dart';
import './widgets/biometric_setup_widget.dart';
import './widgets/password_requirements_widget.dart';
import './widgets/password_strength_indicator_widget.dart';

class PasswordSetup extends StatefulWidget {
  const PasswordSetup({super.key});

  @override
  State<PasswordSetup> createState() => _PasswordSetupState();
}

class _PasswordSetupState extends State<PasswordSetup>
    with TickerProviderStateMixin {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  bool _fromImport = false;
  String? _mnemonicPhrase;
  final _isPasswordVisible = false.obs;
  final _isConfirmPasswordVisible = false.obs;
  final _isRequirementsExpanded = false.obs;
  final _isBiometricEnabled = false.obs;
  final _isLoading = false.obs;
  final _passwordError = ''.obs;
  final _confirmPasswordError = ''.obs;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
    _confirmPasswordController.addListener(_onConfirmPasswordChanged);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = Get.arguments as Map<String, dynamic>?;

    _fromImport = args?['fromImport'] ?? false;
    _mnemonicPhrase = args?['mnemonic'];
  }

  void _onPasswordChanged() {
    setState(() {
      _passwordError.value = '';
      if (_confirmPasswordController.text.isNotEmpty) {
        _validateConfirmPassword();
      }
    });
  }

  void _onConfirmPasswordChanged() {
    setState(() {
      _validateConfirmPassword();
    });
  }

  void _validateConfirmPassword() {
    if (_confirmPasswordController.text.isEmpty) {
      _confirmPasswordError.value = '';
    } else if (_passwordController.text != _confirmPasswordController.text) {
      _confirmPasswordError.value = 'Passwords do not match';
    } else {
      _confirmPasswordError.value = '';
    }
  }

  bool get _isPasswordValid {
    final password = _passwordController.text;
    return password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[0-9]')) &&
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }

  bool get _canSetPassword {
    return _isPasswordValid &&
        _confirmPasswordController.text.isNotEmpty &&
        _confirmPasswordError.isEmpty &&
        !_isLoading.value;
  }

  Future<void> _handleSetPassword() async {
    HelperUtil.closeKeyboard(context);
    if (!_canSetPassword) return;
    appLog('⚠️ [Password] Cannot set password yet.');
    _isLoading.value = true;
    appLog('🔹 [Password] Setting password process started...');
    final storage = const FlutterSecureStorage();

    try {
      HapticFeedback.lightImpact();
      // 🔹 Save password securely
      final password = _passwordController.text.trim();
      appLog(
          '🔑 [Password] Entered password: "${password.isNotEmpty ? '***hidden***' : '(empty)'}"');
      if (password.isNotEmpty) {
        await storage.write(key: AppKeys.userPassword, value: password);
        appLog('💾 [SecureStorage] Password saved successfully.');
      }

      await Future.delayed(const Duration(seconds: 1)); // small UX delay
      if (!mounted) return;

      if (_fromImport) {
        appLog('🟩 [Import Flow] Starting wallet import...');
        // 🟩 Import wallet (Mnemonic OR Private Key)
        final input = _mnemonicPhrase?.trim();
        final isPrivateKey = Get.arguments?['isPrivateKey'] ?? false;
        appLog('📥 [Import Data] Input: "$input"');
        appLog('📥 [Import Data] isPrivateKey: $isPrivateKey');
        if (input == null || input.isEmpty) {
          _passwordError.value = 'Please enter recovery phrase or private key.';
          return;
        }

        // ✅ Initialize services
        appLog('⚙️ [Init] Initializing services...');
        final secureService = SecureMnemonicService();
        final prefs = await SharedPreferencesService.getInstance();
        final multiWalletService = MultiWalletService(secureService);

        WalletInfo? wallet;

        if (isPrivateKey) {
          appLog('🔸 [PrivateKey Import] Starting import...');
          // 🔸 Import from Private Key
          try {
            wallet = await multiWalletService.importPrivateKey(input, password);
            appLog('✅ [PrivateKey Import] Wallet imported: ${wallet.address}');
          } catch (e) {
            _passwordError.value = 'Invalid private key format.';
            appLog('Private key import error: $e');
            return;
          }
        } else {
          appLog('🔹 [Mnemonic Import] Starting mnemonic import...');
          // 🔹 Import from Mnemonic
          if (!MnemonicService.validateMnemonic(input)) {
            _passwordError.value = 'Invalid recovery phrase.';
            return;
          }

          await secureService.encryptAndStoreMnemonic(input, password);
          appLog('🔒 [Mnemonic Storage] Mnemonic encrypted & stored.');
          wallet = await multiWalletService.deriveWalletFromMnemonic(input, 0);
          appLog('✅ [Wallet Derivation] Wallet derived: ${wallet.address}');

          // Save wallet indexes [0]
          await multiWalletService.saveIndexes([0]);
          appLog('💾 [Wallet Index] Index [0] saved.');
        }

        if (wallet == null) {
          _passwordError.value = 'Failed to import wallet.';
          return;
        }

        // ✅ Convert Ethereum-style address (0x...) → Ruby-chain format (r...)
        final rubyAddress = HelperUtil.toRubyAddress(wallet.address);

        // ✅ Store wallet info
        await prefs.setString(AppKeys.walletAddress, rubyAddress);
        await prefs.setBool(AppKeys.isLogin, true);
        await prefs.setString(
            AppKeys.createdAt, DateTime.now().toIso8601String());
        appLog('💾 [Prefs] Wallet address & login info saved.');

        // ✅ Save wallet metadata (for wallet list tracking)
        final walletName =
            prefs.getString(AppKeys.currentWalletName) ?? 'My Wallet';
        appLog('📘 [Wallet Name] Current wallet name: $walletName');
        final namesJson = prefs.getString(AppKeys.walletsListJson);
        List<Map<String, dynamic>> existing = [];

        if (namesJson != null) {
          try {
            existing = (jsonDecode(namesJson) as List<dynamic>)
                .map((e) => Map<String, dynamic>.from(e))
                .toList();
            appLog(
                '📂 [Wallet List] Existing wallets loaded (${existing.length}).');
          } catch (_) {
            existing = [];
            appLog(
                '⚠️ [Wallet List] Failed to decode existing list. Starting fresh.');
          }
        }

        existing.add({
          'name': walletName,
          'address': wallet.address,
          'index': wallet.index,
          'createdAt': DateTime.now().toIso8601String(),
        });

        await prefs.setString(AppKeys.walletsListJson, jsonEncode(existing));
        appLog(
            '💾 [Wallet List] Wallet metadata added. Total wallets: ${existing.length}');
        appLog('🎉 [Success] Wallet imported successfully.');
        // ✅ Navigate to dashboard
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        // 🟦 For new wallet creation → go to mnemonic display screen
        Get.toNamed(AppRoutes.mnemonicPhraseDisplay);
      }
    } catch (e) {
      _passwordError.value = 'Failed to set password. Please try again.';
      appLog("Password save error: $e");
    } finally {
      if (mounted) _isLoading.value = false;
    }
  }

  Future<bool> _onWillPop() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? AppTheme.surfaceElevatedDark
                : AppTheme.surfaceElevated,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Leave Password Setup?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            content: Text(
              'Your progress will be lost if you go back now.',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Stay',
                  style: TextStyle(color: AppTheme.accentTeal),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Leave',
                  style: TextStyle(color: AppTheme.errorRed),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            // gradient: LinearGradient(
            //   begin: Alignment.topCenter,
            //   end: Alignment.bottomCenter,
            //   colors: [
            //     AppTheme.primaryLight,
            //     AppTheme.secondaryLight.withValues(alpha: 0.8),
            //   ],
            // ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 1.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 3.h),
                        _buildProgressIndicator(),
                        SizedBox(height: 4.h),
                        _buildTitle(),
                        SizedBox(height: 3.h),
                        Obx(
                          () => PasswordRequirementsWidget(
                            password: _passwordController.text,
                            isExpanded: _isRequirementsExpanded.value,
                            onToggle: () {
                              _isRequirementsExpanded.value =
                                  !_isRequirementsExpanded.value;
                            },
                          ),
                        ),
                        SizedBox(height: 3.h),
                        _buildPasswordField(),
                        PasswordStrengthIndicatorWidget(
                          password: _passwordController.text,
                        ),
                        SizedBox(height: 3.h),
                        _buildConfirmPasswordField(),
                        SizedBox(height: 3.h),

                        /// biometric setup
                        Obx(() => BiometricSetupWidget(
                              isBiometricEnabled: _isBiometricEnabled.value,
                              onBiometricToggle: (value) async {
                                _isBiometricEnabled.value = value;
                                final prefs = await SharedPreferencesService
                                    .getInstance();
                                appLog("isBiometricEnable :: $value");
                                await prefs.setBool(
                                    AppKeys.isBiometricEnable, value);
                              },
                            )),
                        SizedBox(height: 4.h),
                        _buildSetPasswordButton(),
                        SizedBox(height: 3.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          InkWell(
            onTap: () async {
              if (await _onWillPop()) {
                Navigator.pop(context);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.surfaceElevatedDark //change
                    : AppTheme.secondaryLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1,
                ),
              ),
              child: Icon(
                Platform.isIOS
                    ? Icons.arrow_back_ios_new_rounded
                    : Icons.arrow_back_rounded,
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Password Setup',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step 2 of 3',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.accentTeal,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.accentTeal,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create a Strong Password',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Your password will be used to unlock your wallet and authorize transactions. Make it strong and memorable.',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Obx(() => TextFormField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                obscureText: !_isPasswordVisible.value,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  _confirmPasswordFocusNode.requestFocus();
                },
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  errorText: _passwordError.value.isNotEmpty
                      ? _passwordError.value
                      : null,
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: Icon(
                      Icons.lock_outline,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Confirm Password',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Obx(() => TextFormField(
                controller: _confirmPasswordController,
                focusNode: _confirmPasswordFocusNode,
                obscureText: !_isConfirmPasswordVisible.value,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  if (_canSetPassword) {
                    _handleSetPassword();
                  }
                },
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
                decoration: InputDecoration(
                  hintText: 'Confirm your password',
                  hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  errorText: _confirmPasswordError.value.isNotEmpty
                      ? _confirmPasswordError.value
                      : null,
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_confirmPasswordController.text.isNotEmpty &&
                          _confirmPasswordError.isEmpty)
                        Padding(
                          padding: EdgeInsets.only(right: 2.w),
                          child: Icon(
                            Icons.check_circle,
                            color: AppTheme.successGreen,
                            size: 20,
                          ),
                        ),
                      IconButton(
                        onPressed: () {
                          _isConfirmPasswordVisible.value =
                              !_isConfirmPasswordVisible.value;
                        },
                        icon: Icon(
                          _isConfirmPasswordVisible.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppTheme.textSecondary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: Icon(
                      Icons.lock_outline,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                ),

              )),
        ],
      ),
    );
  }

  Widget _buildSetPasswordButton() {
    return Obx(() => AppButton(
          label: "Set Password",
          enabled: _canSetPassword,
          isLoading: _isLoading.value,
          onPressed: _handleSetPassword,
        ));
  }
}
