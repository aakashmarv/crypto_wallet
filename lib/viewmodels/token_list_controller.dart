import 'package:cryptovault_pro/utils/snackbar_util.dart';
import 'package:get/get.dart';
import 'package:cryptovault_pro/constants/app_keys.dart';
import '../models/responses/token_list_response.dart';
import '../repositories/token_list_repository.dart';
import '../servieces/sharedpreferences_service.dart';
import '../utils/helper_util.dart';
import '../utils/logger.dart';

class TokenListController extends GetxController {
  final TokenListRepository _repository = TokenListRepository();

  /// Observables
  var isLoading = false.obs;
  var tokenList = <TokenInfo>[].obs;
  var walletBalance = ''.obs;
  var walletAddress = ''.obs;
  var latestBlock = 0.obs;

  /// Fetch token list
  Future<void> getTokenList() async {
    try {
      isLoading.value = true;

      // 🔹 Get wallet address from shared prefs
      final prefs = await SharedPreferencesService.getInstance();
      final address = prefs.getString(AppKeys.walletAddress);

      if (address == null || address.isEmpty) {
        SnackbarUtil.showError("Error", "Wallet address not found.");
        isLoading.value = false;
        return;
      }

      final response = await _repository.getTokenlist(address);

      if (response.status == true) {
        if (response.token != null && response.token!.isNotEmpty) {
          tokenList.value = response.token!;
          walletBalance.value = response.balance ?? "0";
          latestBlock.value = response.latestBlock ?? 0;
          appLog("✅ Token list fetched successfully (${tokenList.length} tokens)");
        } else {
          tokenList.clear();
          SnackbarUtil.showError("Info", "No tokens found for this wallet.");
        }
      } else {
        SnackbarUtil.showError("Error", "Failed to fetch token list. Please try again.");
      }
    } catch (e, st) {
      SnackbarUtil.showError("Error", "Something went wrong while fetching token list.");
      appLog("❌ Token list fetch error: $e\n$st");
    } finally {
      isLoading.value = false;
    }
  }
}
