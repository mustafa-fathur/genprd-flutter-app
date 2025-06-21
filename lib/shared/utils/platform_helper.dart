import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:genprd/shared/responsive/responsive_layout.dart';

// Conditional import for platform detection
import 'platform_helper_io.dart'
    if (dart.library.html) 'platform_helper_web.dart';

class PlatformHelper {
  // Platform detection
  static bool get isWeb => kIsWeb;
  static bool get isAndroid => !kIsWeb && PlatformDetector.isAndroid;
  static bool get isIOS => !kIsWeb && PlatformDetector.isIOS;
  static bool get isMobile => isAndroid || isIOS;
  static bool get isDesktop =>
      !kIsWeb &&
      (PlatformDetector.isWindows ||
          PlatformDetector.isMacOS ||
          PlatformDetector.isLinux);

  static String get platformName {
    if (isWeb) return 'Web';
    if (isAndroid) return 'Android';
    if (isIOS) return 'iOS';
    if (PlatformDetector.isWindows) return 'Windows';
    if (PlatformDetector.isMacOS) return 'macOS';
    if (PlatformDetector.isLinux) return 'Linux';
    return 'Unknown';
  }

  // Enhanced responsive helpers that consider both platform and screen size
  static bool isMobilePlatform(BuildContext context) {
    return isMobile || (isWeb && MediaQuery.of(context).size.width < 600);
  }

  static bool isTabletPlatform(BuildContext context) {
    return ResponsiveLayout.isTablet(context);
  }

  static bool isDesktopPlatform(BuildContext context) {
    return ResponsiveLayout.isDesktop(context);
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
    if (isMobilePlatform(context)) {
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
    if (isDesktopPlatform(context)) {
      return 3;
    } else if (isTabletPlatform(context)) {
      return 2;
    } else {
      return 2;
    }
  }

  static double getChildAspectRatio(BuildContext context) {
    if (isDesktopPlatform(context)) {
      return 2.2;
    } else if (isTabletPlatform(context)) {
      return 1.8;
    } else {
      return 1.6;
    }
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
