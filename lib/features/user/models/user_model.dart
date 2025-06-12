import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class User {
  final String id;
  final String? googleId;
  final String email;
  final String name;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    this.googleId,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final name = json['name'] ?? '';

    // Parse created_at date properly handling different formats
    DateTime? createdAtDate;
    if (json['created_at'] != null) {
      try {
        final createdAtStr = json['created_at'].toString();
        debugPrint('Attempting to parse created_at: $createdAtStr');

        // Try standard ISO format first
        try {
          createdAtDate = DateTime.parse(createdAtStr);
          debugPrint('Parsed with DateTime.parse: $createdAtDate');
        } catch (e) {
          debugPrint('Failed standard parsing: $e');

          // Try custom format: 2025-06-12 05:05:54
          try {
            createdAtDate = DateFormat(
              'yyyy-MM-dd HH:mm:ss',
            ).parse(createdAtStr);
            debugPrint('Parsed with DateFormat: $createdAtDate');
          } catch (e2) {
            debugPrint('Failed custom format parsing: $e2');
          }
        }
      } catch (e) {
        debugPrint('Error parsing created_at date: $e');
      }
    } else if (json['createdAt'] != null) {
      try {
        final createdAtStr = json['createdAt'].toString();
        debugPrint('Attempting to parse createdAt: $createdAtStr');

        // Try standard ISO format first
        try {
          createdAtDate = DateTime.parse(createdAtStr);
          debugPrint('Parsed with DateTime.parse: $createdAtDate');
        } catch (e) {
          debugPrint('Failed standard parsing: $e');

          // Try custom format: 2025-06-12 05:05:54
          try {
            createdAtDate = DateFormat(
              'yyyy-MM-dd HH:mm:ss',
            ).parse(createdAtStr);
            debugPrint('Parsed with DateFormat: $createdAtDate');
          } catch (e2) {
            debugPrint('Failed custom format parsing: $e2');
          }
        }
      } catch (e) {
        debugPrint('Error parsing createdAt date: $e');
      }
    }

    // Parse updated_at date properly handling different formats
    DateTime? updatedAtDate;
    if (json['updated_at'] != null) {
      try {
        final updatedAtStr = json['updated_at'].toString();

        // Try standard ISO format first
        try {
          updatedAtDate = DateTime.parse(updatedAtStr);
        } catch (e) {
          // Try custom format: 2025-06-12 05:05:54
          try {
            updatedAtDate = DateFormat(
              'yyyy-MM-dd HH:mm:ss',
            ).parse(updatedAtStr);
          } catch (e2) {
            debugPrint('Failed to parse updated_at date: $e2');
          }
        }
      } catch (e) {
        debugPrint('Error parsing updated_at date: $e');
      }
    } else if (json['updatedAt'] != null) {
      try {
        final updatedAtStr = json['updatedAt'].toString();

        // Try standard ISO format first
        try {
          updatedAtDate = DateTime.parse(updatedAtStr);
        } catch (e) {
          // Try custom format: 2025-06-12 05:05:54
          try {
            updatedAtDate = DateFormat(
              'yyyy-MM-dd HH:mm:ss',
            ).parse(updatedAtStr);
          } catch (e2) {
            debugPrint('Failed to parse updatedAt date: $e2');
          }
        }
      } catch (e) {
        debugPrint('Error parsing updatedAt date: $e');
      }
    }

    return User(
      id: json['id'].toString(),
      googleId: json['google_id'] ?? json['googleId'],
      email: json['email'] ?? '',
      name: name,
      avatarUrl: json['avatar_url'] ?? json['avatarUrl'],
      createdAt: createdAtDate,
      updatedAt: updatedAtDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'google_id': googleId,
      'email': email,
      'name': name,
      'avatar_url': avatarUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email, createdAt: $createdAt}';
  }
}
