import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:genprd/shared/config/api_config.dart';
import 'package:genprd/shared/services/token_storage.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message (Status code: $statusCode)';
}

class ApiClient {
  final http.Client _client = http.Client();
  
  // Add authentication headers if required
  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (requiresAuth) {
      final token = await TokenStorage.getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    
    return headers;
  }
  
  // GET request
  Future<dynamic> get(String endpoint, {
    Map<String, dynamic>? queryParams,
    bool requiresAuth = true,
  }) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final uri = Uri.parse(ApiConfig.baseUrl + endpoint)
          .replace(queryParameters: queryParams);
      
      debugPrint('GET $uri');
      final response = await _client.get(
        uri,
        headers: headers,
      ).timeout(Duration(milliseconds: ApiConfig.connectionTimeout));
      
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      throw ApiException('Error occurred: ${e.toString()}');
    }
  }
  
  // POST request
  Future<dynamic> post(String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParams,
    bool requiresAuth = true,
  }) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final uri = Uri.parse(ApiConfig.baseUrl + endpoint)
          .replace(queryParameters: queryParams);
      
      debugPrint('POST $uri');
      if (body != null) debugPrint('Body: ${jsonEncode(body)}');
      
      final response = await _client.post(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(Duration(milliseconds: ApiConfig.connectionTimeout));
      
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      throw ApiException('Error occurred: ${e.toString()}');
    }
  }
  
  // Helper to handle API responses
  dynamic _handleResponse(http.Response response) {
    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');
    
    final dynamic body = response.body.isNotEmpty 
        ? jsonDecode(response.body) 
        : null;
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else if (response.statusCode == 401) {
      throw ApiException('Unauthorized', statusCode: response.statusCode, data: body);
    } else if (response.statusCode == 404) {
      throw ApiException('Resource not found', statusCode: response.statusCode, data: body);
    } else {
      throw ApiException(
        body != null && body['message'] != null 
            ? body['message'] 
            : 'Request failed with status ${response.statusCode}',
        statusCode: response.statusCode,
        data: body,
      );
    }
  }
}