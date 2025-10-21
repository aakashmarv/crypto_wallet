import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../routes/app_routes.dart';
import '../../servieces/multi_wallet_service.dart';
import '../../servieces/secure_mnemonic_service.dart';
import '../../servieces/sharedpreferences_service.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  bool _isDarkMode = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
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
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDark,
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
                _buildSwitchTile(
                  context,
                  icon: Icons.dark_mode,
                  title: "Dark Mode",
                  value: _isDarkMode,
                  onChanged: (val) {
                    setState(() => _isDarkMode = val);
                  },
                ),
                _buildDivider(),
                _buildNavigationTile(
                  context,
                  icon: Icons.receipt_long,
                  title: "View Transaction",
                  onTap: () {},
                ),
                _buildDivider(),
                _buildNavigationTile(
                  context,
                  icon: Icons.book,
                  title: "Address Book",
                  onTap: () => Get.toNamed(AppRoutes.addressBook),
                ),
                _buildDivider(),
                _buildNavigationTile(
                  context,
                  icon: Icons.link,
                  title: "Connected Sites",
                  onTap: () {},
                ),
                _buildDivider(),
                _buildNavigationTile(
                  context,
                  icon: Icons.lock_reset,
                  title: "Change Password",
                  onTap: () => Get.toNamed(AppRoutes.changePassword),
                ),
                _buildDivider(),
                _buildNavigationTile(
                  context,
                  icon: Icons.help_outline,
                  title: "Help & Support",
                  onTap: () {_launchURL("https://uxbill.com/about");
                  },
                ),
                _buildDivider(),
                _buildNavigationTile(
                  context,
                  icon: Icons.privacy_tip,
                  title: "Privacy Policy",
                  onTap: () {_launchURL("https://uxbill.com/about");},
                ),
                _buildDivider(),
                _buildNavigationTile(
                  context,
                  icon: Icons.logout,
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
        backgroundColor: AppTheme.primaryDark,
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
            child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Logout', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm != true) {
      print('🚫 [Logout] User canceled logout.');
      return;
    }

    print('🔐 [Logout] Logout process started...');

    try {
      // 🔹 Step 2: Clear all wallet-related data safely
      // a) Clear SharedPreferences
      final prefs = await SharedPreferencesService.getInstance();
      await prefs.clear();
      print('🧹 [Logout] SharedPreferences cleared.');

      // b) Clear encrypted storage, mnemonic & AES keys,wallet caches, derived wallets, indexes
      final secureService = SecureMnemonicService();
      final multiWalletService = MultiWalletService(secureService);
      await multiWalletService.clearAll();
      print('🧹 [Logout] MultiWalletService cache and indexes cleared.');

      // 🔹 Step 3: Provide feedback
      HapticFeedback.mediumImpact();

      Get.offAllNamed(AppRoutes.onboarding);

    } catch (e, stack) {
      print(stack);
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
  Widget _buildSwitchTile(BuildContext context,
      {required IconData icon, required String title, required bool value, required Function(bool) onChanged}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 2.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.accentTeal.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.accentTeal, size: 5.5.w),
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
            onChanged: onChanged,
            activeColor: AppTheme.accentTeal,
            inactiveThumbColor: AppTheme.textSecondary,
          )
        ],
      ),
    );
  }

  // 🔘 Navigation Tile Widget
  Widget _buildNavigationTile(BuildContext context,
      {required IconData icon, required String title, required VoidCallback onTap, bool isDestructive = false}) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      splashColor: (isDestructive ? Colors.redAccent : AppTheme.accentTeal).withOpacity(0.1),
      highlightColor: (isDestructive ? Colors.redAccent : AppTheme.accentTeal).withOpacity(0.05),
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
              child: Icon(
                  icon,
                  color: isDestructive ? Colors.redAccent : AppTheme.textPrimary,
                  size: 5.5.w
              ),
            ),
            SizedBox(width: 3.5.w),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? Colors.redAccent : AppTheme.textPrimary,
                ),
              ),
            ),
            Icon(
                Icons.chevron_right,
                color: AppTheme.textSecondary.withOpacity(0.5),
                size: 5.5.w
            ),
          ],
        ),
      ),
    );
  }
}

