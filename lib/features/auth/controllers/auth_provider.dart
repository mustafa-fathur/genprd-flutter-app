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
      final isAuth = await _authService.isAuthenticated();
      
      if (isAuth) {
        _status = AuthStatus.authenticated;
        _user = await _authService.getUserProfile();
      } else {
        _status = AuthStatus.unauthenticated;
        _user = null;
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      debugPrint('Auth initialization error: $e');
    }
    
    notifyListeners();
  }
  
  // Sign in with Google
  Future<void> signInWithGoogle() async {
    if (_status == AuthStatus.authenticating) return;
    
    try {
      _status = AuthStatus.authenticating;
      _errorMessage = null;
      notifyListeners();
      
      await _authService.signInWithGoogle();
      
      // Note: Actual authentication completion happens when 
      // the OAuth callback is processed via processAuthCallback
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      debugPrint('Sign in error: $e');
    }
  }
  
  // Process OAuth callback
  Future<void> processAuthCallback(Map<String, String> params) async {
    try {
      _status = AuthStatus.authenticating;
      _errorMessage = null;
      notifyListeners();
      
      _user = await _authService.processAuthCallback(params);
      _status = AuthStatus.authenticated;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      debugPrint('Auth callback processing error: $e');
    }
    
    notifyListeners();
  }
  
  // Logout the user
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
  
  // Clear any error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}