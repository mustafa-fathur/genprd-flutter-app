import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class PrdModel {
  final String id;
  final String productName;
  final String documentVersion;
  final String documentStage;
  final String projectOverview;
  final String? startDate;
  final String? endDate;
  final DateTime? deadline;
  final List<String> documentOwners;
  final List<String> developers;
  final List<String> stakeholders;
  final Map<String, dynamic> darciRoles;
  final Map<String, dynamic> generatedSections;
  final List<dynamic> timeline;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;

  PrdModel({
    required this.id,
    required this.productName,
    required this.documentVersion,
    required this.documentStage,
    required this.projectOverview,
    this.startDate,
    this.endDate,
    this.deadline,
    required this.documentOwners,
    required this.developers,
    required this.stakeholders,
    required this.darciRoles,
    required this.generatedSections,
    required this.timeline,
    required this.isPinned,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PrdModel.fromJson(Map<String, dynamic> json) {
    return PrdModel(
      id: json['id']?.toString() ?? '',
      productName: json['product_name'] ?? '',
      documentVersion: json['document_version'] ?? '',
      documentStage: json['document_stage'] ?? 'draft',
      projectOverview: json['project_overview'] ?? '',
      startDate: json['start_date'],
      endDate: json['end_date'],
      deadline:
          json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      documentOwners: _parseList(json['document_owners']),
      developers: _parseList(json['developers']),
      stakeholders: _parseList(json['stakeholders']),
      darciRoles: json['darci_roles'] ?? {},
      generatedSections: json['generated_sections'] ?? {},
      timeline: json['timeline'] ?? [],
      isPinned: json['is_pinned'] == true,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'].toString())
              : DateTime.now(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'].toString())
              : DateTime.now(),
    );
  }

  static List<String> _parseList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return [];
  }

  // Helper method to get formatted date
  String get formattedUpdatedAt {
    try {
      final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
      return formatter.format(updatedAt);
    } catch (e) {
      debugPrint('Error formatting date: $e');
      return 'Unknown date';
    }
  }

  // Helper method to get color based on document stage
  String get stageLabel {
    switch (documentStage.toLowerCase()) {
      case 'draft':
        return 'Draft';
      case 'inprogress':
        return 'In Progress';
      case 'finished':
        return 'Finished';
      case 'archived':
        return 'Archived';
      default:
        return 'Unknown';
    }
  }

  // Get overview sections from generated content
  List<Map<String, dynamic>> get overviewSections {
    try {
      final sections = generatedSections['overview']?['sections'] as List?;
      if (sections == null) return [];
      return sections
          .map((section) => section as Map<String, dynamic>)
          .toList();
    } catch (e) {
      debugPrint('Error getting overview sections: $e');
      return [];
    }
  }

  // Get user stories from generated content
  List<Map<String, dynamic>> get userStories {
    try {
      final stories = generatedSections['user_stories']?['stories'] as List?;
      if (stories == null) return [];
      return stories.map((story) => story as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint('Error getting user stories: $e');
      return [];
    }
  }

  // Get success metrics from generated content
  List<Map<String, dynamic>> get successMetrics {
    try {
      final metrics = generatedSections['success_metrics']?['metrics'] as List?;
      if (metrics == null) return [];
      return metrics.map((metric) => metric as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint('Error getting success metrics: $e');
      return [];
    }
  }

  // Get DARCI roles with guidelines
  List<Map<String, dynamic>> get darciRolesList {
    try {
      final roles = generatedSections['darci']?['roles'] as List?;
      if (roles == null) return [];
      return roles.map((role) => role as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint('Error getting DARCI roles: $e');
      return [];
    }
  }

  // Get project timeline from generated content
  List<Map<String, dynamic>> get projectTimeline {
    try {
      final phases = generatedSections['project_timeline']?['phases'] as List?;
      if (phases == null) return [];
      return phases.map((phase) => phase as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint('Error getting project timeline: $e');
      return [];
    }
  }
}
