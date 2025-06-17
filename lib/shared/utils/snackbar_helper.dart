import 'package:flutter/material.dart';
import 'package:genprd/shared/config/themes/app_theme.dart';

class SnackBarHelper {
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        duration: duration,
      ),
    );
  }
}
