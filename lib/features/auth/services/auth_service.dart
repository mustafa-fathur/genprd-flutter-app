import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:genprd/shared/config/api_config.dart';
import 'package:genprd/shared/services/api_client.dart';
import 'package:genprd/shared/services/token_storage.dart';
import 'package:genprd/features/user/models/user_model.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  
  // Sign in with Google OAuth
  Future<void> signInWithGoogle() async {
    try {
      // Build the Google auth URL with callback
      final encodedCallback = Uri.encodeComponent(ApiConfig.callbackUrl);
      final googleAuthUrl = '${ApiConfig.baseUrl}${ApiConfig.googleAuthMobile}?redirect_uri=$encodedCallback';
      final uri = Uri.parse(googleAuthUrl);
      
      debugPrint('Opening Google Auth URL: $googleAuthUrl');
      
      // Check if URL can be launched
      if (await canLaunchUrl(uri)) {
        // Try to launch URL in external browser
        final launched = await launchUrl(
          uri, 
          mode: LaunchMode.externalApplication,
        );
        
        if (!launched) {
          throw Exception('Could not launch Google authentication URL');
        }
      } else {
        throw Exception('Cannot handle URL: $googleAuthUrl');
      }
    } catch (e) {
      debugPrint('Error launching Google Auth: $e');
      rethrow;
    }
  }
  
  // Process OAuth callback data
  Future<User> processAuthCallback(Map<String, String> params) async {
    try {
      debugPrint('Processing auth callback with params: $params');
      
      if (params['token'] == null) {
        throw Exception('No token received in callback');
      }
      
      // Save the access token
      await TokenStorage.saveAccessToken(params['token']!);
      
      // Save refresh token if available
      if (params['refreshToken'] != null) {
        await TokenStorage.saveRefreshToken(params['refreshToken']!);
      }
      
      // Parse and save user data
      if (params['user'] != null) {
        final userData = jsonDecode(params['user']!) as Map<String, dynamic>;
        await TokenStorage.saveUserData(userData);
        return User.fromJson(userData);
      } else {
        // If user data not included in callback, fetch it from API
        final userData = await getUserProfile();
        return userData;
      }
    } catch (e) {
      debugPrint('Error processing auth callback: $e');
      await TokenStorage.clearAll(); // Clear any partial data on error
      rethrow;
    }
  }
  
  // Refresh access token
  Future<String> refreshToken() async {
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }
      
      final response = await _apiClient.post(
        ApiConfig.refreshToken,
        body: {'refreshToken': refreshToken},
        requiresAuth: false,
      );
      
      final newToken = response['token'];
      await TokenStorage.saveAccessToken(newToken);
      
      return newToken;
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      await logout(); // Logout on refresh failure
      rethrow;
    }
  }
  
  // Get current user's profile from the API
  Future<User> getUserProfile() async {
    try {
      final response = await _apiClient.get('/users/profile');
      final userData = response['user'] ?? response;
      
      // Save latest user data
      await TokenStorage.saveUserData(userData);
      
      return User.fromJson(userData);
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      rethrow;
    }
  }
  
  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await TokenStorage.isAuthenticated();
  }
  
  // Logout user
  Future<void> logout() async {
    try {
      // Call logout API if authenticated
      if (await isAuthenticated()) {
        await _apiClient.post(ApiConfig.logout);
      }
    } catch (e) {
      debugPrint('Error during logout API call: $e');
      // Continue with local logout even if API call fails
    } finally {
      // Always clear local auth data
      await TokenStorage.clearAll();
    }
  }
}