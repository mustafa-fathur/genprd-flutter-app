import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:genprd/features/auth/controllers/auth_provider.dart';
import 'package:genprd/shared/config/routes/app_router.dart';
import 'package:genprd/shared/config/themes/app_theme.dart';
import 'package:genprd/shared/utils/platform_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Check authentication status after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndNavigate();
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    // Add a small delay to show the splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // On non-web platforms, check if onboarding should be shown first.
    if (!PlatformHelper.isWeb) {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
      if (!hasSeenOnboarding) {
        _navigateToOnboarding();
        return;
      }
    }

    // For web, or for other platforms after onboarding, navigate based on auth status.
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Navigate based on auth status
    if (authProvider.status == AuthStatus.authenticated) {
      _navigateToDashboard();
    } else if (authProvider.status == AuthStatus.unauthenticated ||
        authProvider.status == AuthStatus.error) {
      _navigateToLogin();
    } else {
      // If still in initial or authenticating state, wait for the provider to update
      authProvider.addListener(_authStateListener);
    }
  }

  void _authStateListener() {
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Remove listener once we've determined the auth state
    if (authProvider.status == AuthStatus.authenticated) {
      authProvider.removeListener(_authStateListener);
      _navigateToDashboard();
    } else if (authProvider.status == AuthStatus.unauthenticated ||
        authProvider.status == AuthStatus.error) {
      authProvider.removeListener(_authStateListener);
      _navigateToLogin();
    }
  }

  void _navigateToDashboard() {
    if (!mounted) return;
    context.go(AppRouter.dashboard);
  }

  void _navigateToLogin() {
    if (!mounted) return;
    context.go(AppRouter.login);
  }

  void _navigateToOnboarding() {
    if (!mounted) return;
    // Use GoRouter with the constant from AppRouter
    context.go(AppRouter.onboarding);
  }

  @override
  void dispose() {
    // Clean up listener if it's still active
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.removeListener(_authStateListener);
    } catch (e) {
      // Ignore errors during disposal
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo container with shadow
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(60),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 40),
            // App name
            Text(
              'GenPRD',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Tagline
            Text(
              'Product Requirements Made Simple',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withAlpha(220),
              ),
            ),
            const SizedBox(height: 60),
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
