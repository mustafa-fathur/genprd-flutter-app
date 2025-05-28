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
        final initialUri = await _appLinks.getInitialLink();
        debugPrint("Deep Link - Initial URI: $initialUri");
        if (initialUri != null) {
          _handleDeepLink(initialUri, onAuthCallback);
        }
      } catch (e) {
        debugPrint("Deep Link - Error getting initial URI: $e");
      }
    }

    // Listen for deep link changes while the app is running
    _subscription = _appLinks.uriLinkStream.listen(
          (Uri uri) {
        debugPrint("Deep Link - URI received: $uri");
        _handleDeepLink(uri, onAuthCallback);
      },
      onError: (err) {
        debugPrint("Deep Link - URI stream error: $err");
      },
    );
  }

  static void _handleDeepLink(Uri uri, AuthCallbackHandler onAuthCallback) {
    try {
      debugPrint("Deep Link - Processing URI: $uri");

      if (uri.scheme == ApiConfig.appScheme &&
          uri.path.contains(ApiConfig.callbackPath)) {
        debugPrint("Deep Link - Auth callback detected");

        final params = Map<String, String>.from(uri.queryParameters);

        onAuthCallback(params);
      }
    } catch (e) {
      debugPrint("Deep Link - Error processing URI: $e");
    }
  }

  static void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
