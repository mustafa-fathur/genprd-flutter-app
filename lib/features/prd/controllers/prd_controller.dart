import 'package:flutter/foundation.dart';
import 'package:genprd/features/prd/services/prd_service.dart';

enum PrdStatus { initial, loading, loaded, error }

class PrdController extends ChangeNotifier {
  final PrdService _prdService = PrdService();

  // State variables
  PrdStatus _status = PrdStatus.initial;
  List<dynamic> _allPrds = [];
  List<dynamic> _pinnedPrds = [];
  List<dynamic> _recentPrds = [];
  String? _errorMessage;

  PrdController() {
    // Load data when controller is created
    loadInitialData();
  }

  // Load initial data
  Future<void> loadInitialData() async {
    await loadPinnedPrds();
    await loadRecentPrds();
  }

  // Getters
  PrdStatus get status => _status;
  List<dynamic> get allPrds => _allPrds;
  List<dynamic> get pinnedPrds => _pinnedPrds;
  List<dynamic> get recentPrds => _recentPrds;
  String? get errorMessage => _errorMessage;

  // Load all PRDs
  Future<void> loadAllPrds() async {
    _status = PrdStatus.loading;
    notifyListeners();

    try {
      _allPrds = await _prdService.getAllPrds();
      _status = PrdStatus.loaded;
    } catch (e) {
      _status = PrdStatus.error;
      _errorMessage = e.toString();
      debugPrint('Error loading PRDs: $e');
    }

    notifyListeners();
  }

  // Load pinned PRDs
  Future<void> loadPinnedPrds() async {
    try {
      debugPrint('PrdController: Loading pinned PRDs...');
      final pinnedPrds = await _prdService.getPinnedPrds();
      _pinnedPrds = pinnedPrds;
      debugPrint('PrdController: Loaded ${_pinnedPrds.length} pinned PRDs');
      notifyListeners();
    } catch (e) {
      debugPrint('PrdController: Error loading pinned PRDs: $e');
      // Don't change overall status for this secondary data
      _pinnedPrds = []; // Set to empty list on error
      notifyListeners();
    }
  }

  // Load recent PRDs
  Future<void> loadRecentPrds() async {
    try {
      debugPrint('PrdController: Loading recent PRDs...');
      final recentPrds = await _prdService.getRecentPrds();
      _recentPrds = recentPrds;
      debugPrint('PrdController: Loaded ${_recentPrds.length} recent PRDs');
      notifyListeners();
    } catch (e) {
      debugPrint('PrdController: Error loading recent PRDs: $e');
      // Don't change overall status for this secondary data
      _recentPrds = []; // Set to empty list on error
      notifyListeners();
    }
  }

  // Load all data
  Future<void> loadAllData() async {
    _status = PrdStatus.loading;
    notifyListeners();

    try {
      await Future.wait([loadAllPrds(), loadPinnedPrds(), loadRecentPrds()]);
      _status = PrdStatus.loaded;
    } catch (e) {
      _status = PrdStatus.error;
      _errorMessage = e.toString();
      debugPrint('Error loading all PRD data: $e');
    }

    notifyListeners();
  }

  // Toggle pin status
  Future<void> togglePinPrd(String id) async {
    try {
      final isPinned = await _prdService.togglePinPrd(id);

      // Update the pinned status in all lists
      _updatePrdPinStatus(id, isPinned);

      // Reload pinned PRDs
      await loadPinnedPrds();

      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling pin status: $e');
    }
  }

  // Helper method to update pin status across lists
  void _updatePrdPinStatus(String id, bool isPinned) {
    for (int i = 0; i < _allPrds.length; i++) {
      if (_allPrds[i]['id'] == id) {
        _allPrds[i]['is_pinned'] = isPinned;
      }
    }

    for (int i = 0; i < _recentPrds.length; i++) {
      if (_recentPrds[i]['id'] == id) {
        _recentPrds[i]['is_pinned'] = isPinned;
      }
    }
  }
}
