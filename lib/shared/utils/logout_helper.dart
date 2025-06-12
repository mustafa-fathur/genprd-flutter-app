import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:genprd/features/auth/controllers/auth_provider.dart';
import 'package:genprd/shared/config/routes/app_router.dart';
import 'package:genprd/shared/services/token_storage.dart';

/// Helper class for handling logout functionality consistently across the app
class LogoutHelper {
  /// Performs a logout operation and navigates to the login screen
  static Future<void> logout(BuildContext context) async {
    debugPrint('LogoutHelper: Starting logout process');

    try {
      // Clear tokens first to ensure we're logged out even if something fails
      await TokenStorage.clearTokens();
      debugPrint('LogoutHelper: Tokens cleared');

      // Update auth provider state if context is available
      if (context.mounted) {
        try {
          final authProvider = Provider.of<AuthProvider>(
            context,
            listen: false,
          );
          await authProvider.forceLogout();
          debugPrint('LogoutHelper: Auth provider state updated');
        } catch (e) {
          debugPrint('LogoutHelper: Error updating auth provider state: $e');
          // Continue even if this fails
        }
      }

      // Navigate to login screen using the simplest approach
      if (context.mounted) {
        debugPrint('LogoutHelper: Navigating to login screen');
        // Use go to clear the navigation stack
        context.go(AppRouter.login);
      }
    } catch (e) {
      debugPrint('LogoutHelper: Error during logout: $e');

      // Even if there's an error, try to navigate to login as a fallback
      if (context.mounted) {
        try {
          context.go(AppRouter.login);
        } catch (e) {
          debugPrint('LogoutHelper: Error navigating to login: $e');
        }
      }
    }
  }

  /// Handles session expiration by clearing tokens and navigating to login screen
  static Future<void> handleSessionExpired(BuildContext context) async {
    debugPrint('LogoutHelper: Handling session expiration');

    try {
      // Clear tokens from storage
      await TokenStorage.clearTokens();
      debugPrint('LogoutHelper: Tokens cleared for session expiration');

      // Get auth provider and update state
      if (context.mounted) {
        try {
          final authProvider = Provider.of<AuthProvider>(
            context,
            listen: false,
          );
          await authProvider.forceLogout();
          debugPrint(
            'LogoutHelper: Auth provider state updated for session expiration',
          );
        } catch (e) {
          debugPrint('LogoutHelper: Error updating auth provider state: $e');
          // Continue with navigation even if this fails
        }
      }

      // Add a short delay to ensure state is fully updated
      await Future.delayed(const Duration(milliseconds: 100));

      // Navigate to login screen directly instead of session expired
      if (context.mounted) {
        debugPrint('LogoutHelper: Navigating directly to login screen');

        try {
          context.go(AppRouter.login);
          debugPrint('LogoutHelper: Navigation to login completed');
        } catch (e) {
          debugPrint('LogoutHelper: Error during navigation to login: $e');

          // Fallback to Navigator if context is still valid
          if (context.mounted) {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/login', (route) => false);
            debugPrint('LogoutHelper: Fallback navigation completed');
          }
        }
      }
    } catch (e) {
      debugPrint('LogoutHelper: Error during session expiration handling: $e');
      // Final fallback
      if (context.mounted) {
        try {
          context.go(AppRouter.login);
        } catch (e2) {
          debugPrint('LogoutHelper: Error in final fallback navigation: $e2');
          if (context.mounted) {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/login', (route) => false);
          }
        }
      }
    }
  }
}
