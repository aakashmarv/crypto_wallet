import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_keys.dart';
import '../../routes/app_routes.dart';
import '../../servieces/multi_wallet_service.dart';
import '../../servieces/secure_mnemonic_service.dart';
import '../../servieces/sharedpreferences_service.dart';
import '../../servieces/theme_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/logger.dart';
import '../password_setup/widgets/biometric_setup_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  bool _isDarkMode = true;
  bool _isBiometricEnabled = false;
  bool _isBiometricAvailable = false;
  String _biometricType = "Biometric";
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
    _loadBiometricStatus();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadBiometricStatus() async {
    final prefs = await SharedPreferencesService.getInstance();
    setState(() {
      _isBiometricEnabled = prefs.getBool(AppKeys.isBiometricEnable) ?? false;
      _isDarkMode = prefs.getBool(AppKeys.isDarkMode) ?? false;
    });
  }

  Future<void> _checkBiometricAvailability() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _isBiometricAvailable = true;
      _biometricType = Theme.of(context).platform == TargetPlatform.iOS
          ? "Face ID / Touch ID"
          : "Fingerprint";
    });
  }

  static Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open link: $e',
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryLight,
        elevation: 0,
        title: Text(
          "Settings",
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        iconTheme: IconThemeData(color: AppTheme.textPrimary),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
            child: Column(
              children: [
                _buildNavigationTile(
                  context,
                  icon: LucideIcons.keyRound,
                  title: "Security Keys",
                  onTap: () => Get.toNamed(AppRoutes.viewKeysScreen),
                ),
                _buildDivider(),
                _buildNavigationTile(
                  context,
                  icon: LucideIcons.notebook,
                  title: "Address Book",
                  onTap: () => Get.toNamed(AppRoutes.addressBook),
                ),
                _buildDivider(),
                // _buildNavigationTile(
                //   context,
                //   icon: Icons.link,
                //   title: "Connected Sites",
                //   onTap: () {},
                // ),
                // _buildDivider(),
                _buildNavigationTile(
                  context,
                  icon: LucideIcons.rotateCcwKey,
                  title: "Change Password",
                  onTap: () => Get.toNamed(AppRoutes.changePassword),
                ),
                _buildDivider(),
                _buildSwitchTile(
                  context,
                  icon: Icons.dark_mode,
                  title: _isDarkMode ? "Dark Mode" : "Light Mode",
                  value: _isDarkMode,
                  onChanged: (val) async {
                    setState(() => _isDarkMode = val);
                    await Get.find<ThemeService>()
                        .toggleTheme(val); // ✅ global theme change
                  },
                ),

                _buildDivider(),
                _buildSwitchTile(
                  context,
                  icon: LucideIcons.fingerprint,
                  title: "Enable $_biometricType",
                  value: _isBiometricEnabled && _isBiometricAvailable,
                  onChanged: _isBiometricAvailable
                      ? (val) {
                          _handleBiometricToggle(
                              val); // async ok to call; wrapper is sync
                        }
                      : null, // allowed now because parameter is nullable
                ),

                _buildDivider(),
                _buildNavigationTile(
                  context,
                  icon: LucideIcons.messageCircleQuestionMark,
                  title: "Help & Support",
                  onTap: () {
                    _launchURL("https://rubynodeui.ctskola.io/help-support");
                  },
                ),
                _buildDivider(),
                _buildNavigationTile(
                  context,
                  icon: LucideIcons.shieldAlert,
                  title: "Privacy Policy",
                  onTap: () {
                    _launchURL("https://rubynodeui.ctskola.io/privacy-policy");
                  },
                ),
                _buildDivider(),
                _buildNavigationTile(
                  context,
                  icon: LucideIcons.logOut,
                  title: "Logout",
                  isDestructive: true,
                  onTap: _handleLogout,
                ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showBiometricPrompt() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              backgroundColor: AppTheme.surfaceElevated,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(
                    Theme.of(context).platform == TargetPlatform.iOS
                        ? Icons.face
                        : Icons.fingerprint,
                    color: AppTheme.accentTeal,
                  ),
                  SizedBox(width: 12),
                  Text(
                    "Enable $_biometricType",
                    style: AppTheme.lightTheme.textTheme.titleLarge
                        ?.copyWith(color: AppTheme.textPrimary),
                  ),
                ],
              ),
              content: Text(
                "Use your $_biometricType to quickly and securely access your wallet.",
                style: AppTheme.lightTheme.textTheme.bodyMedium
                    ?.copyWith(color: AppTheme.textSecondary),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text("Cancel",
                      style: TextStyle(color: AppTheme.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context, true);
                    await Future.delayed(const Duration(milliseconds: 1000));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentTeal,
                    foregroundColor: AppTheme.primaryLight,
                  ),
                  child: const Text("Enable"),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _handleBiometricToggle(bool value) async {
    if (value && _isBiometricAvailable) {
      try {
        HapticFeedback.lightImpact();
        final bool? enabled = await _showBiometricPrompt();
        if (enabled == true) {
          final prefs = await SharedPreferencesService.getInstance();
          await prefs.setBool(AppKeys.isBiometricEnable, true);
          setState(() => _isBiometricEnabled = true);
        } else {
          setState(() => _isBiometricEnabled = false);
        }
      } catch (e) {
        setState(() => _isBiometricEnabled = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to setup $_biometricType. Please try again."),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } else {
      final prefs = await SharedPreferencesService.getInstance();
      await prefs.setBool(AppKeys.isBiometricEnable, false);
      setState(() => _isBiometricEnabled = false);
    }
  }

  // 🔘 Light Divider
  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.only(left: 13.w),
      child: Divider(
        color: AppTheme.borderSubtle.withOpacity(0.5),
        height: 1,
        thickness: 0.5,
      ),
    );
  }

  // 🔘 Logout Confirmation + Clear All Data
  Future<void> _handleLogout() async {
    // 🔹 Step 1: Ask for confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryLight,
        title: Text(
          'Confirm Logout',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          'Are you sure you want to log out?\n\nThis will permanently delete all wallet data, passwords, and cached info from this device.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Logout', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm != true) {
      appLog('🚫 [Logout] User canceled logout.');
      return;
    }

    appLog('🔐 [Logout] Logout process started...');

    try {
      // 🔹 Step 2: Clear all wallet-related data safely
      // a) Clear SharedPreferences
      final prefs = await SharedPreferencesService.getInstance();
      await prefs.clear();
      appLog('🧹 [Logout] SharedPreferences cleared.');

      // b) Clear encrypted storage, mnemonic & AES keys,wallet caches, derived wallets, indexes
      final secureService = SecureMnemonicService();
      final multiWalletService = MultiWalletService(secureService);
      await multiWalletService.clearAll();
      appLog('🧹 [Logout] MultiWalletService cache and indexes cleared.');

      // 🔹 Step 3: Provide feedback
      HapticFeedback.mediumImpact();

      Get.offAllNamed(AppRoutes.onboarding);
    } catch (e, stack) {
      appLog(stack);
      Get.snackbar(
        'Logout Failed',
        'Something went wrong while logging out. Please restart the app.',
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.redAccent,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // 🔘 Switch Tile Widget
// 🔘 Switch Tile Widget
  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool>? onChanged, // <-- change here
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 2.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.textPrimary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.black, size: 5.5.w),
          ),
          SizedBox(width: 3.5.w),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged:
                onChanged, // <-- pass through; Switch expects void Function(bool)?
            activeColor: AppTheme.accentTeal,
            inactiveThumbColor: AppTheme.textSecondary,
            inactiveTrackColor: AppTheme.borderSubtle,
          ),
        ],
      ),
    );
  }

  // 🔘 Navigation Tile Widget
  Widget _buildNavigationTile(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap,
      bool isDestructive = false}) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      splashColor: (isDestructive ? Colors.redAccent : AppTheme.accentTeal)
          .withOpacity(0.1),
      highlightColor: (isDestructive ? Colors.redAccent : AppTheme.accentTeal)
          .withOpacity(0.05),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 2.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.redAccent.withOpacity(0.15)
                    : AppTheme.textPrimary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  color:
                      isDestructive ? Colors.redAccent : AppTheme.textPrimary,
                  size: 5.5.w),
            ),
            SizedBox(width: 3.5.w),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color:
                      isDestructive ? Colors.redAccent : AppTheme.textPrimary,
                ),
              ),
            ),
            Icon(Icons.chevron_right,
                color: AppTheme.textSecondary.withOpacity(0.5), size: 5.5.w),
          ],
        ),
      ),
    );
  }
}
