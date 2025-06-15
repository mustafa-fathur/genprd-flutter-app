import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:genprd/features/prd/controllers/prd_controller.dart';
import 'package:genprd/shared/config/routes/app_router.dart';
import 'package:genprd/shared/config/themes/app_theme.dart';
import 'package:genprd/shared/widgets/loading_widget.dart';
import 'package:genprd/shared/views/main_layout.dart';
import 'package:genprd/features/prd/views/widgets/prd_list_item.dart';
import 'package:genprd/features/prd/views/widgets/empty_state.dart';
import 'package:genprd/features/prd/views/widgets/search_filter_bar.dart';
import 'package:genprd/features/prd/views/widgets/error_state.dart';

class PrdListScreen extends StatefulWidget {
  const PrdListScreen({super.key});

  @override
  State<PrdListScreen> createState() => _PrdListScreenState();
}

class _PrdListScreenState extends State<PrdListScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Draft',
    'In Progress',
    'Finished',
    'Archived',
  ];

  @override
  void initState() {
    super.initState();
    // Load PRDs when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prdController = Provider.of<PrdController>(context, listen: false);
      prdController.loadAllPrds();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'All PRDs',
      selectedItem: NavigationItem.allPrds,
      child: _buildPrdListContent(),
    );
  }

  Widget _buildPrdListContent() {
    return Consumer<PrdController>(
      builder: (context, prdController, child) {
        // Show loading state
        if (prdController.status == PrdStatus.loading &&
            prdController.allPrds.isEmpty) {
          return const Center(child: LoadingWidget(message: 'Loading PRDs...'));
        }

        // Show error state
        if (prdController.status == PrdStatus.error) {
          return ErrorState(
            errorMessage: prdController.errorMessage,
            onRetry: () => prdController.loadAllPrds(),
          );
        }

        // Filter PRDs based on search query and selected filter
        final filteredPrds = _filterPrds(prdController.allPrds);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search and filter row
            SearchFilterBar(
              searchQuery: _searchQuery,
              selectedFilter: _selectedFilter,
              filters: _filters,
              onSearchChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onFilterChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedFilter = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Show empty state if no PRDs
            if (filteredPrds.isEmpty)
              Expanded(
                child: EmptyState(isNoData: prdController.allPrds.isEmpty),
              ),

            // PRD list
            if (filteredPrds.isNotEmpty)
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => prdController.loadAllPrds(),
                  color: AppTheme.primaryColor,
                  child: ListView.separated(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      bottom: 80.0, // Add bottom padding to avoid FAB overlap
                    ),
                    itemCount: filteredPrds.length,
                    separatorBuilder:
                        (context, index) => Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey.shade200,
                        ),
                    itemBuilder: (context, index) {
                      final prd = filteredPrds[index];
                      return PrdListItem(
                        prd: prd,
                        onViewDetails: _navigateToPrdDetail,
                        onTogglePin: _togglePinStatus,
                        onArchive: _showArchiveConfirmationDialog,
                        onDelete: _showDeleteConfirmationDialog,
                      );
                    },
                  ),
                ),
              ),

            // Show loading indicator at the bottom during refresh
            if (prdController.status == PrdStatus.loading &&
                prdController.allPrds.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  List<dynamic> _filterPrds(List<dynamic> prds) {
    if (prds.isEmpty) return [];

    return prds.where((prd) {
      // Filter by stage
      if (_selectedFilter != 'All') {
        final stage = _mapFilterToStage(_selectedFilter);
        if (prd['document_stage']?.toLowerCase() != stage.toLowerCase()) {
          return false;
        }
      }

      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final productName = prd['product_name']?.toString().toLowerCase() ?? '';
        final overview =
            prd['project_overview']?.toString().toLowerCase() ?? '';
        return productName.contains(_searchQuery.toLowerCase()) ||
            overview.contains(_searchQuery.toLowerCase());
      }

      return true;
    }).toList();
  }

  String _mapFilterToStage(String filter) {
    switch (filter) {
      case 'In Progress':
        return 'inprogress';
      case 'Draft':
        return 'draft';
      case 'Finished':
        return 'finished';
      case 'Archived':
        return 'archived';
      default:
        return filter.toLowerCase();
    }
  }

  void _navigateToPrdDetail(String id) {
    AppRouter.navigateToPrdDetail(context, id);
  }

  void _togglePinStatus(Map<String, dynamic> prd) {
    final prdController = Provider.of<PrdController>(context, listen: false);
    final String id = prd['id'].toString();

    try {
      final bool isPinned = prd['is_pinned'] == true;
      prdController.togglePinPrd(id);
      _showSnackBar(
        isPinned ? 'PRD unpinned successfully' : 'PRD pinned successfully',
      );
    } catch (e) {
      _showSnackBar('Failed to update pin status: $e', isError: true);
    }
  }

  void _showArchiveConfirmationDialog(Map<String, dynamic> prd) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Archive PRD'),
            content: Text(
              'Are you sure you want to archive "${prd['product_name']}"? '
              'This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _archivePrd(prd['id'].toString());
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Archive'),
              ),
            ],
          ),
    );
  }

  Future<void> _archivePrd(String id) async {
    final prdController = Provider.of<PrdController>(context, listen: false);
    try {
      await prdController.archivePrd(id);
      _showSnackBar('PRD archived successfully');
    } catch (e) {
      _showSnackBar('Failed to archive PRD: $e', isError: true);
    }
  }

  void _showDeleteConfirmationDialog(Map<String, dynamic> prd) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete PRD'),
            content: Text(
              'Are you sure you want to delete "${prd['product_name']}"? '
              'This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _deletePrd(prd['id'].toString());
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  Future<void> _deletePrd(String id) async {
    final prdController = Provider.of<PrdController>(context, listen: false);
    try {
      await prdController.deletePrd(id);
      _showSnackBar('PRD deleted successfully');
    } catch (e) {
      _showSnackBar('Failed to delete PRD: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        ),
    );
  }
}
