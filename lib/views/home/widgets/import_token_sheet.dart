import 'dart:convert';
import 'package:cryptovault_pro/core/app_export.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';

import '../../../theme/app_theme.dart';
import '../../../utils/helper_util.dart';
import '../../home/controller/home_controller.dart';
import '../../../viewmodels/token_list_controller.dart';
import '../../../viewmodels/import_token_controller.dart';

class ImportTokenSheet extends StatefulWidget {
  const ImportTokenSheet({super.key});

  @override
  State<ImportTokenSheet> createState() => _ImportTokenSheetState();
}

class _ImportTokenSheetState extends State<ImportTokenSheet>
    with SingleTickerProviderStateMixin {
  final HomeController _homeController = Get.find<HomeController>();
  final ImportTokenController _importTokenController =
      Get.put(ImportTokenController());

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tokenAddressController = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

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
    _tokenAddressController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleImportToken() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final userAddress = _homeController.walletAddress.value.trim();
    final tokenAddress = _tokenAddressController.text.trim();

    if (userAddress.isEmpty) {
      Get.snackbar("Error", "Wallet address not found. Please re-login.",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    HelperUtil.closeKeyboard(context);

    _importTokenController.isLoading.value = true;

    try {
      await _importTokenController.importToken(
        walletAddress: userAddress,
        contractAddress: tokenAddress,
      );

      // ✅ If successful (controller handles snackbar), close sheet after short delay
      if (_importTokenController.errorMessage.value.isEmpty) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) Navigator.of(context).pop();
        });
      }
    } finally {
      _importTokenController.isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: DraggableScrollableSheet(
        initialChildSize: 0.7, // ✅ opens higher
        minChildSize: 0.55,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Container(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          decoration: BoxDecoration(
            color: AppTheme.secondaryLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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

                // ✅ Scrollable Form (resizes when keyboard opens)
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context)
                              .viewInsets
                              .bottom), // ✅ only form scrolls
                      child: Column(
                        children: [
                          Text(
                            "Import Token",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 3.h),

                          // Token Address field
                          TextFormField(
                            controller: _tokenAddressController,
                            style: TextStyle(color: AppTheme.textPrimary),
                            decoration: InputDecoration(
                              labelText: "Token Contract Address",
                              labelStyle:
                                  TextStyle(color: AppTheme.textSecondary),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppTheme.borderSubtle),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppTheme.accentTeal),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.red, width: 1.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.red, width: 1.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              errorStyle: TextStyle(
                                color: Colors.red,
                                fontSize: 10.sp,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.paste,
                                    color: AppTheme.textSecondary),
                                onPressed: () async {
                                  final clipboard = await Clipboard.getData(
                                      Clipboard.kTextPlain);
                                  if (clipboard?.text?.isNotEmpty ?? false) {
                                    _tokenAddressController.text =
                                        clipboard!.text!.trim();
                                  }
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter token contract address";
                              }
                              if (!value.startsWith('r') &&
                                  !value.startsWith('0x')) {
                                return "Invalid token address";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 3.h),

                          Text(
                            "Paste your token contract address to import it to your Ruby wallet.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: AppTheme.textSecondary.withOpacity(0.9),
                              fontSize: 10.sp,
                            ),
                          ),
                          SizedBox(
                              height: 10.h), // ✅ space before bottom button
                        ],
                      ),
                    ),
                  ),
                ),

                // ✅ Button stays pinned at absolute bottom (won’t move with keyboard)
                SafeArea(
                  top: false,
                  child: Obx(() => ElevatedButton(
                        onPressed: _importTokenController.isLoading.value
                            ? null
                            : _handleImportToken,
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
                        child: _importTokenController.isLoading.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                "Import Token",
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.sp,
                                ),
                              ),
                      )),
                ),
                SizedBox(
                  height: 1.h,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
