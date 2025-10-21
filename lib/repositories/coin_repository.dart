import 'package:cryptovault_pro/models/responses/coin_response.dart';
import '../constants/api_constants.dart';
import '../servieces/api_service.dart';

class CoinRepository {
  final _dio = ApiService.dio;

  Future<CoinResponse> getCoin() async {
    final response = await _dio.get(
        ApiConstants.getCoinUrl
    );
    return CoinResponse.fromJson(response.data);
  }
}
