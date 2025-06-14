import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:genprd/shared/config/api_config.dart';
import 'package:genprd/shared/services/api_interceptor.dart';
import 'package:genprd/features/auth/services/auth_service.dart';
import 'package:genprd/features/prd/models/prd_model.dart';

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

  // Create a new PRD
  Future<Map<String, dynamic>> createPrd(Map<String, dynamic> prdData) async {
    try {
      debugPrint('Creating new PRD with data: ${jsonEncode(prdData)}');
      final response = await _apiInterceptor.interceptRequest(() async {
        return await http.post(
          Uri.parse('${ApiConfig.baseUrl}/prd'),
          headers: {
            ...await ApiConfig.getHeaders(),
            'Content-Type': 'application/json',
          },
          body: jsonEncode(prdData),
        );
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        debugPrint('PRD created successfully: ${response.statusCode}');
        return responseData['data'] ?? {};
      } else {
        debugPrint(
          'Failed to create PRD: ${response.statusCode} - ${response.body}',
        );
        throw Exception('Failed to create PRD: ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Error creating PRD: $e');
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
            allPrds.where((prd) => prd['is_pinned'] == true).toList();
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
  Future<List<dynamic>> getRecentPrds() async {
    try {
      final response = await _apiInterceptor.interceptRequest(() async {
        return await http.get(
          Uri.parse('${ApiConfig.baseUrl}/prd/recent'),
          headers: await ApiConfig.getHeaders(),
        );
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['data'] ?? [];
      } else {
        throw Exception('Failed to load recent PRDs: ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Error fetching recent PRDs: $e');
      rethrow;
    }
  }

  // Get PRD by ID
  Future<PrdModel> getPrdById(String id) async {
    try {
      final response = await _apiInterceptor.interceptRequest(() async {
        return await http.get(
          Uri.parse('${ApiConfig.baseUrl}/prd/$id'),
          headers: await ApiConfig.getHeaders(),
        );
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final prdData = responseData['data'] ?? {};
        return PrdModel.fromJson(prdData);
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

  // Archive or unarchive a PRD
  Future<Map<String, dynamic>> archivePrd(String id) async {
    try {
      final response = await _apiInterceptor.interceptRequest(() async {
        return await http.patch(
          Uri.parse('${ApiConfig.baseUrl}/prd/$id/archive'),
          headers: await ApiConfig.getHeaders(),
        );
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['data'] ?? {};
      } else {
        throw Exception('Failed to archive PRD: ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Error archiving PRD: $e');
      rethrow;
    }
  }

  // Delete a PRD
  Future<bool> deletePrd(String id) async {
    try {
      final response = await _apiInterceptor.interceptRequest(() async {
        return await http.delete(
          Uri.parse('${ApiConfig.baseUrl}/prd/$id'),
          headers: await ApiConfig.getHeaders(),
        );
      });

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete PRD: ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Error deleting PRD: $e');
      rethrow;
    }
  }

  // Update PRD stage
  Future<Map<String, dynamic>> updatePrdStage(String id, String stage) async {
    try {
      debugPrint('Updating PRD stage to: $stage for ID: $id');
      final response = await _apiInterceptor.interceptRequest(() async {
        return await http.patch(
          Uri.parse('${ApiConfig.baseUrl}/prd/$id/stage'),
          headers: {
            ...await ApiConfig.getHeaders(),
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'stage': stage}),
        );
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        debugPrint('Stage update response: ${response.body}');
        return responseData['data'] ?? {};
      } else {
        debugPrint(
          'Failed to update stage: ${response.statusCode} - ${response.body}',
        );
        throw Exception('Failed to update PRD stage: ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Error updating PRD stage: $e');
      rethrow;
    }
  }

  // Download PRD
  Future<Map<String, dynamic>> downloadPrd(String id) async {
    try {
      final response = await _apiInterceptor.interceptRequest(() async {
        return await http.get(
          Uri.parse('${ApiConfig.baseUrl}/prd/$id/download'),
          headers: await ApiConfig.getHeaders(),
        );
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['data'] ?? {};
      } else {
        throw Exception('Failed to download PRD: ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Error downloading PRD: $e');
      rethrow;
    }
  }
}
