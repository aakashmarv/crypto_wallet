import 'package:get/get.dart';
import '../constants/api_constants.dart';
import '../constants/app_keys.dart';
import '../repositories/coin_repository.dart';
import '../servieces/sharedpreferences_service.dart';
import '../utils/helper_util.dart';
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
    _initAndFetch();
  }
  Future<void> _initAndFetch() async {
    // Load saved network before first fetch
    final prefs = await SharedPreferencesService.getInstance();
    final selected = prefs.getString(AppKeys.selectedNetwork) ?? "ruby";
    ApiConstants.setNetwork(selected == "testnet");
    appLog("🌐 Network applied on startup coin controller → $selected");
    await fetchCoinPrice();
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
        HelperUtil.toast( "Failed to fetch coin price.");
        appLog("⚠️ Invalid response or missing result.");
      }
    } catch (e, st) {
      HelperUtil.toast( "Something went wrong while fetching price.");
      appLog("❌ Coin price fetch error: $e\n$st");
    } finally {
      isLoading.value = false;
    }
  }
}
