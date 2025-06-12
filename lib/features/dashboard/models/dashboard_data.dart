import 'package:flutter/foundation.dart';

class DashboardData {
  final DashboardCounts counts;
  final List<RecentPRD> recentPRDs;

  DashboardData({required this.counts, required this.recentPRDs});

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      counts: DashboardCounts.fromJson(json['counts'] ?? {}),
      recentPRDs:
          (json['recentPRDs'] as List<dynamic>?)
              ?.map((prd) => RecentPRD.fromJson(prd))
              .toList() ??
          [],
    );
  }

  // Empty dashboard data for initial state
  factory DashboardData.empty() {
    return DashboardData(counts: DashboardCounts.empty(), recentPRDs: []);
  }
}

class DashboardCounts {
  final int totalPRD;
  final int totalPersonnel;
  final int totalDraft;
  final int totalInProgress;
  final int totalFinished;
  final int totalArchived;
  final int totalPinned;

  DashboardCounts({
    required this.totalPRD,
    required this.totalPersonnel,
    required this.totalDraft,
    required this.totalInProgress,
    required this.totalFinished,
    required this.totalArchived,
    required this.totalPinned,
  });

  factory DashboardCounts.fromJson(Map<String, dynamic> json) {
    return DashboardCounts(
      totalPRD: json['totalPRD'] ?? 0,
      totalPersonnel: json['totalPersonnel'] ?? 0,
      totalDraft: json['totalDraft'] ?? 0,
      totalInProgress: json['totalInProgress'] ?? 0,
      totalFinished: json['totalFinished'] ?? 0,
      totalArchived: json['totalArchived'] ?? 0,
      totalPinned: json['totalPinned'] ?? 0,
    );
  }

  // Empty counts for initial state
  factory DashboardCounts.empty() {
    return DashboardCounts(
      totalPRD: 0,
      totalPersonnel: 0,
      totalDraft: 0,
      totalInProgress: 0,
      totalFinished: 0,
      totalArchived: 0,
      totalPinned: 0,
    );
  }
}

class RecentPRD {
  final String id;
  final String productName;
  final String documentStage;
  final String documentVersion;
  final DateTime updatedAt;

  RecentPRD({
    required this.id,
    required this.productName,
    required this.documentStage,
    required this.documentVersion,
    required this.updatedAt,
  });

  factory RecentPRD.fromJson(Map<String, dynamic> json) {
    return RecentPRD(
      id: json['id']?.toString() ?? '',
      productName: json['product_name'] ?? '',
      documentStage: json['document_stage'] ?? '',
      documentVersion: json['document_version'] ?? '',
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : DateTime.now(),
    );
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
}
