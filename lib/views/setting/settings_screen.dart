import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../routes/app_routes.dart';
import '../../servieces/secure_mnemonic_service.dart';
import '../../servieces/sharedpreferences_service.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = true;

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
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 2.h),
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
            _buildNavigationTile(
              context,
              icon: Icons.receipt_long,
              title: "View Transaction",
              onTap: () {},
            ),
            _buildNavigationTile(
              context,
              icon: Icons.book,
              title: "Address Book",
              onTap: () {},
            ),
            _buildNavigationTile(
              context,
              icon: Icons.link,
              title: "Connected Sites",
              onTap: () {},
            ),
            _buildNavigationTile(
              context,
              icon: Icons.lock_reset,
              title: "Change Password",
              onTap: () {},
            ),
            _buildNavigationTile(
              context,
              icon: Icons.help_outline,
              title: "Help & Support",
              onTap: () {},
            ),
            _buildNavigationTile(
              context,
              icon: Icons.privacy_tip,
              title: "Privacy Policy",
              onTap: () {},
            ),
            _buildNavigationTile(
              context,
              icon: Icons.logout,
              title: "Logout",
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
    );
  }

  // 🔘 Logout Confirmation + Clear All Data
  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryDark,
        title: Text(
          'Confirm Logout',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          'Are you sure you want to log out? This will delete all wallet data.',
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

    if (confirm != true) return;

    // ✅ Clear all data
    final prefs = await SharedPreferencesService.getInstance();
    await prefs.clear();

    await SecureMnemonicService().clearAll();
    // await MultiWalletService().clearAll();

    // ✅ Navigate to onboarding / login screen
    Get.offAllNamed(AppRoutes.onboarding);
  }

  // 🔘 Switch Tile Widget
  Widget _buildSwitchTile(BuildContext context,
      {required IconData icon, required String title, required bool value, required Function(bool) onChanged}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accentTeal, size: 6.w),
          SizedBox(width: 3.w),
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
      {required IconData icon, required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: AppTheme.secondaryDark.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderSubtle),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.textPrimary, size: 6.w),
            SizedBox(width: 3.w),
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
            Icon(Icons.keyboard_arrow_right, color: AppTheme.textSecondary, size: 6.w),
          ],
        ),
      ),
    );
  }
}
