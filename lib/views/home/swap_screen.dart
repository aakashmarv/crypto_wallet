import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/app_button.dart';

class SwapScreen extends StatefulWidget {
  const SwapScreen({super.key});

  @override
  State<SwapScreen> createState() => _SwapScreenState();
}

class _SwapScreenState extends State<SwapScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fromAmountController = TextEditingController();
  final TextEditingController _toAmountController = TextEditingController();

  String _fromCoin = "RUBY";
  String _toCoin = "USDT";

  final List<String> _coins = ["RUBY", "USDT", "BTC", "ETH"];

  bool _isLoading = false;
  bool _isSwapped = false; // 🔹 Track swap of From/To sections

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryLight,
        elevation: 0,
        title: Text(
          "Swap",
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        iconTheme: IconThemeData(color: AppTheme.textPrimary),
      ),
      body: Form(
        key: _formKey,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 AnimatedSwitcher for From/To Sections
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.5),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      );
                    },
                    child: _isSwapped
                        ? _buildSwapSection(
                            key: const ValueKey("to"),
                            title: "To",
                            controller: _toAmountController,
                            selectedCoin: _toCoin,
                            onCoinChanged: (coin) =>
                                setState(() => _toCoin = coin),
                          )
                        : _buildSwapSection(
                            key: const ValueKey("from"),
                            title: "From",
                            controller: _fromAmountController,
                            selectedCoin: _fromCoin,
                            onCoinChanged: (coin) =>
                                setState(() => _fromCoin = coin),
                          ),
                  ),
                  SizedBox(height: 2.h),

                  // 🔹 Swap Icon
                  Center(
                    child: GestureDetector(
                      onTap: () => setState(() => _isSwapped = !_isSwapped),
                      child: AnimatedRotation(
                        turns: _isSwapped ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.accentTeal.withOpacity(0.5),
                          ),
                          child: Icon(Icons.swap_vert,
                              color: AppTheme.textPrimary),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // 🔹 Second Section (switches position)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.5),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      );
                    },
                    child: _isSwapped
                        ? _buildSwapSection(
                            key: const ValueKey("from"),
                            title: "From",
                            controller: _fromAmountController,
                            selectedCoin: _fromCoin,
                            onCoinChanged: (coin) =>
                                setState(() => _fromCoin = coin),
                          )
                        : _buildSwapSection(
                            key: const ValueKey("to"),
                            title: "To",
                            controller: _toAmountController,
                            selectedCoin: _toCoin,
                            onCoinChanged: (coin) =>
                                setState(() => _toCoin = coin),
                          ),
                  ),
                  SizedBox(height: 8.h),

                  // 🔹 Swap Info Card
                  _buildSwapInfoCard(),
                  SizedBox(height: 20.h), // space for bottom button
                ],
              ),
            ),

            // 🔹 Bottom Swap Button
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 2.h,
              left: 1.w,
              right: 1.w,
              child: AppButton(
                label: "Swap",
                onPressed: _isLoading ? null : _handleSwap,
                isLoading: _isLoading,
                enabled: !_isLoading, // disable button while loading
                trailingIcon: !_isLoading
                    ? Icon(
                        Icons.swap_horiz,
                        color: AppTheme.primaryLight, // match your button style
                        size: 18.sp,
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Swap Section Builder
  Widget _buildSwapSection({
    required Key key,
    required String title,
    required TextEditingController controller,
    required String selectedCoin,
    required Function(String) onCoinChanged,
  }) {
    return Container(
      key: key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              // Amount Field
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: "0.0",
                    hintStyle: TextStyle(color: AppTheme.textSecondary),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.borderSubtle),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.accentTeal),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    errorStyle: TextStyle(fontSize: 9.sp, color: Colors.red),
                    suffixIcon:
                        Icon(Icons.attach_money, color: AppTheme.textSecondary),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Enter amount";
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) return "Invalid amount";
                    return null;
                  },
                ),
              ),
              SizedBox(width: 3.w),

              // Coin Dropdown
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.2.h),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryLight.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCoin,
                    dropdownColor: AppTheme.secondaryLight,
                    icon: Icon(Icons.keyboard_arrow_down,
                        color: AppTheme.textSecondary),
                    style: GoogleFonts.inter(
                      color: AppTheme.textPrimary,
                      fontSize: 11.sp,
                    ),
                    items: _coins
                        .map((coin) =>
                            DropdownMenuItem(value: coin, child: Text(coin)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) onCoinChanged(value);
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🔹 Swap Info Card
  Widget _buildSwapInfoCard() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.secondaryLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow("Minimum Received", "0.95 $_toCoin"),
          _infoRow("Exchange Rate", "1 $_fromCoin = 0.95 $_toCoin"),
          _infoRow("Gas Fee", "0.001 $_fromCoin"),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11.sp, color: AppTheme.textSecondary)),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary)),
        ],
      ),
    );
  }

  // 🔹 Handle Swap
  void _handleSwap() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      Future.delayed(const Duration(seconds: 2), () {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Swap successful!")),
        );
      });
    }
  }
}
