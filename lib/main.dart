import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:genprd/features/auth/controllers/auth_provider.dart';
import 'package:genprd/shared/config/themes/app_theme.dart';
import 'package:genprd/shared/views/splash_screen.dart';
import 'package:genprd/shared/services/deep_link_handler.dart';

void main() {
  // Ensure Flutter is initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Create AuthProvider instance that will be shared throughout the app
  final AuthProvider _authProvider = AuthProvider();

  @override
  void initState() {
    super.initState();

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
    // Provide AuthProvider to the entire app
    return ChangeNotifierProvider.value(
      value: _authProvider,
      child: MaterialApp(
        title: 'GenPRD',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
