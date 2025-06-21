import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:genprd/features/auth/controllers/auth_provider.dart';
import 'package:genprd/features/dashboard/controllers/dashboard_provider.dart';
import 'package:genprd/features/prd/controllers/prd_controller.dart';
import 'package:genprd/features/user/controllers/user_provider.dart';
import 'package:genprd/firebase_options.dart';
import 'package:genprd/shared/config/routes/app_router.dart';
import 'package:genprd/shared/config/themes/app_theme.dart';
import 'package:genprd/shared/services/deep_link_handler.dart';
import 'package:genprd/shared/services/firebase_api.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() async {
  // Use the path URL strategy for clean URLs on the web
  usePathUrlStrategy();

  // Ensure Flutter is initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  // Skip Firebase initialization on iOS
  bool useFirebase = !Platform.isIOS;
  
  if (useFirebase) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await FirebaseApi().initNotifications();
  }

  // Create providers and handlers
  final authProvider = AuthProvider();
  final deepLinkHandler = DeepLinkHandler();

  // Initialize the handler with the provider
  deepLinkHandler.init(authProvider);

  // IMPORTANT: Process the initial link *before* running the app.
  // This ensures the auth state is set correctly if the app is launched from a URL.
  await deepLinkHandler.handleInitialLink();

  // Now, initialize the auth state from storage. This is harmless if the
  // deep link already authenticated the user.
  await authProvider.initAuth();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => PrdController()),
      ],
      child: MyApp(
        deepLinkHandler: deepLinkHandler,
        authProvider: authProvider,
        useFirebase: useFirebase,
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final DeepLinkHandler deepLinkHandler;
  final AuthProvider authProvider;
  final bool useFirebase;

  const MyApp({
    super.key,
    required this.deepLinkHandler,
    required this.authProvider,
    required this.useFirebase,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Now, only set up the listener for links that come in *while the app is running*.
    widget.deepLinkHandler.handleIncomingLinks();
  }

  @override
  void dispose() {
    // Clean up deep link handler
    widget.deepLinkHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Apply Google Fonts to the theme
    final ThemeData baseTheme = AppTheme.lightTheme;
    final textTheme = GoogleFonts.interTextTheme(baseTheme.textTheme);

    final ThemeData theme = baseTheme.copyWith(
      textTheme: textTheme,
      primaryTextTheme: textTheme,
    );

    return MaterialApp.router(
      title: 'GenPRD',
      theme: theme,
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.getRouter(widget.authProvider),
    );
  }
}
