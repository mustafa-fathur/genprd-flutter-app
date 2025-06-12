import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import 'token_storage.dart';
import '../../features/auth/services/auth_service.dart';
import '../utils/logout_helper.dart';
import 'package:flutter/material.dart';

class ApiInterceptor {
  final AuthService _authService;
  bool _isRefreshing = false;
  final _queue = <Future Function()>[];

  // Context for navigation
  final BuildContext? context;

  ApiInterceptor(this._authService, {this.context});

  Future<http.Response> interceptRequest(
    Future<http.Response> Function() request,
  ) async {
    try {
      // Check if token is expired
      if (await TokenStorage.isTokenExpired()) {
        debugPrint('Token is expired, attempting to refresh...');
        return await _handleTokenRefresh(request);
      }

      // Make the request
      final response = await request();

      // If we get a 401, try to refresh the token
      if (response.statusCode == 401) {
        debugPrint('Received 401, attempting to refresh token...');
        return await _handleTokenRefresh(request);
      }

      return response;
    } catch (e) {
      debugPrint('Error in API interceptor: $e');
      rethrow;
    }
  }

  Future<http.Response> _handleTokenRefresh(
    Future<http.Response> Function() request,
  ) async {
    if (_isRefreshing) {
      return await _queueRequest(request);
    }

    _isRefreshing = true;
    int refreshAttempts = 0;
    const maxRefreshAttempts = 3;

    try {
      while (refreshAttempts < maxRefreshAttempts) {
        final success = await _authService.refreshToken();
        if (success) {
          // Process queued requests
          while (_queue.isNotEmpty) {
            final queuedRequest = _queue.removeAt(0);
            await queuedRequest();
          }
          return await request();
        }
        refreshAttempts++;
      }

      // If refresh token fails after max attempts, force logout
      debugPrint(
        'Token refresh failed after $maxRefreshAttempts attempts, forcing logout',
      );
      await TokenStorage.clearTokens();

      if (context != null) {
        // Navigate directly to login instead of session expired screen
        await LogoutHelper.logout(context!);
      }

      throw Exception(
        'Token refresh failed after $maxRefreshAttempts attempts. You have been logged out.',
      );
    } finally {
      _isRefreshing = false;
    }
  }

  Future<http.Response> _queueRequest(
    Future<http.Response> Function() request,
  ) async {
    final completer = Completer<http.Response>();

    _queue.add(() async {
      try {
        final response = await request();
        completer.complete(response);
      } catch (e) {
        completer.completeError(e);
      }
    });

    return completer.future;
  }
}
