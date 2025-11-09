import 'package:cryptovault_pro/repositories/transaction_history_repository.dart';
import 'package:get/get.dart';
import '../constants/app_keys.dart';
import '../models/responses/transaction_history_response.dart';
import '../servieces/sharedpreferences_service.dart';
import '../utils/helper_util.dart';
import '../utils/logger.dart';
import '../utils/snackbar_util.dart';

class TransactionHistoryController extends GetxController {
  final TransactionHistoryRepository _repository = TransactionHistoryRepository();

  /// Observables
  var isLoading = false.obs;
  var transactions = <Transaction>[].obs;
  var totalTransactions = 0.obs;
  var currentPage = 1.obs;
  final int _pageSize = 20;

  /// Fetch transaction history
  Future<void> getTransactionHistory({int page = 1}) async {
    try {
      isLoading.value = true;

      // 🔹 Get wallet address from SharedPreferences
      final prefs = await SharedPreferencesService.getInstance();
      final address = prefs.getString(AppKeys.walletAddress);

      if (address == null || address.isEmpty) {
        HelperUtil.toast("Wallet address not found.");
        isLoading.value = false;
        return;
      }

      // 🔹 Fetch from repository
      final response = await _repository.getTransationHistory(address, page, _pageSize);

      if (response.status == true && response.result != null) {
        if (page == 1) {
          transactions.value = response.result!;
        } else {
          transactions.addAll(response.result!);
        }

        // trxLength is now double? → safely convert to int
        totalTransactions.value = (response.trxLength ?? transactions.length.toDouble()).toInt();
        currentPage.value = page;

        appLog("✅ Transactions fetched successfully (${transactions.length} total)");
      } else {
        if (page == 1) transactions.clear();
        HelperUtil.toast( "No transactions found.");
      }
    } catch (e, st) {
      HelperUtil.toast("Something went wrong while fetching transactions.");
      appLog("❌ Transaction fetch error: $e\n$st");
    } finally {
      isLoading.value = false;
    }
  }

  /// Load more transactions (for pagination)
  Future<void> loadMoreTransactions() async {
    if (isLoading.value) return;
    await getTransactionHistory(page: currentPage.value + 1);
  }

  /// Refresh list manually
  Future<void> refreshTransactions() async {
    await getTransactionHistory(page: 1);
  }
}

