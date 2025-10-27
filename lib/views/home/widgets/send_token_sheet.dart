import 'package:cryptovault_pro/core/app_export.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/helper_util.dart';
import '../../home/controller/home_controller.dart';

class SendTokenSheet extends StatefulWidget {
  final String tokenName;
  final String tokenAddress;

  const SendTokenSheet({
    super.key,
    required this.tokenName,
    required this.tokenAddress,
  });

  @override
  State<SendTokenSheet> createState() => _SendTokenSheetState();
}

class _SendTokenSheetState extends State<SendTokenSheet>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  final HomeController _homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnimation =
        CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleSendToken() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final recipient = _recipientController.text.trim();
    final amount = _amountController.text.trim();
    final sender = _homeController.walletAddress.value.trim();

    if (sender.isEmpty) {
      Get.snackbar("Error", "Wallet address not found. Please re-login.",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    HelperUtil.closeKeyboard(context);

    // 🟢 You can integrate your transaction sending logic here
    // e.g. call your SendService or SendController

    Get.snackbar(
      "Transaction Initiated",
      "Sending $amount ${widget.tokenName} to $recipient",
      backgroundColor: AppTheme.accentTeal,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: DraggableScrollableSheet(
        initialChildSize: 0.75, // opens higher like ImportTokenSheet
        minChildSize: 0.55,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Container(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          decoration: BoxDecoration(
            color: AppTheme.secondaryDark,
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            bottom: false,
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 12.w,
                  height: 0.8.h,
                  margin: EdgeInsets.only(top: 1.5.h, bottom: 2.h),
                  decoration: BoxDecoration(
                    color: AppTheme.borderSubtle,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),

                // Scrollable content
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Send ${widget.tokenName}",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 3.h),

                          // Recipient field
                          TextFormField(
                            controller: _recipientController,
                            style: TextStyle(color: AppTheme.textPrimary),
                            decoration: _inputDecoration(
                              label: "Recipient Address",
                              suffix: IconButton(
                                icon: Icon(Icons.paste, color: AppTheme.textSecondary),
                                onPressed: () async {
                                  final data = await Clipboard.getData(Clipboard.kTextPlain);
                                  if (data?.text?.isNotEmpty ?? false) {
                                    _recipientController.text = data!.text!.trim();
                                  }
                                },
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return "Enter recipient address";
                              }
                              if (!v.startsWith('0x') && !v.startsWith('r')) {
                                return "Invalid address format";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 2.h),

                          TextFormField(
                            controller: _amountController,
                            keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                            style: TextStyle(color: AppTheme.textPrimary),
                            decoration: _inputDecoration(label: "Amount"),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return "Enter amount";
                              }
                              final parsed = double.tryParse(v);
                              if (parsed == null || parsed <= 0) {
                                return "Invalid amount";
                              }
                              return null;
                            },
                          ),


                          SizedBox(height: 3.h),

                          // Info
                          Text(
                            "Enter recipient address and amount to send ${widget.tokenName}.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: AppTheme.textSecondary.withOpacity(0.9),
                              fontSize: 10.sp,
                            ),
                          ),
                          SizedBox(height: 10.h),
                        ],
                      ),
                    ),
                  ),
                ),

                // ✅ Bottom button (fixed)
                SafeArea(
                  top: false,
                  child: ElevatedButton(
                    onPressed: _handleSendToken,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentTeal,
                      disabledBackgroundColor:
                      AppTheme.accentTeal.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(
                          vertical: 1.5.h, horizontal: 20.w),
                    ),
                    child: Text(
                      "Send Token",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 1.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
  InputDecoration _inputDecoration({required String label, Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppTheme.textSecondary),
      suffixIcon: suffix,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppTheme.borderSubtle, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppTheme.accentTeal, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      // ✅ When error appears → keep same border, only red color
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      errorStyle: TextStyle(
        color: Colors.red,
        fontSize: 10.sp,
        fontWeight: FontWeight.w400,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
    );
  }

}
