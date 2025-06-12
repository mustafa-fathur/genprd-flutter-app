import 'package:flutter/material.dart';
import 'package:genprd/features/auth/controllers/auth_provider.dart';
import 'package:genprd/features/auth/views/login_screen.dart';
import 'package:genprd/shared/services/token_storage.dart';
import 'package:provider/provider.dart';
import 'package:genprd/shared/utils/logout_helper.dart';

/// Helper class for authentication-related utilities
class AuthUtils {
  /// Check if the current user session is valid
  static Future<bool> isSessionValid(BuildContext context) async {
    try {
      // Check token validity
      final hasToken = await TokenStorage.getAccessToken() != null;
      if (!hasToken) {
        debugPrint('AuthUtils: No token found');
        return false;
      }

      final isExpired = await TokenStorage.isTokenExpired();
      if (isExpired) {
        debugPrint('AuthUtils: Token is expired');
        return false;
      }

      // Check auth provider state
      if (context.mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final isAuthenticated = authProvider.isAuthenticated;

        debugPrint(
          'AuthUtils: Auth provider authenticated state: $isAuthenticated',
        );
        return isAuthenticated;
      }

      return false;
    } catch (e) {
      debugPrint('AuthUtils: Error checking session validity: $e');
      return false;
    }
  }

  /// Handle invalid session by redirecting to session expired screen
  static Future<void> handleInvalidSession(BuildContext context) async {
    debugPrint('AuthUtils: Handling invalid session');
    await LogoutHelper.handleSessionExpired(context);
  }

  /// Refresh the user's authentication state
  static Future<bool> refreshAuthState(BuildContext context) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.initAuth();

      final isAuthenticated = authProvider.isAuthenticated;
      debugPrint(
        'AuthUtils: Auth state refreshed, authenticated: $isAuthenticated',
      );

      return isAuthenticated;
    } catch (e) {
      debugPrint('AuthUtils: Error refreshing auth state: $e');
      return false;
    }
  }

  /// Force logout the user and navigate to login screen
  static Future<void> forceLogout(BuildContext context) async {
    debugPrint('AuthUtils: Forcing logout');
    await LogoutHelper.logout(context);
  }
}
