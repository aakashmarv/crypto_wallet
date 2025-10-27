import 'package:cryptovault_pro/utils/snackbar_util.dart';
import 'package:get/get.dart';
import '../../../viewmodels/token_list_controller.dart';
import '../../../utils/logger.dart';
import '../repositories/import_token_repository.dart';

class ImportTokenController extends GetxController {
  final ImportTokenRepository _repository = ImportTokenRepository();

  /// Observables
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  final TokenListController tokenListController = Get.find<TokenListController>();

  Future<void> importToken({
    required String walletAddress,
    required String contractAddress,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _repository.getTransationHistory(walletAddress, contractAddress);
      if (response.status == true) {
        await _fetchUpdatedTokenList();
      } else {
        final message = response.msg ?? "Failed to import token.";
        SnackbarUtil.showError("Error", message);
      }
    } catch (e, stack) {
      appLog("❌ ImportTokenController Error: $e\n$stack");
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchUpdatedTokenList() async {
    try {
      await tokenListController.getTokenList();
    } catch (e) {
      appLog("⚠️ Failed to refresh token list: $e");
    }
  }
}
