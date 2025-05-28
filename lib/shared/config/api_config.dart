class ApiConfig {
  // Base URLs for different environments
  
  // For local development with Android Emulator
  static const String _devBaseUrl = 'http://10.0.2.2:3000/api';
  
  // For local development with iOS Simulator
  // static const String _devBaseUrl = 'http://localhost:3000/api';
  
  // For physical devices using your computer's IP
  // static const String _devBaseUrl = 'http://192.168.1.X:3000/api'; // Replace X with your IP
  
  // For production
  static const String _prodBaseUrl = 'https://express-backend-418864732285.asia-southeast2.run.app/api';
  
  // Choose which URL to use - change this when deploying
  static const bool _useProduction = false;
  
  // The active base URL determined by environment
  static String get baseUrl => _useProduction ? _prodBaseUrl : _devBaseUrl;
  
  // Auth endpoints - use mobile-specific endpoints from your Express API
  static const String googleAuthMobile = '/auth/mobile/google';
  static const String googleCallbackMobile = '/auth/mobile/google/callback';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  
  // Deep link configurations
  static const String appScheme = 'genprd';
  static const String callbackPath = 'auth/callback';
  static const String callbackUrl = '$appScheme://$callbackPath';
  
  // Timeout durations
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
}