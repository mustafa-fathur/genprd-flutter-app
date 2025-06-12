class ApiConfig {
  // Base URLs for different environments
  static const String _devBaseUrl = 'http://10.0.2.2:3000/api';
  static const String _prodBaseUrl =
      'https://express-backend-418864732285.asia-southeast2.run.app/api';

  // Set this to true to use the deployed backend
  static const bool _useProduction = false;

  // The active base URL determined by environment
  static String get baseUrl => _useProduction ? _prodBaseUrl : _devBaseUrl;

  // Auth endpoints
  static const String googleAuthMobile = '/auth/mobile/google';
  static const String googleAuthVerify = '/auth/verify-google-token';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';

  // User endpoints
  static const String userProfile = '/users/profile';
  static const String updateUserProfile = '/users/profile';

  // Deep link configurations
  static const String appScheme = 'genprd';
  static const String callbackHost = 'auth';
  static const String callbackPath = '/callback';
  // Fixed format for deep link callback - proper URL format
  static const String callbackUrl = '$appScheme://$callbackHost$callbackPath';

  // Timeout durations (in milliseconds)
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
}
