import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:genprd/firebase_options.dart';
import 'package:genprd/shared/services/firebase_api.dart';
import 'package:provider/provider.dart';
import 'package:genprd/features/auth/controllers/auth_provider.dart';
import 'package:genprd/features/user/controllers/user_provider.dart';
import 'package:genprd/features/dashboard/controllers/dashboard_provider.dart';
import 'package:genprd/features/prd/controllers/prd_controller.dart';
import 'package:genprd/shared/config/routes/app_router.dart';
import 'package:genprd/shared/config/themes/app_theme.dart';
import 'package:genprd/shared/services/deep_link_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // Ensure Flutter is initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseApi().initNotifications();

  // Initialize deep link handler
  final deepLinkHandler = DeepLinkHandler();
  await deepLinkHandler.initUniLinks();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => PrdController()),
      ],
      child: MyApp(deepLinkHandler: deepLinkHandler),
    ),
  );
}

class MyApp extends StatefulWidget {
  final DeepLinkHandler deepLinkHandler;

  const MyApp({super.key, required this.deepLinkHandler});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize authentication state
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initAuth();

    // Handle deep links
    widget.deepLinkHandler.handleIncomingLinks(context);
    widget.deepLinkHandler.handleInitialLink(context);
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
      routerConfig: AppRouter.router,
    );
  }
}
