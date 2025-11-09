import 'package:cryptovault_pro/viewmodels/transaction_history_controller.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import '../../constants/app_keys.dart';
import '../../servieces/sharedpreferences_service.dart';
import '../../theme/app_theme.dart';
import 'package:get/get.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  final TransactionHistoryController controller =
      Get.put(TransactionHistoryController());

  String? _walletAddress;

  @override
  void initState() {
    super.initState();
    _loadWalletAddress();
    controller.getTransactionHistory(); // initial fetch
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadWalletAddress() async {
    final prefs = await SharedPreferencesService.getInstance();
    _walletAddress = prefs.getString(AppKeys.walletAddress);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 🧭 Scroll listener for pagination
  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !controller.isLoading.value &&
        controller.transactions.length < controller.totalTransactions.value) {
      controller.loadMoreTransactions();
    }
  }

  /// 🔁 Pull to refresh
  Future<void> _onRefresh() async {
    await controller.refreshTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryLight,
      appBar: AppBar(
        title: Text(
          "Transaction History",
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.primaryLight,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.textPrimary),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.transactions.isEmpty) {
            return _buildShimmerList();
          }

          if (controller.transactions.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppTheme.accentTeal,
            child: _buildTransactionList(),
          );
        }),
      ),
    );
  }

  /// 🧩 Shimmer while loading
  Widget _buildShimmerList() {
    return ListView.builder(
      itemCount: 10,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      itemBuilder: (_, i) => Container(
        margin: EdgeInsets.only(bottom: 2.h),
        height: 10.h,
        decoration: BoxDecoration(
          color: AppTheme.borderSubtle,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  /// 🧩 Empty state
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, color: AppTheme.textSecondary, size: 40.sp),
            SizedBox(height: 2.h),
            Text(
              "No transactions yet",
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              "Your latest wallet activity will appear here",
              style: TextStyle(
                color: AppTheme.textSecondary.withOpacity(0.6),
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🧩 Transaction List with Pagination Loader
  Widget _buildTransactionList() {
    return Obx(() {
      final transactions = controller.transactions;
      final isLoading = controller.isLoading.value;
      final hasMore = transactions.length < controller.totalTransactions.value;

      return ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        itemCount: transactions.length + (isLoading && hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == transactions.length && isLoading && hasMore) {
            return _buildBottomLoader();
          }

          final tx = transactions[index];
          final isSent =
              tx.from?.toLowerCase() == _walletAddress?.toLowerCase();

          final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(
            DateTime.tryParse(tx.createdAt ?? '') ?? DateTime.now(),
          );

          return Container(
            margin: EdgeInsets.only(bottom: 1.8.h),
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.secondaryLight.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderSubtle, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSent
                        ? AppTheme.errorRed.withOpacity(0.1)
                        : AppTheme.successGreen.withOpacity(0.1),
                  ),
                  child: Icon(
                    isSent
                        ? Icons.call_made_rounded
                        : Icons.call_received_rounded,
                    color: isSent ? AppTheme.errorRed : AppTheme.successGreen,
                    size: 18.sp,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isSent ? 'Sent' : 'Received',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        '${tx.hash?.substring(0, 10)}...${tx.hash?.substring(tx.hash!.length - 6)}',
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: AppTheme.textSecondary,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 8.5.sp,
                          color: AppTheme.textSecondary.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 2.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isSent ? "-" : "+"}${tx.value ?? 0} RUBY',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color:
                            isSent ? AppTheme.errorRed : AppTheme.successGreen,
                      ),
                    ),
                    SizedBox(height: 0.3.h),
                    Text(
                      (tx.status == 1 ? 'Completed' : 'Pending'),
                      style: TextStyle(
                        fontSize: 8.5.sp,
                        fontWeight: FontWeight.w500,
                        color: tx.status == 1
                            ? AppTheme.successGreen
                            : AppTheme.warningOrange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    });
  }

  /// 🔁 Bottom loader widget (for pagination)
  Widget _buildBottomLoader() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Center(
        child: CircularProgressIndicator(
          color: AppTheme.accentTeal,
          strokeWidth: 2,
        ),
      ),
    );
  }
}
