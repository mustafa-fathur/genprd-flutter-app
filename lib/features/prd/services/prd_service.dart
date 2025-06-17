import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:genprd/shared/config/api_config.dart';
import 'package:genprd/shared/services/api_interceptor.dart';
import 'package:genprd/features/auth/services/auth_service.dart';
import 'package:genprd/features/prd/models/prd_model.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
class PrdService {
  final ApiInterceptor _apiInterceptor;
  final Dio _dio = Dio();
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
          body: jsonEncode({'document_stage': stage}),
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
      // Request permission untuk storage
      if (await _requestStoragePermission()) {
        final response = await _apiInterceptor.interceptRequest(() async {
          return await http.get(
            Uri.parse('${ApiConfig.baseUrl}/prd/$id/download'),
            headers: await ApiConfig.getHeaders(),
          );
        });

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          print("$responseData >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
          
          final data = responseData['data'] ?? {};
          final downloadUrl = data['download_url'];
          final fileName = data['file_name'];
          
          if (downloadUrl != null && fileName != null) {
            // Download file dari URL
            final filePath = await _downloadFile(downloadUrl, fileName);
            
            return {
              ...data,
              'local_file_path': filePath,
              'download_status': 'completed'
            };
          } else {
            throw Exception('Download URL or filename not found in response');
          }
        } else {
          throw Exception('Failed to download PRD: ${response.reasonPhrase}');
        }
      } else {
        throw Exception('Storage permission denied');
      }
    } catch (e) {
      debugPrint('Error downloading PRD: $e');
      rethrow;
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Check Android version
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkVersion = androidInfo.version.sdkInt;
      
      print('Android SDK Version: $sdkVersion');
      
      if (sdkVersion >= 33) {
        // Android 13+ (API 33+) - Request media permissions
        final List<Permission> permissions = [
          Permission.photos,
          Permission.videos,
          Permission.audio,
        ];
        
        Map<Permission, PermissionStatus> statuses = await permissions.request();
        
        // Check if any media permission is granted
        bool hasMediaPermission = statuses.values.any(
          (status) => status == PermissionStatus.granted
        );
        
        if (!hasMediaPermission) {
          print('Media permissions denied, trying manage external storage');
          final manageStorageStatus = await Permission.manageExternalStorage.request();
          return manageStorageStatus == PermissionStatus.granted;
        }
        
        return hasMediaPermission;
      } else if (sdkVersion >= 30) {
        // Android 11-12 (API 30-32) - Request manage external storage
        final manageStorageStatus = await Permission.manageExternalStorage.status;
        
        if (manageStorageStatus.isDenied) {
          final result = await Permission.manageExternalStorage.request();
          return result == PermissionStatus.granted;
        }
        
        return manageStorageStatus == PermissionStatus.granted;
      } else {
        // Android 10 and below - Use legacy storage permission
        final storageStatus = await Permission.storage.status;
        
        if (storageStatus.isDenied) {
          final result = await Permission.storage.request();
          return result == PermissionStatus.granted;
        }
        
        return storageStatus == PermissionStatus.granted;
      }
    }
    
    return true; // iOS doesn't need storage permission for Downloads
  }

  Future<String> _downloadFile(String url, String fileName) async {
    try {
      // Dapatkan direktori Downloads
      Directory? downloadsDirectory;
      
      if (Platform.isAndroid) {
        // Untuk Android, gunakan external storage Downloads
        downloadsDirectory = Directory('/storage/emulated/0/Download');
        if (!await downloadsDirectory.exists()) {
          downloadsDirectory = await getExternalStorageDirectory();
        }
      } else {
        // Untuk iOS
        downloadsDirectory = await getApplicationDocumentsDirectory();
      }

      if (downloadsDirectory == null) {
        throw Exception('Could not access downloads directory');
      }

      final filePath = '${downloadsDirectory.path}/$fileName';
      
      // Download file menggunakan Dio
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            print('Download progress: $progress%');
          }
        },
      );

      print('File downloaded to: $filePath');
      return filePath;
    } catch (e) {
      throw Exception('Failed to download file: $e');
    }
  }

  // Update PRD
  Future<Map<String, dynamic>> updatePrd(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      debugPrint('Updating PRD with ID: $id');
      final response = await _apiInterceptor.interceptRequest(() async {
        return await http.put(
          Uri.parse('${ApiConfig.baseUrl}/prd/$id'),
          headers: {
            ...await ApiConfig.getHeaders(),
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data),
        );
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        debugPrint('PRD update response: ${response.body}');
        return responseData['data'] ?? {};
      } else {
        debugPrint(
          'Failed to update PRD: ${response.statusCode} - ${response.body}',
        );
        throw Exception('Failed to update PRD: ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Error updating PRD: $e');
      rethrow;
    }
  }
}
