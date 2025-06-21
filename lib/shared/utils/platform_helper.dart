import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';

class PlatformHelper {
  // Platform detection
  static bool get isWeb => kIsWeb;
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isMobile => isAndroid || isIOS;
  static bool get isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  static String get platformName {
    if (isWeb) return 'Web';
    if (isAndroid) return 'Android';
    if (isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }

  // Enhanced responsive helpers that consider both platform and screen size
  static bool isMobilePlatform(BuildContext context) {
    return isMobile || (isWeb && MediaQuery.of(context).size.width < 600);
  }

  static bool isTabletPlatform(BuildContext context) {
    if (isMobile) return false; // Mobile platforms are never "tablet"
    return MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1200;
  }

  static bool isDesktopPlatform(BuildContext context) {
    if (isMobile) return false; // Mobile platforms are never "desktop"
    return MediaQuery.of(context).size.width >= 1200;
  }

  // Platform-specific responsive helpers
  static bool shouldShowSidebar(BuildContext context) {
    // On mobile platforms, never show permanent sidebar
    if (isMobile) return false;

    // On web/desktop, show sidebar for tablet+ sizes
    return MediaQuery.of(context).size.width >= 900;
  }

  static bool shouldUseDrawer(BuildContext context) {
    // Only use drawer on mobile platforms or small web screens
    return isMobile || (isWeb && MediaQuery.of(context).size.width < 900);
  }

  // Platform-specific styling helpers
  static double getAppBarHeight(BuildContext context) {
    if (isWeb) return kToolbarHeight;
    if (isAndroid) return kToolbarHeight;
    if (isIOS) return kToolbarHeight + MediaQuery.of(context).padding.top;
    return kToolbarHeight;
  }

  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isMobile) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    } else if (isWeb) {
      final width = MediaQuery.of(context).size.width;
      if (width < 600) {
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      } else if (width < 1200) {
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      } else {
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
      }
    }
    return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
  }

  // Platform-specific grid configurations
  static int getGridCrossAxisCount(BuildContext context) {
    if (isMobile) return 1;

    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 1;
    if (width < 900) return 2;
    if (width < 1200) return 3;
    return 4;
  }

  // Platform-specific navigation patterns
  static NavigationPattern getNavigationPattern(BuildContext context) {
    if (isMobile) return NavigationPattern.bottomNavigation;
    if (isWeb && MediaQuery.of(context).size.width < 900) {
      return NavigationPattern.drawer;
    }
    return NavigationPattern.sidebar;
  }
}

enum NavigationPattern { bottomNavigation, drawer, sidebar }
