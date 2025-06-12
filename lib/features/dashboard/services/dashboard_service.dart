import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:genprd/features/dashboard/models/dashboard_data.dart';
import 'package:genprd/shared/config/api_config.dart';
import 'package:genprd/shared/services/api_interceptor.dart';
import 'package:genprd/shared/services/token_storage.dart';
import 'package:genprd/features/auth/services/auth_service.dart';

class DashboardService {
  final AuthService _authService = AuthService();
  late ApiInterceptor _apiInterceptor;

  DashboardService() {
    _apiInterceptor = ApiInterceptor(_authService);
  }

  Future<DashboardData> getDashboardData() async {
    try {
      final token = await TokenStorage.getAccessToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await _apiInterceptor.interceptRequest(() async {
        final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.dashboard}');
        return await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        debugPrint('Dashboard data fetched successfully');

        if (responseData['status'] == 'success' &&
            responseData['data'] != null) {
          return DashboardData.fromJson(responseData['data']);
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception(
          'Failed to fetch dashboard data: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching dashboard data: $e');
      rethrow;
    }
  }
}
