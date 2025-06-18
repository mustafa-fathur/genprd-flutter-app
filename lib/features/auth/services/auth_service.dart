import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:genprd/shared/config/api_config.dart';
import 'package:genprd/shared/services/token_storage.dart';
import 'package:genprd/features/user/models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../models/auth_credentials.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // clientId tidak bekerja di Android, gunakan serverClientId
    serverClientId:
        '418864732285-cj9knn4bngfn1ra00j32t5njanfvtebg.apps.googleusercontent.com',
  ); // Sign in with Google OAuth URL Launcher
  Future<void> signInWithGoogle() async {
    try {
      // The backend initiates the Google OAuth flow, and it will handle the redirect_uri to Google.
      // After Google auth, the backend will redirect to our app's deep link (ApiConfig.callbackUrl).
      final googleAuthInitiationUrl =
          '${ApiConfig.baseUrl}${ApiConfig.googleAuthMobile}';
      final uri = Uri.parse(googleAuthInitiationUrl);

      debugPrint(
        'Opening Backend Google Auth Initiation URL: $googleAuthInitiationUrl',
      );
      debugPrint('Expected app callback URL: ${ApiConfig.callbackUrl}');

      // Log diagnostic info about URL launching
      await _logUrlLaunchDetails(uri);

      // First attempt with inAppWebView (keeps the user in the app)
      try {
        if (await canLaunchUrl(uri)) {
          final launched = await launchUrl(
            uri,
            mode: LaunchMode.inAppWebView,
            webOnlyWindowName: '_self',
            webViewConfiguration: const WebViewConfiguration(
              enableJavaScript: true,
              enableDomStorage: true,
            ),
          );

          if (launched) {
            debugPrint('URL launched successfully with inAppWebView mode');
            return;
          }
        }
      } catch (e) {
        debugPrint('Error launching with inAppWebView: $e');
      }

      // Second attempt with externalApplication (opens in system browser)
      try {
        if (await canLaunchUrl(uri)) {
          final launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
            webOnlyWindowName: '_self',
          );

          if (launched) {
            debugPrint(
              'URL launched successfully with externalApplication mode',
            );
            return;
          }
        }
      } catch (e) {
        debugPrint('Error launching with externalApplication: $e');
      }

      // Last resort: platformDefault
      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
          webOnlyWindowName: '_self',
        );

        if (!launched) {
          throw Exception(
            'All URL launch attempts failed for: $googleAuthInitiationUrl',
          );
        }
      } else {
        // If the URL can't be launched, try a direct API call
        debugPrint('Cannot launch URL, attempting direct API call');
        await _tryDirectNativeSignIn();
      }
    } catch (e) {
      debugPrint('Error launching Google Auth: $e');
      rethrow;
    }
  }

  // Helper method to attempt direct native sign-in as a fallback
  Future<void> _tryDirectNativeSignIn() async {
    try {
      await signInWithGoogleNative();
    } catch (e) {
      debugPrint('Direct native sign-in also failed: $e');
      throw Exception(
        'All authentication methods failed. Please check your internet connection and try again.',
      );
    }
  }

  // Sign in with native Google Sign In
  Future<void> signInWithGoogleNative() async {
    try {
      debugPrint('Starting native Google Sign In flow...');

      // [COMMENTED OUT] Make sure Google Play Services is available
      // final bool isPlayServicesAvailable = await _googleSignIn.canAccessScopes([
      //   'email',
      // ]);
      // if (!isPlayServicesAvailable) {
      //   debugPrint('Google Play Services not available, trying web fallback');
      //   await signInWithGoogle();
      //   return;
      // }

      // Sign out first to avoid inconsistent state
      await _googleSignIn.signOut();

      // Try interactive sign in
      debugPrint('Attempting interactive sign in...');
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        debugPrint('Sign in cancelled by user');
        throw Exception('Google Sign In canceled');
      }

      debugPrint(
        'Sign in successful: ${account.displayName} (${account.email})',
      );
      await _processGoogleAccount(account);
    } catch (e) {
      // Detailed error handling
      if (e.toString().contains('ApiException: 10')) {
        debugPrint(
          'Error code 10: This is a SHA-1 or package name configuration issue',
        );
        debugPrint(
          'Make sure SHA-1 and package name are registered in Google Cloud Console',
        );

        // Try web approach as fallback
        debugPrint('Trying web approach as fallback...');
        await signInWithGoogle();
        return;
      } else if (e.toString().contains('network_error') ||
          e.toString().contains('socket') ||
          e.toString().contains('connection')) {
        debugPrint('Network error detected during Google Sign In');
        throw Exception(
          'Network error. Please check your internet connection and try again.',
        );
      }

      debugPrint('Google Sign In error: $e');
      rethrow;
    }
  }

  // Helper method for processing Google account after sign in
  Future<void> _processGoogleAccount(GoogleSignInAccount account) async {
    debugPrint('Signed in as: ${account.displayName} (${account.email})');
    debugPrint('User ID: ${account.id}');

    final GoogleSignInAuthentication googleAuth = await account.authentication;

    debugPrint('Got token: ${googleAuth.accessToken != null}');

    // Send token to backend for verification
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.googleAuthVerify}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_token': googleAuth.idToken,
        'access_token': googleAuth.accessToken,
      }),
    );

    debugPrint('Backend response status: ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception('Authentication failed: ${response.body}');
    }

    // Parse response
    final responseData = jsonDecode(response.body);

    // Save authentication data
    await TokenStorage.saveAccessToken(responseData['access_token']);

    if (responseData['refresh_token'] != null) {
      await TokenStorage.saveRefreshToken(responseData['refresh_token']);
    }

    debugPrint('Authentication successful');
  }

  // Get user profile
  Future<User?> getUserProfile() async {
    try {
      // Implementasi untuk mendapatkan profil user dari backend atau local storage
      final userData = await TokenStorage.getUserData();
      if (userData == null) {
        return null;
      }

      return User.fromJson(userData);
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      final accessToken = await TokenStorage.getAccessToken();
      return accessToken != null;
    } catch (e) {
      debugPrint('Error checking authentication: $e');
      return false;
    }
  }

  // Process auth callback
  Future<User?> processAuthCallback(Map<String, String> params) async {
    try {
      debugPrint('Processing auth callback with params: $params');

      // Handle token under different possible parameter names
      String? token;
      DateTime? expiresAt;

      // Check various possible token parameter names
      final possibleTokenKeys = [
        'token',
        'access_token',
        'id_token',
        'auth_token',
      ];
      for (final key in possibleTokenKeys) {
        if (params.containsKey(key) && params[key]!.isNotEmpty) {
          token = params[key];
          debugPrint('Found token under key: $key');
          break;
        }
      }

      // Check for expiry
      if (params.containsKey('expires_in')) {
        final expiresIn = int.tryParse(params['expires_in'] ?? '');
        if (expiresIn != null) {
          expiresAt = DateTime.now().add(Duration(seconds: expiresIn));
        }
      }

      // If we found a token, save it
      if (token != null && token.isNotEmpty) {
        await TokenStorage.saveAccessToken(token, expiresAt: expiresAt);
        debugPrint('Saved access token successfully');

        // Check for refresh token under different possible names
        final possibleRefreshTokenKeys = ['refresh_token', 'refreshToken'];
        for (final key in possibleRefreshTokenKeys) {
          if (params.containsKey(key) && params[key]!.isNotEmpty) {
            await TokenStorage.saveRefreshToken(params[key]!);
            debugPrint('Saved refresh token successfully');
            break;
          }
        }

        // Handle user data under different possible parameter names
        Map<String, dynamic>? userData;

        // Try to find user data in params
        final possibleUserDataKeys = ['user_data', 'userData', 'user'];
        for (final key in possibleUserDataKeys) {
          if (params.containsKey(key) && params[key]!.isNotEmpty) {
            try {
              userData = jsonDecode(params[key]!) as Map<String, dynamic>;
              debugPrint('Found user data under key: $key');
              break;
            } catch (e) {
              debugPrint('Error parsing user data for key $key: $e');
            }
          }
        }

        // Save and return user data if we found it
        if (userData != null) {
          await TokenStorage.saveUserData(userData);
          debugPrint('Saved user data successfully');
          return User.fromJson(userData);
        }

        // If we didn't find user data in the params, fetch it from the API
        debugPrint('No user data in params, fetching profile from API');
        return await getUserProfile();
      } else {
        // If there's an error parameter, log it
        if (params.containsKey('error')) {
          debugPrint('Auth error from callback: ${params['error']}');
          if (params.containsKey('error_description')) {
            debugPrint('Error description: ${params['error_description']}');
          }
        }

        debugPrint('No valid token found in callback parameters');
        return null;
      }
    } catch (e) {
      debugPrint('Error processing auth callback: $e');
      return null;
    }
  }

  // Refresh token
  Future<bool> refreshToken() async {
    try {
      debugPrint('Attempting to refresh token...');
      final refreshToken = await TokenStorage.getRefreshToken();

      if (refreshToken == null) {
        debugPrint('No refresh token available');
        return false;
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.refreshToken}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final newAccessToken = responseData['access_token'];
        DateTime? newExpiresAt;

        if (responseData['expires_in'] != null) {
          final expiresIn = int.tryParse(responseData['expires_in'].toString());
          if (expiresIn != null) {
            newExpiresAt = DateTime.now().add(Duration(seconds: expiresIn));
          }
        }

        await TokenStorage.saveAccessToken(
          newAccessToken,
          expiresAt: newExpiresAt,
        );
        debugPrint('Token refreshed successfully');
        return true;
      } else {
        debugPrint('Token refresh failed: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      // Sign out dari Google
      await _googleSignIn.signOut();

      // Hapus token
      await TokenStorage.clearTokens();

      debugPrint('Logged out successfully');
    } catch (e) {
      debugPrint('Error during logout: $e');
      rethrow;
    }
  }

  // Diagnostic helper for URL launching
  Future<void> _logUrlLaunchDetails(Uri uri) async {
    try {
      debugPrint('==== URL LAUNCH DIAGNOSTICS ====');
      debugPrint('URL to launch: $uri');
      debugPrint('Can launch URL: ${await canLaunchUrl(uri)}');

      // Check supported URL schemes
      final schemes = [
        'http',
        'https',
        'tel',
        'mailto',
        'sms',
        'file',
        'genprd',
      ];
      for (final scheme in schemes) {
        final testUri = Uri.parse('$scheme://example.com');
        final canLaunch = await canLaunchUrl(testUri);
        debugPrint('Can launch $scheme scheme: $canLaunch');
      }

      // Check app package name
      debugPrint('Package name: com.genprd.app');

      // Check callback URL
      debugPrint('Callback URL: ${ApiConfig.callbackUrl}');
      debugPrint('Callback Host: ${ApiConfig.callbackHost}');
      debugPrint('Callback Path: ${ApiConfig.callbackPath}');

      debugPrint('================================');
    } catch (e) {
      debugPrint('Error in URL diagnostics: $e');
    }
  }

  // Conventional Auth Methods
  Future<User?> register(AuthCredentials credentials) async {
    try {
      debugPrint('Attempting registration with email: ${credentials.email}');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(credentials.toJson()),
      );

      debugPrint('Registration response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      // Accept both 200 OK and 201 Created as successful responses
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        debugPrint('Registration successful: ${response.body}');

        final data = responseData['data'];
        if (data == null) {
          debugPrint('Registration response missing data field');
          throw Exception('Registration failed: Invalid server response');
        }

        // Save tokens - with type safety
        if (data['access_token'] != null) {
          await TokenStorage.saveAccessToken(data['access_token'].toString());
        }

        if (data['refresh_token'] != null) {
          await TokenStorage.saveRefreshToken(data['refresh_token'].toString());
        }

        // Save user data
        if (data['user'] != null) {
          await TokenStorage.saveUserData(data['user']);
          debugPrint('Registration successful, user data saved');
          return User.fromJson(data['user']);
        } else {
          debugPrint('Registration response missing user data');
          throw Exception('Registration successful but user data is missing');
        }
      } else {
        // Handle error responses
        debugPrint('Registration failed with status: ${response.statusCode}');
        debugPrint('Error response: ${response.body}');

        try {
          final errorData = jsonDecode(response.body);
          final errorMessage = errorData['message'] ?? 'Registration failed';
          throw Exception(errorMessage);
        } catch (e) {
          throw Exception('Registration failed: ${response.reasonPhrase}');
        }
      }
    } catch (e) {
      debugPrint('Registration error: $e');
      rethrow;
    }
  }

  Future<User?> login(AuthCredentials credentials) async {
    try {
      debugPrint('Attempting login with email: ${credentials.email}');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(credentials.toJson()),
      );

      debugPrint('Login response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        debugPrint('Login successful: ${response.body}');

        final data = responseData['data'];
        if (data == null) {
          debugPrint('Login response missing data field');
          throw Exception('Login failed: Invalid server response');
        }

        // Save tokens with type safety
        if (data['access_token'] != null) {
          await TokenStorage.saveAccessToken(data['access_token'].toString());
        } else {
          throw Exception('Login failed: Missing access token');
        }

        if (data['refresh_token'] != null) {
          await TokenStorage.saveRefreshToken(data['refresh_token'].toString());
        }

        // Save user data
        if (data['user'] != null) {
          await TokenStorage.saveUserData(data['user']);
          debugPrint('Login successful, user data saved');
          return User.fromJson(data['user']);
        } else {
          debugPrint('Login response missing user data');
          throw Exception('Login successful but user data is missing');
        }
      } else {
        // Handle error responses
        debugPrint('Login failed with status: ${response.statusCode}');
        debugPrint('Error response: ${response.body}');

        try {
          final errorData = jsonDecode(response.body);
          final errorMessage = errorData['message'] ?? 'Login failed';
          throw Exception(errorMessage);
        } catch (e) {
          throw Exception('Login failed: ${response.reasonPhrase}');
        }
      }
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send password reset email');
      }
    } catch (e) {
      debugPrint('Forgot password error: $e');
      rethrow;
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token, 'password': newPassword}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to reset password');
      }
    } catch (e) {
      debugPrint('Reset password error: $e');
      rethrow;
    }
  }

  // Add this method to update FCM token
  Future<void> updateFcmToken(String fcmToken) async {
    debugPrint('[updateFcmToken] Called with token: $fcmToken');
    final accessToken = await TokenStorage.getAccessToken();
    debugPrint('[updateFcmToken] Got access token: $accessToken');
    if (accessToken == null) {
      debugPrint('[updateFcmToken] No access token, skipping FCM update');
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/users/fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'fcm_token': fcmToken}),
      );
      debugPrint(
        '[updateFcmToken] Response: ${response.statusCode} ${response.body}',
      );
      if (response.statusCode != 200) {
        debugPrint(
          '[updateFcmToken] Failed to update FCM token: ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('[updateFcmToken] Exception: $e');
    }
  }
}
