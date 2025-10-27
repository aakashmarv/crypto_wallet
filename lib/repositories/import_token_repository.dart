import 'package:cryptovault_pro/models/responses/import_token_address_response.dart';
import '../constants/api_constants.dart';
import '../servieces/api_service.dart';

class ImportTokenRepository {
  final _dio = ApiService.dio;

  Future<ImportTokenAddressResponse> getTransationHistory(String walletAddress, String contractAddress) async {
    final response = await _dio.get(
        ApiConstants.getImportTokenAddress(walletAddress,contractAddress)
    );
    return ImportTokenAddressResponse.fromJson(response.data);
  }
}