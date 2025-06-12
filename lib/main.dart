import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:genprd/features/auth/controllers/auth_provider.dart';
import 'package:genprd/features/user/controllers/user_provider.dart';
import 'package:genprd/shared/config/routes/app_router.dart';
import 'package:genprd/shared/config/themes/app_theme.dart';
import 'package:genprd/shared/services/deep_link_handler.dart';
import 'package:genprd/shared/services/token_storage.dart';
import 'package:go_router/go_router.dart';

void main() async {
  // Ensure Flutter is initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();

  // Check if token is valid
  final bool hasToken = await _checkToken();
  debugPrint('Initial token check: ${hasToken ? 'valid' : 'invalid'}');

  runApp(MyApp(hasValidToken: hasToken));
}

// Check if token exists and is valid
Future<bool> _checkToken() async {
  try {
    final token = await TokenStorage.getAccessToken();
    if (token == null) {
      debugPrint('No token found');
      return false;
    }

    final isExpired = await TokenStorage.isTokenExpired();
    debugPrint('Token expired: $isExpired');
    return !isExpired;
  } catch (e) {
    debugPrint('Error checking token: $e');
    return false;
  }
}

class MyApp extends StatefulWidget {
  final bool hasValidToken;

  const MyApp({super.key, this.hasValidToken = true});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Create provider instances that will be shared throughout the app
  late final AuthProvider _authProvider;
  final UserProvider _userProvider = UserProvider();

  @override
  void initState() {
    super.initState();

    // Initialize auth provider
    _authProvider = AuthProvider();

    // Check if token is valid from constructor
    if (!widget.hasValidToken) {
      debugPrint('Token is invalid, clearing tokens');
      TokenStorage.clearTokens();
    }

    // Always initialize auth and deep links
    debugPrint('Initializing authentication flow');
    // Initialize authentication state
    _authProvider.initAuth().catchError((e) {
      debugPrint('Error initializing auth: $e');
    });

    // Initialize deep link handler with error handling
    try {
      DeepLinkHandler.init((params) {
        debugPrint('Auth callback received: $params');
        _authProvider.processAuthCallback(params).catchError((e) {
          debugPrint('Error processing auth callback: $e');
        });
      });
    } catch (e) {
      debugPrint('Error initializing deep link handler: $e');
    }
  }

  @override
  void dispose() {
    // Clean up deep link handler
    DeepLinkHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Provide providers to the entire app
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider.value(value: _userProvider),
      ],
      child: MaterialApp.router(
        title: 'GenPRD',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _createRouter(),
      ),
    );
  }

  // Create a unified router that handles both normal and session expired flows
  GoRouter _createRouter() {
    debugPrint('Creating unified router');

    return GoRouter(
      initialLocation:
          widget.hasValidToken ? AppRouter.dashboard : AppRouter.login,
      debugLogDiagnostics: true,
      routes: [
        // Root route redirects to dashboard if authenticated, splash otherwise
        GoRoute(
          path: '/',
          redirect: (_, __) {
            debugPrint('Redirecting from root based on auth state');
            return widget.hasValidToken
                ? AppRouter.dashboard
                : AppRouter.splash;
          },
        ),
        GoRoute(
          path: AppRouter.splash,
          name: 'splash',
          builder: (context, state) {
            debugPrint('Building splash screen');
            return AppRouter.buildSplashScreen();
          },
        ),
        GoRoute(
          path: AppRouter.login,
          name: 'login',
          builder: (context, state) {
            debugPrint('Building login screen');
            return AppRouter.buildLoginScreen();
          },
        ),
        GoRoute(
          path: AppRouter.dashboard,
          name: 'dashboard',
          builder: (context, state) {
            debugPrint('Building dashboard screen');
            return AppRouter.buildDashboardScreen();
          },
        ),
        GoRoute(
          path: AppRouter.sessionExpired,
          name: 'sessionExpired',
          builder: (context, state) {
            debugPrint('Building session expired screen');
            return AppRouter.buildSessionExpiredScreen();
          },
        ),
        // Include all other routes from AppRouter
        GoRoute(
          path: AppRouter.allPrds,
          name: 'allPrds',
          builder: (context, state) {
            debugPrint('Building all PRDs screen');
            return AppRouter.buildAllPrdsScreen();
          },
        ),
        GoRoute(
          path: AppRouter.pinnedPrds,
          name: 'pinnedPrds',
          builder: (context, state) {
            debugPrint('Building pinned PRDs screen');
            return AppRouter.buildPinnedPrdsScreen();
          },
        ),
        GoRoute(
          path: AppRouter.recentPrds,
          name: 'recentPrds',
          builder: (context, state) {
            debugPrint('Building recent PRDs screen');
            return AppRouter.buildRecentPrdsScreen();
          },
        ),
        GoRoute(
          path: AppRouter.createPrd,
          name: 'createPrd',
          builder: (context, state) {
            debugPrint('Building create PRD screen');
            return AppRouter.buildCreatePrdScreen();
          },
        ),
        GoRoute(
          path: AppRouter.userProfile,
          name: 'userProfile',
          builder: (context, state) {
            debugPrint('Building user profile screen');
            return AppRouter.buildUserProfileScreen();
          },
        ),
        GoRoute(
          path: '/prds/:id',
          name: 'prdDetail',
          builder: (context, state) {
            final prdId = state.pathParameters['id'] ?? '1';
            debugPrint('Building PRD detail screen for ID: $prdId');
            return AppRouter.buildPrdDetailScreen(prdId);
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
                  onPressed: () => context.go(AppRouter.login),
                  child: const Text('Go to Login'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => context.go(AppRouter.dashboard),
                  child: const Text('Go to Dashboard'),
                ),
              ],
            ),
          ),
        );
      },
      redirect: (BuildContext context, GoRouterState state) {
        debugPrint('Navigation request to: ${state.uri.path}');

        // Check if user is authenticated for protected routes
        final isAuthenticated = _authProvider.isAuthenticated;
        final isGoingToLoginPage = state.matchedLocation == AppRouter.login;
        final isGoingToSessionExpired =
            state.matchedLocation == AppRouter.sessionExpired;
        final isGoingToSplash = state.matchedLocation == AppRouter.splash;

        debugPrint('Auth state during redirection check: $isAuthenticated');
        debugPrint('Current path: ${state.matchedLocation}');

        // Always allow access to login, session expired, and splash without authentication
        if (isGoingToLoginPage || isGoingToSessionExpired || isGoingToSplash) {
          // If already authenticated and trying to go to login, redirect to dashboard
          if (isAuthenticated && isGoingToLoginPage) {
            debugPrint('User already authenticated, redirecting to dashboard');
            return AppRouter.dashboard;
          }
          return null;
        }

        // Redirect to login if not authenticated and trying to access protected routes
        if (!isAuthenticated) {
          debugPrint('User not authenticated, redirecting to login');
          return AppRouter.login;
        }

        // No redirection needed for authenticated users accessing protected routes
        return null;
      },
    );
  }
}
