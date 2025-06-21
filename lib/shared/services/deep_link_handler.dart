import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:genprd/shared/config/api_config.dart';
import 'package:genprd/features/auth/controllers/auth_provider.dart';
import 'package:genprd/shared/config/routes/app_router.dart';

class DeepLinkHandler {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;
  bool _initialUriHandled = false;

  late final AuthProvider _authProvider;

  void init(AuthProvider authProvider) {
    _authProvider = authProvider;
    debugPrint('Initializing deep links handler');
  }

  // Handle incoming links while app is running
  void handleIncomingLinks() {
    _subscription = _appLinks.uriLinkStream.listen((uri) {
      debugPrint('Got app link while app was running: ${uri.toString()}');
      _handleDeepLink(uri);
    }, onError: (e) => debugPrint('Deep link error: $e'));
  }

  // Handle initial link if app was opened from a deep link
  Future<void> handleInitialLink() async {
    if (!_initialUriHandled) {
      _initialUriHandled = true;
      try {
        final initialUri = await _appLinks.getInitialLink();
        if (initialUri != null) {
          debugPrint('Got initial link: ${initialUri.toString()}');
          await _handleDeepLink(initialUri);
        }
      } catch (e) {
        debugPrint('Error getting initial link: $e');
      }
    }
  }

  Future<void> _handleDeepLink(Uri uri) async {
    try {
      debugPrint('Processing deep link: $uri');

      final isWebCallback =
          uri.path == AppRouter.authCallback &&
          uri.queryParameters.containsKey('token');
      final isMobileCallback = uri.scheme == ApiConfig.appScheme;

      if (isWebCallback || isMobileCallback) {
        final params = uri.queryParameters;
        debugPrint('Auth callback params: $params');
        await _authProvider.processAuthCallback(params);
      }
    } catch (e) {
      debugPrint('Error handling deep link: $e');
    }
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
