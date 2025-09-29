import 'package:cryptovault_pro/core/app_export.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../widgets/app_button.dart';

class ActionButtonsRowWidget extends StatelessWidget {
  const ActionButtonsRowWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: [
          // Deposit Button
          Expanded(
            child: Padding(
              padding:  EdgeInsets.only(left: 3.w,right:3.w,top: 1.h),
              child: _ActionButton(
                label: 'Deposit',
                icon: Icons.download_rounded,
                onTap: () => _handleDeposit(context),
              ),
            ),
          ),

          SizedBox(width: 3.w),

          // Send Button
          Expanded(
            child: Padding(
              padding:EdgeInsets.only(left: 3.w,right:3.w,top: 1.h),
              child: _ActionButton(
                label: 'Send',
                icon: Icons.send_rounded,
                onTap: () => _handleSend(context),
              ),
            ),
          ),

          SizedBox(width: 3.w),

          // Swap Button
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 3.w,right:3.w,top: 1.h),
              child: _ActionButton(
                label: 'Swap',
                icon: Icons.swap_horiz_rounded,
                onTap: () => _handleSwap(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDeposit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _DepositBottomSheet(),
    );
  }


  void _handleSend(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _SendBottomSheet(),
    );
  }

  void _handleSwap(BuildContext context) {
    Get.toNamed(AppRoutes.swap);
  }
}
class _DepositBottomSheet extends StatelessWidget {
  const _DepositBottomSheet();

  final String walletAddress = "rA99b007d6a2...D06dE1948746";

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.35,
      maxChildSize: 0.75,
      builder: (_, controller) => Container(
        padding: EdgeInsets.fromLTRB(
          5.w,
          3.h,
          5.w,
          bottomPadding > 0 ? bottomPadding : 2.h,
        ),
        decoration: BoxDecoration(
          color: AppTheme.secondaryDark,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Handle bar
            Container(
              width: 10.w,
              height: 0.7.h,
              decoration: BoxDecoration(
                color: AppTheme.borderSubtle,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 2.h),

            Text(
              "Deposit Address",
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 2.h),

            // QR Code
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SizedBox(
                width: 40.w,
                height: 40.w,
                child: Center(
                  child: Icon(
                    Icons.qr_code,
                    size: 36.w,
                    color: AppTheme.black,
                  ),
                ),
              ),
            ),
            SizedBox(height: 2.h),

            // Wallet Address + Copy Button
            Row(
              children: [
                Expanded(
                  child: Text(
                    walletAddress,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.copy, color: AppTheme.successGreen, size: 6.w),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: walletAddress));

                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SendBottomSheet extends StatefulWidget {
  const _SendBottomSheet();

  @override
  State<_SendBottomSheet> createState() => _SendBottomSheetState();
}

class _SendBottomSheetState extends State<_SendBottomSheet>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  String _selectedCoin = "Ruby";
  final Map<String, double> _balances = {
    "Ruby": 1250.50,
    "Ruby Testnet": 300.75,
    "Ruby Dev": 120.25,
  };

  bool _showCoins = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _handleSend() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sending ${_amountController.text} $_selectedCoin...")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.55,
        maxChildSize: 0.9,
        builder: (_, controller) => Container(
          padding: EdgeInsets.fromLTRB(
            5.w,
            3.h,
            5.w,
            bottomPadding > 0 ? bottomPadding : 2.h,
          ),
          decoration: BoxDecoration(
            color: AppTheme.secondaryDark,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ✅ Handle bar
              Container(
                width: 12.w,
                height: 0.8.h,
                margin: EdgeInsets.only(bottom: 2.h),
                decoration: BoxDecoration(
                  color: AppTheme.borderSubtle,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),

              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    controller: controller,
                    children: [
                      Text(
                        "Send Tokens",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 3.h),

                      // ✅ Recipient Address
                      TextFormField(
                        controller: _recipientController,
                        style: TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          labelText: "Recipient Address",
                          labelStyle: TextStyle(color: AppTheme.textSecondary),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.borderSubtle),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.accentTeal),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorBorder: OutlineInputBorder( // 🔴 error border
                            borderSide: BorderSide(color: Colors.red, width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedErrorBorder: OutlineInputBorder( // 🔴 error border while typing
                            borderSide: BorderSide(color: Colors.red, width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorStyle: TextStyle( // 🔴 error text styling
                            color: Colors.red,
                            fontSize: 10.sp,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.copy, color: AppTheme.textSecondary),
                            onPressed: () {
                              if (_recipientController.text.isNotEmpty) {
                                Clipboard.setData(ClipboardData(text: _recipientController.text));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Address copied!")),
                                );
                              }
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter recipient address";
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 1.5.h),
// ✅ Amount
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          labelText: "Amount",
                          labelStyle: TextStyle(color: AppTheme.textSecondary),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.borderSubtle),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppTheme.accentTeal),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red, width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red, width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorStyle: TextStyle(
                            color: Colors.red,
                            fontSize: 10.sp,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Enter amount";
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) return "Invalid amount";
                          if (amount > _balances[_selectedCoin]!) return "Insufficient balance";
                          return null;
                        },
                      ),
                      SizedBox(height: 1.5.h),
                      // ✅ Custom Dropdown
                      InkWell(
                        onTap: () => setState(() => _showCoins = !_showCoins),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.borderSubtle),
                            borderRadius: BorderRadius.circular(16),
                            color: AppTheme.secondaryDark.withOpacity(0.5),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(2.w),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentTeal.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.monetization_on,
                                    color: AppTheme.accentTeal, size: 22),
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Text(
                                  _selectedCoin,
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                              AnimatedRotation(
                                turns: _showCoins ? 0.5 : 0,
                                duration: const Duration(milliseconds: 300),
                                child: Icon(Icons.keyboard_arrow_down,
                                    color: AppTheme.accentTeal, size: 24),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ✅ Coin List (expandable)
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        firstChild: const SizedBox.shrink(),
                        secondChild: Column(
                          children: _balances.keys.map((coin) {
                            return ListTile(
                              onTap: () {
                                setState(() {
                                  _selectedCoin = coin;
                                  _showCoins = false;
                                });
                              },
                              title: Text(
                                coin,
                                style: TextStyle(color: AppTheme.textPrimary),
                              ),
                              trailing: Text(
                                _balances[coin].toString(),
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 11.sp),
                              ),
                            );
                          }).toList(),
                        ),
                        crossFadeState:
                        _showCoins ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                      ),

                      SizedBox(height: 2.h),
                    ],
                  ),
                ),
              ),

              // ✅ Send Button pinned at bottom
              SafeArea(
                top: false,
                child: AppButton(
                  label: "Send",
                  onPressed: _handleSend,
                  enabled: true,
                  trailingIcon: null,
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}


class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        decoration: BoxDecoration(
          color: AppTheme.accentTherd,
          // gradient: LinearGradient(
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          //   colors: [
          //     AppTheme.accentTeal.withValues(alpha: 0.1),
          //     AppTheme.successGreen.withValues(alpha: 0.05),
          //   ],
          // ),
          borderRadius: BorderRadius.circular(12),
          // border: Border.all(
          //   color: AppTheme.borderSubtle,
          //   width: 1,
          // ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppTheme.textPrimary,
              size: 5.w,
            ),
            SizedBox(height: 1.h),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 9.5.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
