import 'package:cryptovault_pro/models/responses/token_list_response.dart';
import '../constants/api_constants.dart';
import '../servieces/api_service.dart';

class TokenListRepository {
  final _dio = ApiService.dio;

  Future<TokenListResponse> getTokenlist(String wallerAddress) async {
    final response = await _dio.get(
      ApiConstants.getTokenlistUrl(wallerAddress)
    );
    return TokenListResponse.fromJson(response.data);
  }
}
