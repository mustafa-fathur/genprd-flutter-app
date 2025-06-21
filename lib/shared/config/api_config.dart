import 'package:genprd/shared/services/token_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // Base URLs for different environments
  static String get _devBaseUrl =>
      dotenv.env['DEV_API_URL'] ?? 'http://localhost:3000/api';
  static String get _prodBaseUrl =>
      dotenv.env['PROD_API_URL'] ??
      'https://express-backend-418864732285.asia-southeast2.run.app/api';

  // Set this to true to use the deployed backend
  static const bool _useProduction = false;

  // The active base URL determined by environment
  static String get baseUrl => _useProduction ? _prodBaseUrl : _devBaseUrl;

  // Auth endpoints
  static const String googleAuthMobile = '/auth/mobile/google';
  static const String googleAuthWeb = '/auth/web/google';
  static const String googleAuthVerify = '/auth/verify-google-token';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';

  // User endpoints
  static const String userProfile = '/users/profile';
  static const String updateUserProfile = '/users/profile';

  // Dashboard endpoints
  static const String dashboard = '/dashboard';

  // Deep link configurations
  static const String appScheme = 'genprd';
  static const String callbackHost = 'auth';
  static const String callbackPath = '/callback';
  // Fixed format for deep link callback - proper URL format
  static const String callbackUrl = '$appScheme://$callbackHost$callbackPath';

  // Timeout durations (in milliseconds)
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Get headers for API requests
  static Future<Map<String, String>> getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Get token from storage
    final token = await TokenStorage.getAccessToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }
}
