import 'package:cryptovault_pro/utils/snackbar_util.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:cryptovault_pro/constants/app_keys.dart';
import '../models/responses/token_list_response.dart';
import '../repositories/token_list_repository.dart';
import '../servieces/sharedpreferences_service.dart';
import '../utils/logger.dart';

class TokenListController extends GetxController {
  final TokenListRepository _repository = TokenListRepository();

  /// Observables
  var isLoading = false.obs;
  var tokenList = <TokenInfo>[].obs;
  var nftList = <NFTInfo>[].obs;
  var walletBalance = ''.obs;
  var walletAddress = ''.obs;
  var latestBlock = 0.obs;

  @override
  void onInit() {
    super.onInit();
    getTokenList();
  }

  /// Fetch token list
  Future<void> getTokenList() async {
    try {
      isLoading.value = true;

      // 🔹 Get wallet address from shared prefs
      final prefs = await SharedPreferencesService.getInstance();
      final address = prefs.getString(AppKeys.walletAddress);

      if (address == null || address.isEmpty) {
        // SnackbarUtil.showError("Error", "Wallet address not found.");
        isLoading.value = false;
        return;
      }

      final response = await _repository.getTokenlist(address);

      if (response.status == true) {
        tokenList.value = response.token ?? [];
        nftList.value = response.nfts ?? [];
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

  Future<bool> removeToken(TokenInfo token) async {
    final prefs = await SharedPreferencesService.getInstance();
    final address = prefs.getString(AppKeys.walletAddress);

    if (address == null || token.contractAddress == null) return false;

    final success = await _repository.removeToken(address, token.contractAddress!);

    if (success) {
      Fluttertoast.showToast(msg: "${token.name ?? 'Token'} removed.");
    } else {
      Fluttertoast.showToast(msg: "Could not remove token. Try again.");
    }

    return success;
  }



}
