import 'package:cryptovault_pro/servieces/sharedpreferences_service.dart';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../constants/app_keys.dart';
import '../utils/logger.dart';

class ApiService {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
    ),
  )..interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Load token from SharedPreferences
        final prefs = await SharedPreferencesService.getInstance();
        final token = prefs.getString(AppKeys.token);

        // Add Bearer token if available
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          appLog("🔐 Bearer Token attached");
        }

        appLog("📤 REQUEST → ${options.method} ${options.uri}");
        appLog("🔸 Headers: ${options.headers}");
        appLog("🔸 Data: ${options.data}");

        return handler.next(options);
      },

      onResponse: (response, handler) {
        appLog("✅ RESPONSE ← ${response.statusCode} ${response.requestOptions.uri}");
        appLog("📦 Response Data: ${response.data}");
        return handler.next(response);
      },

      onError: (DioException e, handler) {
        appLog("❌ ERROR ← ${e.response?.statusCode} ${e.requestOptions.uri}");
        appLog("🧯 Message: ${e.message}");
        appLog("📦 Error Data: ${e.response?.data}");
        return handler.next(e);
      },
    ),
  );
}
