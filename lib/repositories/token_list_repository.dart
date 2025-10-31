import 'package:cryptovault_pro/models/responses/token_list_response.dart';
import '../constants/api_constants.dart';
import '../servieces/api_service.dart';

class TokenListRepository {
  final _dio = ApiService.dio;

  Future<TokenListResponse> getTokenlist(String walletAddress) async {
    final response = await _dio.get(
      ApiConstants.getTokenlistUrl(walletAddress),
    );
    return TokenListResponse.fromJson(response.data);
  }

  Future<bool> removeToken(String walletAddress, String contractAddress) async {
    final url =
        "https://rubyexplorer.com/api/importtokenaddress/$walletAddress/$contractAddress/remove";

    try {
      final response = await _dio.get(url);

      if (response.data is Map && response.data["status"] == true) {
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}


