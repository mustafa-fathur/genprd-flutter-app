import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:genprd/shared/config/routes/app_router.dart';
import 'package:genprd/shared/config/themes/app_theme.dart';
import 'package:genprd/shared/services/token_storage.dart';

class SessionExpiredScreen extends StatelessWidget {
  const SessionExpiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 80, color: AppTheme.primaryColor),
              const SizedBox(height: 24),
              Text(
                'Session Expired',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your session has expired or is invalid. Please log in again to continue.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    // Clear tokens before navigating to login
                    await TokenStorage.clearTokens();

                    if (context.mounted) {
                      debugPrint('Session expired screen: Navigating to login');

                      // Use Future.microtask to ensure navigation happens after the current build cycle
                      Future.microtask(() {
                        try {
                          if (context.mounted) {
                            // Navigate to login screen
                            context.go(AppRouter.login);
                            debugPrint(
                              'Navigation to login completed from session expired screen',
                            );
                          }
                        } catch (e) {
                          debugPrint(
                            'Error navigating to login from session expired: $e',
                          );
                        }
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Log In Again',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
