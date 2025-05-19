import 'package:flutter/material.dart';
import 'package:genprd/shared/config/themes/app_theme.dart';
import 'package:genprd/shared/views/splash_screen.dart';
// import 'package:genprd/shared/views/dashboard_screen.dart'; // Remove DashboardScreen import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GenPRD',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}