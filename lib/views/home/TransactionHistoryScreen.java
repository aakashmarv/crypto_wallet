class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  int _currentPage = 1;
  final int _pageSize = 20;

  List<Map<String, dynamic>> _transactions = [];
  String? _walletAddress;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 🧭 Scroll listener for pagination
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100 &&
        !_isLoadingMore &&
        _hasMore &&
        !_isLoading) {
      _loadMoreTransactions();
    }
  }

  /// 🚀 Load initial transactions (first page)
  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _transactions.clear();
      _hasMore = true;
    });

    await _fetchTransactions(page: _currentPage);
  }

  /// ➕ Load next page transactions
  Future<void> _loadMoreTransactions() async {
    setState(() => _isLoadingMore = true);
    _currentPage++;
    await _fetchTransactions(page: _currentPage);
    setState(() => _isLoadingMore = false);
  }

  /// 🌐 Fetch data from Ruby Explorer API using Dio
  Future<void> _fetchTransactions({required int page}) async {
    final prefs = await SharedPreferencesService.getInstance();
    final address = prefs.getString(AppKeys.walletAddress);
    _walletAddress = address;

    if (address == null || address.isEmpty) {
      debugPrint("⚠️ No wallet address found");
      setState(() => _isLoading = false);
      return;
    }

    try {
      debugPrint("🌐 Fetching transactions for: $address (page: $page)");

      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Accept': 'application/json'},
      ));

      final url = "https://rubyexplorer.com/api/getTransction/$address/$page/$_pageSize";
      final response = await dio.get(url);

      if (response.statusCode == 200 && response.data["status"] == true) {
        final result = List<Map<String, dynamic>>.from(response.data["result"]);

        if (result.isEmpty) {
          _hasMore = false;
          setState(() => _isLoading = false);
          return;
        }

        final newTxs = result.map((tx) {
          final value = tx["value"] ?? tx["otherDetails"]?[0]?["coinTransfer"]?["value"] ?? 0;
          final from = tx["from"];
          final to = tx["to"];
          final hash = tx["hash"];
          final status = tx["status"] == 1 ? "success" : "pending";

          DateTime createdAt = DateTime.tryParse(tx["createdAt"] ?? "") ?? DateTime.now();

          return {
            "hash": hash,
            "from": from,
            "to": to,
            "value": value.toString(),
            "timestamp": createdAt.millisecondsSinceEpoch ~/ 1000,
            "status": status,
          };
        }).toList();

        setState(() {
          _transactions.addAll(newTxs);
          _isLoading = false;
          _hasMore = result.length == _pageSize;
        });

        debugPrint("✅ Page $page loaded → total: ${_transactions.length}");
      } else {
        debugPrint("⚠️ API invalid response: ${response.data}");
        setState(() => _isLoading = false);
      }
    } catch (e, st) {
      debugPrint("❌ Transaction fetch error: $e");
      debugPrint(st.toString());
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

  /// 🧩 Shimmer while loading
  Widget _buildShimmerList() {
    return ListView.builder(
      itemCount: 6,
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
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      itemCount: _transactions.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _transactions.length) {
          return _buildBottomLoader();
        }

        final tx = _transactions[index];
        final isSent = tx['from'].toString().toLowerCase() == _walletAddress?.toLowerCase();
        final formattedDate = DateFormat('dd MMM yyyy, hh:mm a')
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
                      '${tx['hash'].toString().substring(0, 10)}...${tx['hash'].toString().substring(tx['hash'].length - 6)}',
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
                    '${isSent ? "-" : "+"}${tx['value']} RUBY',
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
