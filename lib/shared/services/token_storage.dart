import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  // SharedPreferences keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _tokenExpiryKey = 'token_expiry';

  // Save access token with expiry
  static Future<void> saveAccessToken(
    String token, {
    DateTime? expiresAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
    if (expiresAt != null) {
      await prefs.setString(_tokenExpiryKey, expiresAt.toIso8601String());
    }
  }

  // Save refresh token
  static Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
  }

  // Save user data
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, jsonEncode(userData));
  }

  // Get access token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // Get refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  // Get token expiry
  static Future<DateTime?> getTokenExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryStr = prefs.getString(_tokenExpiryKey);
    if (expiryStr == null) return null;
    return DateTime.parse(expiryStr);
  }

  // Check if token is expired
  static Future<bool> isTokenExpired() async {
    final expiry = await getTokenExpiry();
    if (expiry == null) return true;
    return DateTime.now().isAfter(expiry);
  }

  // Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userDataKey);
    if (userJson == null) return null;
    return jsonDecode(userJson) as Map<String, dynamic>;
  }

  // Clear all tokens
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userDataKey);
    await prefs.remove(_tokenExpiryKey);
  }
}
