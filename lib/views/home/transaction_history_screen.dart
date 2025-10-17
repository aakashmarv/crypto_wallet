import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import '../../constants/app_keys.dart';
import '../../servieces/sharedpreferences_service.dart';
import '../../theme/app_theme.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _transactions = [];
  String? _walletAddress;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);

    final prefs = await SharedPreferencesService.getInstance();
    final address = prefs.getString(AppKeys.walletAddress);
    _walletAddress = address;

    if (address != null) {
      try {
        // ✅ Fetch transactions dynamically (via API or local service)
        // final txs = await TransactionService().fetchTransactions(address);

        await Future.delayed(const Duration(seconds: 1));
        final txs = [
          {
            'hash': '0xabc1234567890abcdef',
            'from': address,
            'to': '0x9876543210fedcba',
            'value': '0.015',
            'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
            'status': 'success',
          },
          {
            'hash': '0xdef1234567890abc987',
            'from': '0x9876543210fedcba',
            'to': address,
            'value': '0.250',
            'timestamp': DateTime.now().subtract(const Duration(hours: 5)).millisecondsSinceEpoch ~/ 1000,
            'status': 'success',
          },
        ];

        setState(() {
          _transactions = txs;
          _isLoading = false;
        });
      } catch (e) {
        debugPrint("Transaction fetch error: $e");
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
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
        backgroundColor: AppTheme.primaryDark,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.textPrimary),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadTransactions,
          color: AppTheme.accentTeal,
          child: _isLoading
              ? _buildShimmerList()
              : _transactions.isEmpty
              ? _buildEmptyState()
              : _buildTransactionList(),
        ),
      ),
    );
  }

  /// 🧩 Shimmer effect for loading
  Widget _buildShimmerList() {
    return ListView.builder(
      itemCount: 8,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      itemBuilder: (_, i) => Container(
        margin: EdgeInsets.only(bottom: 2.h),
        height: 10.h,
        decoration: BoxDecoration(
          color: AppTheme.accentTherd.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  /// 🧩 Empty state widget
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

  /// 🧩 Transaction list builder
  Widget _buildTransactionList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final tx = _transactions[index];
        final bool isSent = tx['from'].toString().toLowerCase() == _walletAddress?.toLowerCase();
        final String formattedDate = DateFormat('dd MMM yyyy, hh:mm a')
            .format(DateTime.fromMillisecondsSinceEpoch(tx['timestamp'] * 1000));

        return Container(
          margin: EdgeInsets.only(bottom: 1.8.h),
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: AppTheme.secondaryDark.withOpacity(0.15),
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
                  isSent ? Icons.call_made_rounded : Icons.call_received_rounded,
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
                      '${tx['hash'].toString().substring(0, 12)}...${tx['hash'].toString().substring(tx['hash'].length - 6)}',
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
                    '${isSent ? "-" : "+"}${tx['value']} ETH',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: isSent ? AppTheme.errorRed : AppTheme.successGreen,
                    ),
                  ),
                  SizedBox(height: 0.3.h),
                  Text(
                    tx['status'] == 'success' ? 'Completed' : 'Pending',
                    style: TextStyle(
                      fontSize: 8.5.sp,
                      fontWeight: FontWeight.w500,
                      color: tx['status'] == 'success'
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
  }
}
