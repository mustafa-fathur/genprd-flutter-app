import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:genprd/shared/config/api_config.dart';
import 'package:provider/provider.dart';
import 'package:genprd/features/auth/controllers/auth_provider.dart';

class DeepLinkHandler {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;
  bool _initialUriHandled = false;

  // Initialize deep links
  Future<void> initUniLinks() async {
    try {
      debugPrint('Initializing deep links handler');
    } catch (e) {
      debugPrint('Error initializing deep links: $e');
    }
  }

  // Handle incoming links while app is running
  void handleIncomingLinks(BuildContext context) {
    _subscription = _appLinks.uriLinkStream.listen((uri) {
      debugPrint('Got app link while app was running: ${uri.toString()}');
      _handleDeepLink(context, uri);
    }, onError: (e) => debugPrint('Deep link error: $e'));
  }

  // Handle initial link if app was opened from a deep link
  Future<void> handleInitialLink(BuildContext context) async {
    if (!_initialUriHandled) {
      _initialUriHandled = true;
      try {
        final initialUri = await _appLinks.getInitialLink();
        if (initialUri != null) {
          debugPrint('Got initial link: ${initialUri.toString()}');
          _handleDeepLink(context, initialUri);
        }
      } catch (e) {
        debugPrint('Error getting initial link: $e');
      }
    }
  }

  void _handleDeepLink(BuildContext context, Uri uri) {
    try {
      debugPrint('Processing deep link: $uri');
      // Check if this is an auth callback
      if (uri.scheme == ApiConfig.appScheme) {
        // Parse query parameters
        final params = uri.queryParameters;
        debugPrint('Deep link params: $params');

        // Get auth provider and process the callback
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider.processAuthCallback(params).catchError((e) {
          debugPrint('Error processing auth callback: $e');
        });
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
