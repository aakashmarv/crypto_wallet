import 'package:get/get.dart';

import '../repositories/coin_repository.dart';
import '../utils/logger.dart';
import '../utils/snackbar_util.dart';

class CoinPriceController extends GetxController {
  final CoinRepository _repository = CoinRepository();

  /// Observables
  var isLoading = false.obs;
  var coinPrice = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCoinPrice();
  }

  /// Fetch the coin price
  Future<void> fetchCoinPrice() async {
    try {
      isLoading.value = true;

      final response = await _repository.getCoin();

      if (response.status == true && response.result != null) {
        coinPrice.value = response.result?.price ?? 0.0;
        appLog("✅ Coin price fetched: ${coinPrice.value}");
      } else {
        SnackbarUtil.showError("Error", "Failed to fetch coin price.");
        appLog("⚠️ Invalid response or missing result.");
      }
    } catch (e, st) {
      SnackbarUtil.showError("Error", "Something went wrong while fetching price.");
      appLog("❌ Coin price fetch error: $e\n$st");
    } finally {
      isLoading.value = false;
    }
  }
}
