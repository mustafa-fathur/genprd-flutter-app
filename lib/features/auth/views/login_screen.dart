import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:genprd/features/auth/controllers/auth_provider.dart';
import 'package:genprd/features/dashboard/views/dashboard_screen.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:genprd/shared/config/themes/app_theme.dart';
import 'package:flutter/foundation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLogin = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Check if already authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated) {
        _navigateToDashboard();
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _errorMessage = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      debugPrint('Starting Google sign-in process...');

      // First attempt: Try native sign in
      try {
        debugPrint('Attempting native Google Sign In...');
        await authProvider.signInWithGoogleNative();

        if (authProvider.isAuthenticated && mounted) {
          debugPrint('Native sign in successful, navigating to dashboard');
          _navigateToDashboard();
          return;
        } else {
          debugPrint('Native sign in did not result in authenticated state');
        }
      } catch (nativeError) {
        debugPrint('Native sign in failed with error: $nativeError');

        // Don't show error yet, we'll try web flow first
        if (nativeError.toString().contains('PlatformException') ||
            nativeError.toString().contains('ApiException: 10') ||
            nativeError.toString().contains('MissingPluginException')) {
          debugPrint('Detected known error in native flow, trying web flow...');
        }
      }

      // Second attempt: Try web flow
      try {
        debugPrint('Falling back to web flow authentication...');
        await authProvider.signInWithGoogle();
        debugPrint('Web flow URL launched successfully');

        // Show a snackbar to inform user about the redirect
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please complete sign in in your browser'),
              duration: Duration(seconds: 5),
            ),
          );
        }
      } catch (webError) {
        debugPrint('Web flow sign in also failed: $webError');
        setState(() {
          _errorMessage = 'Sign in failed: $webError';
        });
      }
    } catch (e) {
      debugPrint('Unexpected error during sign in process: $e');
      setState(() {
        _errorMessage = 'Sign in error: $e';
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      setState(() {
        _errorMessage = null;
      });

      if (_isLogin) {
        await authProvider.login(
          _emailController.text,
          _passwordController.text,
        );
      } else {
        await authProvider.register(
          _emailController.text,
          _passwordController.text,
          _nameController.text,
        );
      }

      if (authProvider.isAuthenticated && mounted) {
        _navigateToDashboard();
      } else if (mounted && authProvider.errorMessage != null) {
        setState(() {
          _errorMessage = authProvider.errorMessage;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          // Remove "Exception: " prefix for cleaner error messages
          if (_errorMessage != null &&
              _errorMessage!.startsWith("Exception: ")) {
            _errorMessage = _errorMessage!.substring("Exception: ".length);
          }
        });
      }
    }
  }

  void _navigateToDashboard() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

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
                      'assets/images/logo.png',
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
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isLogin ? 'Welcome Back' : 'Create Account',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isLogin
                              ? 'Sign in to continue'
                              : 'Create an account to get started',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        // Display error if present
                        if (_errorMessage != null ||
                            authProvider.errorMessage != null)
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
                                _errorMessage ??
                                    authProvider.errorMessage ??
                                    '',
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),

                        if (!_isLogin) ...[
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        if (authProvider.status == AuthStatus.authenticating)
                          const CircularProgressIndicator()
                        else
                          Column(
                            children: [
                              ElevatedButton(
                                onPressed: _submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppTheme.primaryColor,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  minimumSize: const Size(double.infinity, 54),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  _isLogin ? 'Sign In' : 'Register',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'OR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
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
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppTheme.primaryColor,
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
                            ],
                          ),
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin;
                              _errorMessage = null;
                            });
                          },
                          child: Text(
                            _isLogin
                                ? 'Don\'t have an account? Register'
                                : 'Already have an account? Sign In',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        if (_isLogin) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'Forgot Password?',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                        const SizedBox(height: 24),
                        Text(
                          'By signing in, you agree to our Terms of Service and Privacy Policy',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimary.withAlpha(178),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
