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
  Future<bool> togglePinPrd(String id) async {
    try {
      final isPinned = await _prdService.togglePinPrd(id);

      // Update the pinned status in all lists
      _updatePrdPinStatus(id, isPinned);

      // Reload pinned PRDs
      await loadPinnedPrds();
      await loadRecentPrds();

      notifyListeners();
      return isPinned;
    } catch (e) {
      debugPrint('Error toggling pin status: $e');
      rethrow;
    }
  }

  // Archive PRD
  Future<Map<String, dynamic>> archivePrd(String id) async {
    try {
      final result = await _prdService.archivePrd(id);

      // Update the PRD stage in all lists
      final newStage = result['document_stage'];
      _updatePrdStage(id, newStage);

      // Reload lists to ensure UI is updated
      await loadPinnedPrds();
      await loadRecentPrds();

      notifyListeners();
      return result;
    } catch (e) {
      debugPrint('Error archiving PRD: $e');
      rethrow;
    }
  }

  // Delete PRD
  Future<bool> deletePrd(String id) async {
    try {
      final result = await _prdService.deletePrd(id);

      if (result) {
        // Remove the PRD from all lists
        _allPrds.removeWhere((prd) => prd['id'].toString() == id);
        _pinnedPrds.removeWhere((prd) => prd['id'].toString() == id);
        _recentPrds.removeWhere((prd) => prd['id'].toString() == id);

        notifyListeners();
      }

      return result;
    } catch (e) {
      debugPrint('Error deleting PRD: $e');
      rethrow;
    }
  }

  // Update PRD stage
  Future<Map<String, dynamic>> updatePrdStage(String id, String stage) async {
    try {
      final result = await _prdService.updatePrdStage(id, stage);

      // Update the PRD stage in all lists
      final newStage = result['document_stage'];
      _updatePrdStage(id, newStage);

      notifyListeners();
      return result;
    } catch (e) {
      debugPrint('Error updating PRD stage: $e');
      rethrow;
    }
  }

  // Download PRD
  Future<Map<String, dynamic>> downloadPrd(String id) async {
    try {
      return await _prdService.downloadPrd(id);
    } catch (e) {
      debugPrint('Error downloading PRD: $e');
      rethrow;
    }
  }

  // Helper method to update pin status across lists
  void _updatePrdPinStatus(String id, bool isPinned) {
    for (int i = 0; i < _allPrds.length; i++) {
      if (_allPrds[i]['id'].toString() == id) {
        _allPrds[i]['is_pinned'] = isPinned;
      }
    }

    for (int i = 0; i < _recentPrds.length; i++) {
      if (_recentPrds[i]['id'].toString() == id) {
        _recentPrds[i]['is_pinned'] = isPinned;
      }
    }

    for (int i = 0; i < _pinnedPrds.length; i++) {
      if (_pinnedPrds[i]['id'].toString() == id) {
        _pinnedPrds[i]['is_pinned'] = isPinned;
      }
    }
  }

  // Helper method to update stage across lists
  void _updatePrdStage(String id, String stage) {
    for (int i = 0; i < _allPrds.length; i++) {
      if (_allPrds[i]['id'].toString() == id) {
        _allPrds[i]['document_stage'] = stage;
      }
    }

    for (int i = 0; i < _recentPrds.length; i++) {
      if (_recentPrds[i]['id'].toString() == id) {
        _recentPrds[i]['document_stage'] = stage;
      }
    }

    for (int i = 0; i < _pinnedPrds.length; i++) {
      if (_pinnedPrds[i]['id'].toString() == id) {
        _pinnedPrds[i]['document_stage'] = stage;
      }
    }
  }
}
