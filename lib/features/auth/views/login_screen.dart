import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:genprd/features/auth/controllers/auth_provider.dart';
import 'package:genprd/features/dashboard/views/dashboard_screen.dart';
import 'package:genprd/shared/widgets/loading_widget.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:genprd/shared/config/themes/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Check if already authenticated on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated) {
        _navigateToDashboard();
      }
    });
  }

  Future<void> _signInWithGoogle() async {
    try {
      setState(() {
        _errorMessage = null;
      });
      
      // Get auth provider and initiate Google sign-in
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signInWithGoogle();
      
      // The navigation will happen automatically when the auth callback is processed
      // through the deep link handler, or manually if needed
      if (authProvider.isAuthenticated && mounted) {
        _navigateToDashboard();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Sign in failed: ${e.toString()}';
      });
    }
  }

  void _navigateToDashboard() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardScreen())
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth provider for state changes
    final authProvider = Provider.of<AuthProvider>(context);
    final bool isLoading = authProvider.status == AuthStatus.authenticating;
    
    // Use error message from provider or local state
    final errorMsg = authProvider.errorMessage ?? _errorMessage;

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Column(
        children: [
          // Wave section with white logo background
          ClipPath(
            clipper: WaveClipperTwo(),
            child: Container(
              color: Colors.white,
              width: double.infinity,
              height: 340,
              child: Center(
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset(
                      'assets/images/genprd_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Login content on light blue background
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome to GenPRD',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Sign in with your Google account to continue',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    
                    // Display error if present
                    if (errorMsg != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withAlpha(40),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red),
                          ),
                          child: Text(
                            errorMsg,
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 24),
                    isLoading
                        ? const LoadingWidget()
                        : ElevatedButton.icon(
                            onPressed: _signInWithGoogle,
                            icon: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 16,
                              child: Image.asset(
                                'assets/images/google_logo.png',
                                height: 20.0,
                              ),
                            ),
                            label: Text(
                              'Sign in with Google',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.onPrimary,
                              foregroundColor: Theme.of(context).colorScheme.primary,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 24,
                              ),
                              minimumSize: const Size(double.infinity, 54),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                    const SizedBox(height: 24),
                    Text(
                      'By signing in, you agree to our Terms of Service and Privacy Policy',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary.withAlpha(178),
                          ),
                      textAlign: TextAlign.center,
                    ),
                    
                    // Debug option for development - remove in production
                    const SizedBox(height: 48),
                    Text(
                      'Developer options',
                      style: TextStyle(
                        color: Colors.white.withAlpha(128), 
                        fontSize: 12
                      ),
                    ),
                    TextButton(
                      onPressed: _navigateToDashboard,
                      child: Text(
                        'Skip authentication (dev only)',
                        style: TextStyle(
                          color: Colors.white.withAlpha(128), 
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}