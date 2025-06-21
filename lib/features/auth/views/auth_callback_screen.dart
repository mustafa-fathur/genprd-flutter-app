import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:genprd/features/auth/controllers/auth_provider.dart';
import 'package:genprd/shared/config/routes/app_router.dart';

class AuthCallbackScreen extends StatefulWidget {
  const AuthCallbackScreen({super.key});

  @override
  State<AuthCallbackScreen> createState() => _AuthCallbackScreenState();
}

class _AuthCallbackScreenState extends State<AuthCallbackScreen> {
  @override
  void initState() {
    super.initState();
    // Defer the execution until after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processCallback();
    });
  }

  Future<void> _processCallback() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Using GoRouterState.of(context) might be problematic if context is not ready.
    // A more robust way is to get the current route information differently if issues arise.
    // However, for this case, it should be fine within addPostFrameCallback.
    final queryParams = GoRouterState.of(context).uri.queryParameters;

    if (queryParams.isNotEmpty) {
      final success = await authProvider.processAuthCallback(queryParams);
      if (mounted) {
        if (success) {
          context.go(AppRouter.dashboard);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text('Authentication failed. Please try again.'),
            ),
          );
          context.go(AppRouter.login);
        }
      }
    } else {
      if (mounted) {
        // No params, something went wrong, redirect to login
        context.go(AppRouter.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 24),
            Text(
              'Processing authentication, please wait...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
