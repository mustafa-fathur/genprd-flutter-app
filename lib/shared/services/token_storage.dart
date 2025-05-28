import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  // SharedPreferences keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';

  // Save access token
  static Future<bool> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_accessTokenKey, token);
  }

  // Get access token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // Save refresh token
  static Future<bool> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_refreshTokenKey, token);
  }

  // Get refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  // Save user data
  static Future<bool> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_userDataKey, jsonEncode(userData));
  }

  // Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userDataKey);
    if (userDataString == null) {
      return null;
    }
    return jsonDecode(userDataString) as Map<String, dynamic>;
  }

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // Clear all auth data (logout)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userDataKey);
  }
}