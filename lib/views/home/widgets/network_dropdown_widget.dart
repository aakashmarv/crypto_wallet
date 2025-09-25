import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../theme/app_theme.dart';

class NetworkDropdownWidget extends StatefulWidget {
  const NetworkDropdownWidget({super.key});

  @override
  State<NetworkDropdownWidget> createState() => _NetworkDropdownWidgetState();
}

class _NetworkDropdownWidgetState extends State<NetworkDropdownWidget> {
  String _selected = "Ruby"; // default
  bool _isMenuOpen = false; // for arrow animation

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onOpened: () {
        setState(() => _isMenuOpen = true);
      },
      onCanceled: () {
        setState(() => _isMenuOpen = false);
      },
      onSelected: (value) {
        setState(() {
          _selected = value;
          _isMenuOpen = false;
        });
      },
      offset: const Offset(0, 40),
      color: AppTheme.secondaryDark.withOpacity(0.95),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.successGreen, width: 1.2),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: "Ruby",
          child: Row(
            children: [
              Icon(Icons.circle, size: 14, color: AppTheme.successGreen),
              SizedBox(width: 2.w),
              Text(
                "Ruby",
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: "Ruby Testnet",
          child: Row(
            children: [
              Icon(Icons.circle_outlined, size: 14, color: AppTheme.successGreen),
              SizedBox(width: 2.w),
              Text(
                "Ruby Testnet",
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(50), // fully rounded
          border: Border.all(color: AppTheme.successGreen, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shield_rounded, size: 16, color: AppTheme.successGreen),
            SizedBox(width: 1.w),
            Text(
              _selected,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.successGreen,
              ),
            ),
            SizedBox(width: 1.w),
            AnimatedRotation(
              turns: _isMenuOpen ? 0.5 : 0, // arrow up/down
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: AppTheme.successGreen,
                size: 5.w,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
