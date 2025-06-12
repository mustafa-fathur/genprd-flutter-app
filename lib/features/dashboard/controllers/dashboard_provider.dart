import 'package:flutter/material.dart';
import 'package:genprd/features/dashboard/models/dashboard_data.dart';
import 'package:genprd/features/dashboard/services/dashboard_service.dart';

enum DashboardStatus { initial, loading, loaded, error }

class DashboardProvider with ChangeNotifier {
  final DashboardService _dashboardService = DashboardService();

  DashboardStatus _status = DashboardStatus.initial;
  DashboardData _dashboardData = DashboardData.empty();
  String? _errorMessage;

  // Getters
  DashboardStatus get status => _status;
  DashboardData get dashboardData => _dashboardData;
  String? get errorMessage => _errorMessage;

  // Load dashboard data
  Future<void> loadDashboardData() async {
    if (_status == DashboardStatus.loading) return;

    try {
      _status = DashboardStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final data = await _dashboardService.getDashboardData();
      _dashboardData = data;
      _status = DashboardStatus.loaded;

      debugPrint('Dashboard data loaded successfully');
    } catch (e) {
      _status = DashboardStatus.error;
      _errorMessage = e.toString();
      debugPrint('Error loading dashboard data: $e');
    }

    notifyListeners();
  }

  // Refresh dashboard data
  Future<void> refreshDashboardData() async {
    try {
      final data = await _dashboardService.getDashboardData();
      _dashboardData = data;
      _status = DashboardStatus.loaded;
      _errorMessage = null;

      debugPrint('Dashboard data refreshed successfully');
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error refreshing dashboard data: $e');
      // Keep previous status and data if refresh fails
    }

    notifyListeners();
  }
}
