import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:genprd/features/auth/views/login_screen.dart';
import 'package:genprd/features/auth/views/auth_callback_screen.dart';
import 'package:genprd/features/dashboard/views/dashboard_screen.dart';
import 'package:genprd/features/prd/views/prd_detail_screen.dart';
import 'package:genprd/features/prd/views/prd_form_screen.dart';
import 'package:genprd/features/prd/views/prd_list_screen.dart';
import 'package:genprd/features/user/views/user_profile_screen.dart';
import 'package:genprd/shared/views/session_expired_screen.dart';
import 'package:genprd/shared/views/splash_screen.dart';
import 'package:genprd/shared/views/onboarding_screen.dart';

class AppRouter {
  // Route paths
  static const String splash = '/splash';
  static const String login = '/login';
  static const String authCallback = '/auth/callback';
  static const String dashboard = '/dashboard';
  static const String allPrds = '/prds';
  static const String pinnedPrds = '/prds/pinned';
  static const String recentPrds = '/prds/recent';
  static const String prdDetail = '/prds/:id';
  static const String createPrd = '/prds/create';
  static const String userProfile = '/profile';
  static const String sessionExpired = '/session-expired';
  static const String onboarding = '/onboarding';
  static const String root = '/';

  // Screen builder methods for use in unified router
  static Widget buildSplashScreen() => const SplashScreen();
  static Widget buildLoginScreen() => const LoginScreen();
  static Widget buildAuthCallbackScreen() => const AuthCallbackScreen();
  static Widget buildDashboardScreen() => const DashboardScreen();
  static Widget buildSessionExpiredScreen() => const SessionExpiredScreen();
  static Widget buildAllPrdsScreen() => const PrdListScreen();
  static Widget buildPinnedPrdsScreen() => const PrdListScreen();
  static Widget buildRecentPrdsScreen() => const PrdListScreen();
  static Widget buildCreatePrdScreen() => const PrdFormScreen();
  static Widget buildUserProfileScreen() => const UserProfileScreen();
  static Widget buildOnboardingScreen() => const OnboardingScreen();
  static Widget buildPrdDetailScreen(String prdId) =>
      PrdDetailScreen(prdId: prdId);

  static GoRouter get router => _router;

  // Private router instance
  static final _router = GoRouter(
    initialLocation: root,
    debugLogDiagnostics: true,
    routes: [
      // Root route redirects to splash
      GoRoute(
        path: root,
        redirect: (_, __) {
          debugPrint('Redirecting from root to splash screen');
          return splash;
        },
      ),
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) {
          debugPrint('Building splash screen');
          return buildSplashScreen();
        },
      ),
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) {
          debugPrint('Building login screen');
          return buildLoginScreen();
        },
      ),
      GoRoute(
        path: authCallback,
        name: 'authCallback',
        builder: (context, state) {
          debugPrint('Building auth callback screen');
          return buildAuthCallbackScreen();
        },
      ),
      GoRoute(
        path: onboarding,
        name: 'onboarding',
        builder: (context, state) {
          debugPrint('Building onboarding screen');
          return buildOnboardingScreen();
        },
      ),
      GoRoute(
        path: dashboard,
        name: 'dashboard',
        builder: (context, state) {
          debugPrint('Building dashboard screen');
          return buildDashboardScreen();
        },
      ),
      GoRoute(
        path: allPrds,
        name: 'allPrds',
        builder: (context, state) {
          debugPrint('Building all PRDs screen');
          return buildAllPrdsScreen();
        },
      ),
      GoRoute(
        path: pinnedPrds,
        name: 'pinnedPrds',
        builder: (context, state) {
          debugPrint('Building pinned PRDs screen');
          return buildPinnedPrdsScreen();
        },
      ),
      GoRoute(
        path: recentPrds,
        name: 'recentPrds',
        builder: (context, state) {
          debugPrint('Building recent PRDs screen');
          return buildRecentPrdsScreen();
        },
      ),
      GoRoute(
        path: createPrd,
        name: 'createPrd',
        builder: (context, state) {
          debugPrint('Building create PRD screen');
          return buildCreatePrdScreen();
        },
      ),
      GoRoute(
        path: userProfile,
        name: 'userProfile',
        builder: (context, state) {
          debugPrint('Building user profile screen');
          return buildUserProfileScreen();
        },
      ),
      GoRoute(
        path: sessionExpired,
        name: 'sessionExpired',
        builder: (context, state) {
          debugPrint('Building session expired screen');
          return buildSessionExpiredScreen();
        },
      ),
      GoRoute(
        path: '/prds/:id',
        name: 'prdDetail',
        builder: (context, state) {
          final prdId = state.pathParameters['id'] ?? '1';
          debugPrint('Building PRD detail screen for ID: $prdId');
          return buildPrdDetailScreen(prdId);
        },
      ),
    ],
    errorBuilder: (context, state) {
      debugPrint('Navigation error: ${state.error}');
      debugPrint('Attempted path: ${state.uri.path}');

      return Scaffold(
        appBar: AppBar(
          title: const Text('Navigation Error'),
          backgroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Route not found: ${state.uri.path}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.go(login),
                child: const Text('Go to Login'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => context.go(dashboard),
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
        ),
      );
    },
    redirect: (BuildContext context, GoRouterState state) {
      debugPrint('Navigation request to: ${state.uri.path}');
      return null; // No redirect needed
    },
  );

  // Navigation helper methods
  static void navigateToDashboard(BuildContext context) {
    debugPrint('Navigating to dashboard: $dashboard');
    context.go(dashboard);
  }

  static void navigateToAllPrds(BuildContext context) {
    debugPrint('Navigating to all PRDs: $allPrds');
    context.push(allPrds);
  }

  static void navigateToPinnedPrds(BuildContext context) {
    debugPrint('Navigating to pinned PRDs: $pinnedPrds');
    context.push(pinnedPrds);
  }

  static void navigateToRecentPrds(BuildContext context) {
    debugPrint('Navigating to recent PRDs: $recentPrds');
    context.push(recentPrds);
  }

  static void navigateToPrdDetail(BuildContext context, String prdId) {
    final path = '/prds/$prdId';
    debugPrint('Navigating to PRD detail: $path');
    context.push(path);
  }

  static void navigateToCreatePrd(BuildContext context) {
    debugPrint('Navigating to create PRD: $createPrd');
    context.push(createPrd);
  }

  static void navigateToUserProfile(BuildContext context) {
    debugPrint('Navigating to user profile: $userProfile');
    context.push(userProfile);
  }

  static void navigateToLogin(BuildContext context) {
    debugPrint('Navigating to login: $login');

    // Use go to clear the navigation stack and prevent back navigation
    try {
      context.go(login);
      debugPrint('Successfully navigated to login screen');
    } catch (e) {
      debugPrint('Error navigating to login: $e');
    }
  }

  static void navigateToSessionExpired(BuildContext context) {
    debugPrint('Navigating to session expired: $sessionExpired');
    context.go(sessionExpired);
  }

  static void navigateToOnboarding(BuildContext context) {
    debugPrint('Navigating to onboarding: $onboarding');
    context.go(onboarding);
  }
}
