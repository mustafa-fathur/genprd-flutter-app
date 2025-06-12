import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:genprd/shared/config/api_config.dart';
import 'package:genprd/shared/services/api_interceptor.dart';
import 'package:genprd/features/auth/services/auth_service.dart';

class PrdService {
  final ApiInterceptor _apiInterceptor;

  PrdService({ApiInterceptor? apiInterceptor})
    : _apiInterceptor = apiInterceptor ?? ApiInterceptor(AuthService());

  // Fetch all PRDs
  Future<List<dynamic>> getAllPrds() async {
    try {
      final response = await _apiInterceptor.interceptRequest(() async {
        return await http.get(
          Uri.parse('${ApiConfig.baseUrl}/prd'),
          headers: await ApiConfig.getHeaders(),
        );
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['data']['prds'] ?? [];
      } else {
        throw Exception('Failed to load PRDs: ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Error fetching PRDs: $e');
      rethrow;
    }
  }

  // Fetch pinned PRDs
  Future<List<dynamic>> getPinnedPrds() async {
    try {
      debugPrint('Fetching pinned PRDs...');
      final response = await _apiInterceptor.interceptRequest(() async {
        return await http.get(
          Uri.parse('${ApiConfig.baseUrl}/prd?all=true'),
          headers: await ApiConfig.getHeaders(),
        );
      });

      debugPrint('Pinned PRDs response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final allPrds = responseData['data']['prds'] ?? [];
        // Filter pinned PRDs
        final pinnedPrds =
            (allPrds as List).where((prd) => prd['is_pinned'] == true).toList();
        debugPrint('Found ${pinnedPrds.length} pinned PRDs');
        return pinnedPrds;
      } else {
        throw Exception('Failed to load pinned PRDs: ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Error fetching pinned PRDs: $e');
      rethrow;
    }
  }

  // Fetch recent PRDs
  Future<List<dynamic>> getRecentPrds({int limit = 5}) async {
    try {
      debugPrint('Fetching recent PRDs...');
      final response = await _apiInterceptor.interceptRequest(() async {
        return await http.get(
          Uri.parse('${ApiConfig.baseUrl}/prd?all=true'),
          headers: await ApiConfig.getHeaders(),
        );
      });

      debugPrint('Recent PRDs response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final allPrds = responseData['data']['prds'] ?? [];

        // Filter out pinned PRDs and sort by updated_at
        final unpinnedPrds =
            (allPrds as List).where((prd) => prd['is_pinned'] != true).toList();
        unpinnedPrds.sort((a, b) {
          final DateTime aDate = DateTime.parse(
            a['updated_at'] ?? DateTime.now().toIso8601String(),
          );
          final DateTime bDate = DateTime.parse(
            b['updated_at'] ?? DateTime.now().toIso8601String(),
          );
          return bDate.compareTo(aDate); // Sort by most recent first
        });

        // Take only the requested number of items
        final recentPrds = unpinnedPrds.take(limit).toList();
        debugPrint('Found ${recentPrds.length} recent PRDs');
        return recentPrds;
      } else {
        throw Exception('Failed to load recent PRDs: ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Error fetching recent PRDs: $e');
      rethrow;
    }
  }

  // Get PRD by ID
  Future<Map<String, dynamic>> getPrdById(String id) async {
    try {
      final response = await _apiInterceptor.interceptRequest(() async {
        return await http.get(
          Uri.parse('${ApiConfig.baseUrl}/prd/$id'),
          headers: await ApiConfig.getHeaders(),
        );
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['data'] ?? {};
      } else {
        throw Exception('Failed to load PRD details: ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Error fetching PRD details: $e');
      rethrow;
    }
  }

  // Toggle pin status of a PRD
  Future<bool> togglePinPrd(String id) async {
    try {
      final response = await _apiInterceptor.interceptRequest(() async {
        return await http.patch(
          Uri.parse('${ApiConfig.baseUrl}/prd/$id/pin'),
          headers: await ApiConfig.getHeaders(),
        );
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['data']['is_pinned'] ?? false;
      } else {
        throw Exception(
          'Failed to toggle pin status: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      debugPrint('Error toggling pin status: $e');
      rethrow;
    }
  }
}
