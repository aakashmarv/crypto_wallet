import 'package:cryptovault_pro/models/responses/transaction_history_response.dart';
import '../constants/api_constants.dart';
import '../servieces/api_service.dart';

class TransactionHistoryRepository {
  final _dio = ApiService.dio;

  Future<TransactionHistoryResponse> getTransationHistory(String address, int page, int pageSize) async {
    final response = await _dio.get(
        ApiConstants.getTransactionUrl(address,page,pageSize)
    );
    return TransactionHistoryResponse.fromJson(response.data);
  }
}