import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:genprd/features/user/models/user_model.dart';
import 'package:genprd/shared/config/api_config.dart';
import 'package:genprd/shared/services/token_storage.dart';
import 'package:http/http.dart' as http;

class UserService {
  // Get user profile from API
  Future<User?> getUserProfile() async {
    try {
      final accessToken = await TokenStorage.getAccessToken();

      if (accessToken == null) {
        debugPrint('No access token available to fetch user profile');
        return null;
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.userProfile}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      debugPrint('Get user profile response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        debugPrint('User profile retrieved successfully');

        if (responseData['data'] != null) {
          // Log the data structure
          debugPrint('User data: ${responseData['data']}');

          // Check for createdAt/created_at fields
          if (responseData['data']['created_at'] != null) {
            debugPrint(
              'Found created_at: ${responseData['data']['created_at']}',
            );
          } else if (responseData['data']['createdAt'] != null) {
            debugPrint('Found createdAt: ${responseData['data']['createdAt']}');
          } else {
            debugPrint('No creation date found in response');
          }

          // Cache user data in local storage
          await TokenStorage.saveUserData(responseData['data']);
          final user = User.fromJson(responseData['data']);
          debugPrint('Parsed user: $user, createdAt: ${user.createdAt}');
          return user;
        }
      } else {
        debugPrint('Failed to get user profile: ${response.body}');
      }

      return null;
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  // Update user profile
  Future<User?> updateUserProfile({String? name, String? email}) async {
    try {
      final accessToken = await TokenStorage.getAccessToken();

      if (accessToken == null) {
        debugPrint('No access token available to update user profile');
        return null;
      }

      final Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (email != null) updateData['email'] = email;

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.updateUserProfile}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(updateData),
      );

      debugPrint('Update user profile response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        debugPrint('User profile updated successfully');

        if (responseData['data'] != null) {
          // Update user data in local storage
          await TokenStorage.saveUserData(responseData['data']);
          return User.fromJson(responseData['data']);
        }
      } else {
        debugPrint('Failed to update user profile: ${response.body}');
      }

      return null;
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      return null;
    }
  }

  // Format member since date
  String formatMemberSince(DateTime? date) {
    if (date == null) {
      debugPrint('Member since date is null');
      return 'Unknown';
    }

    debugPrint('Formatting member since date: $date');

    // If date is within the last 30 days, show "New member"
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays < 30) {
      return 'New member';
    }

    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} ${date.year}';
  }
}
