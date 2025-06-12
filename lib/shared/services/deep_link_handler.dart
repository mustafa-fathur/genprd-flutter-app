import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:app_links/app_links.dart';
import 'package:genprd/shared/config/api_config.dart';

typedef AuthCallbackHandler = void Function(Map<String, String> params);

class DeepLinkHandler {
  static final AppLinks _appLinks = AppLinks();
  static StreamSubscription<Uri>? _subscription;
  static bool _initialUriHandled = false;

  static Future<void> init(AuthCallbackHandler onAuthCallback) async {
    // Handle initial URI when app is launched from a deep link
    if (!_initialUriHandled) {
      _initialUriHandled = true;
      try {
        // Perubahan ini untuk mengatasi perubahan API di package app_links
        final initialUri = await _appLinks.getInitialLink();
        if (initialUri != null) {
          debugPrint('Got initial link: ${initialUri.toString()}');
          _handleDeepLink(initialUri, onAuthCallback);
        }
      } catch (e) {
        debugPrint('Error getting initial link: $e');
      }
    }

    // Listen for deep link changes while the app is running
    _subscription = _appLinks.uriLinkStream.listen((uri) {
      debugPrint('Got app link while app was running: ${uri.toString()}');
      _handleDeepLink(uri, onAuthCallback);
    }, onError: (e) => debugPrint('Deep link error: $e'));
  }

  static void _handleDeepLink(Uri uri, AuthCallbackHandler onAuthCallback) {
    try {
      debugPrint('Processing deep link: $uri');
      // Cek apakah ini adalah callback auth
      if (uri.scheme == ApiConfig.appScheme) {
        // Parse query parameters
        final params = uri.queryParameters;
        debugPrint('Deep link params: $params');
        onAuthCallback(params);
      }
    } catch (e) {
      debugPrint('Error handling deep link: $e');
    }
  }

  static void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
