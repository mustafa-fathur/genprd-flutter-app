import 'package:flutter/material.dart';

class AppTheme {
  // Primary brand color - dark grey as originally specified
  static const primaryColor = Color(0xFF1F2937);

  // Secondary color - a lighter shade of the primary
  static final secondaryColor = const Color(0xFF1F2937).withOpacity(0.1);

  // Background color - clean white
  static const backgroundColor = Colors.white;

  // Text colors
  static const textColor = Color(0xFF1F2937);
  static const textSecondaryColor = Color(0xFF6B7280);

  // Define badge colors with a consistent palette
  static final Map<String, Color> badgeColors = {
    'Draft': const Color(0xFFF59E0B), // Amber
    'In Progress': const Color(0xFF2563EB), // Blue
    'Finished': const Color(0xFF10B981), // Emerald
    'Archived': const Color(0xFF6B7280), // Gray
  };

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: false,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    fontFamily: 'Inter', // Will use system font if not available
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      onSurface: textColor,
      onSurfaceVariant: textSecondaryColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: primaryColor),
      titleTextStyle: TextStyle(
        color: textColor,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: textColor,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        color: textColor,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      displaySmall: TextStyle(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      headlineLarge: TextStyle(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      headlineMedium: TextStyle(
        color: textColor,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      headlineSmall: TextStyle(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        color: textColor,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(color: textColor, fontSize: 16, letterSpacing: -0.1),
      bodyMedium: TextStyle(
        color: textColor,
        fontSize: 14,
        letterSpacing: -0.1,
      ),
      bodySmall: TextStyle(color: textSecondaryColor, fontSize: 12),
      labelLarge: TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
    ),
    iconTheme: const IconThemeData(color: primaryColor, size: 24),
  );
}
