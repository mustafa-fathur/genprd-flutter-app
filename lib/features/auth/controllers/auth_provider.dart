import 'package:flutter/foundation.dart';
import 'package:genprd/features/auth/services/auth_service.dart';
import 'package:genprd/features/user/models/user_model.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  authenticating,
  error
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
  
  // Initialize authentication state
  Future<void> initAuth() async {
    if (_status == AuthStatus.authenticating) return;
    
    try {
      debugPrint('Initializing authentication state...');
      final isAuth = await _authService.isAuthenticated();
      
      if (isAuth) {
        _status = AuthStatus.authenticated;
        _user = await _authService.getUserProfile();
        debugPrint('User is authenticated: ${_user?.email}');
      } else {
        _status = AuthStatus.unauthenticated;
        _user = null;
        debugPrint('User is not authenticated');
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      debugPrint('Auth initialization error: $e');
    }
    
    notifyListeners();
  }
  
  // Web flow Google sign-in
  Future<void> signInWithGoogle() async {
    if (_status == AuthStatus.authenticating) return;
    
    try {
      _status = AuthStatus.authenticating;
      _errorMessage = null;
      notifyListeners();
      
      await _authService.signInWithGoogle();
      debugPrint('Google sign-in URL launched successfully');
      
      // Note: Autentikasi sebenarnya terjadi setelah callback OAuth
    } catch (e) {
      _status = AuthStatus.error;
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
      _status = AuthStatus.authenticating;
      _errorMessage = null;
      notifyListeners();
      
      await _authService.signInWithGoogleNative();
      
      // Get user after successful authentication
      _user = await _authService.getUserProfile();
      _status = AuthStatus.authenticated;
      
      debugPrint('Native Google sign-in completed successfully');
      
    } catch (e) {
      debugPrint('Native sign in error: $e');
      _status = AuthStatus.error;
      _errorMessage = e.toString();
    }
    
    notifyListeners();
  }
    // Process OAuth callback
  Future<bool> processAuthCallback(Map<String, String> params) async {
    try {
      debugPrint('Processing auth callback with params: $params');
      _status = AuthStatus.authenticating;
      _errorMessage = null;
      notifyListeners();
      
      _user = await _authService.processAuthCallback(params);
      
      if (_user != null) {
        _status = AuthStatus.authenticated;
        debugPrint('Authentication successful via callback');
        notifyListeners();
        return true;
      } else {
        _status = AuthStatus.unauthenticated;
        debugPrint('Authentication failed via callback');
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Auth callback processing error: $e');
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Logout
  Future<void> logout() async {
    try {
      await _authService.logout();
      _status = AuthStatus.unauthenticated;
      _user = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Logout error: $e');
    }
    
    notifyListeners();
  }
}