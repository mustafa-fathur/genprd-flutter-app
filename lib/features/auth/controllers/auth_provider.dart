import 'package:flutter/foundation.dart';
import 'package:genprd/features/auth/services/auth_service.dart';
import 'package:genprd/features/user/models/user_model.dart';
import '../models/auth_credentials.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  authenticating,
  error,
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  // State variables
  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;

  // Getters
  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // Set status with logging
  void _setStatus(AuthStatus newStatus) {
    debugPrint('Auth status changing from $_status to $newStatus');
    _status = newStatus;
  }

  // Initialize authentication state
  Future<void> initAuth() async {
    if (_status == AuthStatus.authenticating) return;

    try {
      debugPrint('Initializing authentication state...');
      final isAuth = await _authService.isAuthenticated();

      if (isAuth) {
        _setStatus(AuthStatus.authenticated);
        _user = await _authService.getUserProfile();
        debugPrint('User is authenticated: ${_user?.email}');
      } else {
        _setStatus(AuthStatus.unauthenticated);
        _user = null;
        debugPrint('User is not authenticated');
      }
    } catch (e) {
      _setStatus(AuthStatus.error);
      _errorMessage = e.toString();
      debugPrint('Auth initialization error: $e');
    }

    notifyListeners();
  }

  // Web flow Google sign-in
  Future<void> signInWithGoogle() async {
    if (_status == AuthStatus.authenticating) return;

    try {
      _setStatus(AuthStatus.authenticating);
      _errorMessage = null;
      notifyListeners();

      await _authService.signInWithGoogle();
      debugPrint('Google sign-in URL launched successfully');

      // Note: Autentikasi sebenarnya terjadi setelah callback OAuth
    } catch (e) {
      _setStatus(AuthStatus.error);
      _errorMessage = e.toString();
      notifyListeners();
      debugPrint('Sign in error: $e');
    }
  }

  // Native Google sign-in
  Future<void> signInWithGoogleNative() async {
    if (_status == AuthStatus.authenticating) return;

    try {
      debugPrint('Starting Google Native sign-in process...');
      _setStatus(AuthStatus.authenticating);
      _errorMessage = null;
      notifyListeners();

      await _authService.signInWithGoogleNative();

      // Get user after successful authentication
      _user = await _authService.getUserProfile();
      _setStatus(AuthStatus.authenticated);
      debugPrint(
        'Native Google sign-in completed successfully, user: ${_user?.email}',
      );

      // Add a small delay before notifying listeners to ensure navigation works properly
      await Future.delayed(const Duration(milliseconds: 100));

      if (_user != null) {
        await _sendFcmTokenIfNeeded();
      }
    } catch (e) {
      debugPrint('Native sign in error: $e');
      _setStatus(AuthStatus.error);
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  // Process OAuth callback
  Future<bool> processAuthCallback(Map<String, String> params) async {
    try {
      debugPrint('Processing auth callback with params: $params');
      _setStatus(AuthStatus.authenticating);
      _errorMessage = null;
      notifyListeners();

      _user = await _authService.processAuthCallback(params);

      if (_user != null) {
        _setStatus(AuthStatus.authenticated);
        debugPrint(
          'Authentication successful via callback, user: ${_user?.email}',
        );
        await _sendFcmTokenIfNeeded();
        notifyListeners();
        return true;
      } else {
        _setStatus(AuthStatus.unauthenticated);
        debugPrint('Authentication failed via callback');
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Auth callback processing error: $e');
      _setStatus(AuthStatus.error);
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _authService.logout();
      _setStatus(AuthStatus.unauthenticated);
      _user = null;
      _errorMessage = null;
      debugPrint('User logged out successfully');
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Logout error: $e');
    }

    notifyListeners();
  }

  // Force logout (used when token is invalid)
  Future<void> forceLogout() async {
    debugPrint('Force logout called');

    try {
      // Clear tokens first
      await _authService.logout();
      debugPrint('Force logout: tokens cleared');
    } catch (e) {
      debugPrint('Force logout: error clearing tokens: $e');
      // Continue even if token clearing fails
    }

    // Update state regardless of token clearing success
    _setStatus(AuthStatus.unauthenticated);
    _user = null;
    _errorMessage = null;

    debugPrint('Force logout: state updated to unauthenticated');

    // Notify listeners immediately
    notifyListeners();
  }

  // Conventional Auth Methods
  Future<void> register(String email, String password, String name) async {
    if (_status == AuthStatus.authenticating) return;

    try {
      _setStatus(AuthStatus.authenticating);
      _errorMessage = null;
      notifyListeners();

      final credentials = AuthCredentials(
        email: email,
        password: password,
        name: name,
      );

      _user = await _authService.register(credentials);

      if (_user != null) {
        _setStatus(AuthStatus.authenticated);
        debugPrint('Registration successful, user: ${_user?.email}');
        await _sendFcmTokenIfNeeded();
      } else {
        _setStatus(AuthStatus.error);
        _errorMessage = 'Registration failed: Unknown error';
        debugPrint('Registration failed: Unknown error');
      }
    } catch (e) {
      _setStatus(AuthStatus.error);

      // Clean up error message for display
      String errorMsg = e.toString();
      if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.substring('Exception: '.length);
      }

      _errorMessage = errorMsg;
      debugPrint('Registration error: $e');
    }

    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    if (_status == AuthStatus.authenticating) return;

    try {
      _setStatus(AuthStatus.authenticating);
      _errorMessage = null;
      notifyListeners();

      final credentials = AuthCredentials(email: email, password: password);

      _user = await _authService.login(credentials);

      if (_user != null) {
        _setStatus(AuthStatus.authenticated);
        debugPrint('Login successful, user: ${_user?.email}');
        await _sendFcmTokenIfNeeded();
      } else {
        _setStatus(AuthStatus.error);
        _errorMessage = 'Invalid email or password';
        debugPrint('Login failed: Invalid email or password');
      }
    } catch (e) {
      _setStatus(AuthStatus.error);
      _errorMessage = e.toString();
      debugPrint('Login error: $e');
    }

    notifyListeners();
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _authService.forgotPassword(email);
      debugPrint('Password reset email sent');
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Forgot password error: $e');
      notifyListeners();
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await _authService.resetPassword(token, newPassword);
      debugPrint('Password reset successful');
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Reset password error: $e');
      notifyListeners();
    }
  }

  // Helper to send FCM token to backend
  Future<void> _sendFcmTokenIfNeeded() async {
    debugPrint('[_sendFcmTokenIfNeeded] Called');
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      debugPrint('[_sendFcmTokenIfNeeded] Got FCM token: $fcmToken');
      if (fcmToken != null) {
        await _authService.updateFcmToken(fcmToken);
        debugPrint('[_sendFcmTokenIfNeeded] Sent FCM token to backend');
      }
    } catch (e) {
      debugPrint('[_sendFcmTokenIfNeeded] Error: $e');
    }
  }
}
