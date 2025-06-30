import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:genprd/shared/utils/platform_helper.dart';
import 'package:provider/provider.dart';
import 'package:genprd/features/prd/controllers/prd_controller.dart';
import 'package:genprd/shared/config/routes/app_router.dart';
import 'package:genprd/shared/config/themes/app_theme.dart';
import 'package:genprd/shared/widgets/loading_widget.dart';
import 'package:genprd/shared/views/main_layout.dart';
import 'package:genprd/shared/utils/snackbar_helper.dart';
import 'package:intl/intl.dart';

class PrdListScreen extends StatefulWidget {
  const PrdListScreen({super.key});

  @override
  State<PrdListScreen> createState() => _PrdListScreenState();
}

class _PrdListScreenState extends State<PrdListScreen> {
  final String _searchQuery = '';
  final String _selectedFilter = 'All';
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
    return const MainLayout(
      title: 'All PRDs',
      subtitle: 'Manage and organize your Product Requirement Documents',
      selectedItem: NavigationItem.allPrds,
      child: PrdListContent(),
    );
  }
}

class PrdListContent extends StatefulWidget {
  const PrdListContent({super.key});

  @override
  _PrdListContentState createState() => _PrdListContentState();
}

class _PrdListContentState extends State<PrdListContent> {
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
            const SizedBox(height: 24),

            // Show empty state or PRD list
            Expanded(
              child:
                  filteredPrds.isEmpty
                      ? EmptyState(isNoData: prdController.allPrds.isEmpty)
                      : FilteredPrdList(
                        prds: filteredPrds,
                        onViewDetails: _navigateToPrdDetail,
                        onTogglePin: _togglePinStatus,
                        onArchive: _showArchiveConfirmationDialog,
                        onDelete: _showDeleteConfirmationDialog,
                        onRefresh: () => prdController.loadAllPrds(),
                      ),
            ),

            // Show loading indicator at the bottom during refresh
            if (prdController.status == PrdStatus.loading &&
                prdController.allPrds.isNotEmpty)
              const LoadingIndicator(),
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
      SnackBarHelper.showSnackBar(
        context,
        isPinned ? 'PRD unpinned successfully' : 'PRD pinned successfully',
      );
    } catch (e) {
      SnackBarHelper.showSnackBar(
        context,
        'Failed to update pin status: $e',
        isError: true,
      );
    }
  }

  void _showArchiveConfirmationDialog(Map<String, dynamic> prd) {
    showDialog(
      context: context,
      builder:
          (context) => ConfirmationDialog(
            title: 'Archive PRD',
            message:
                'Are you sure you want to archive "${prd['product_name']}"? '
                'This action cannot be undone.',
            confirmText: 'Archive',
            onConfirm: () => _archivePrd(prd['id'].toString()),
          ),
    );
  }

  Future<void> _archivePrd(String id) async {
    final prdController = Provider.of<PrdController>(context, listen: false);
    try {
      await prdController.archivePrd(id);
      SnackBarHelper.showSnackBar(context, 'PRD archived successfully');
    } catch (e) {
      SnackBarHelper.showSnackBar(
        context,
        'Failed to archive PRD: $e',
        isError: true,
      );
    }
  }

  void _showDeleteConfirmationDialog(Map<String, dynamic> prd) {
    showDialog(
      context: context,
      builder:
          (context) => ConfirmationDialog(
            title: 'Delete PRD',
            message:
                'Are you sure you want to delete "${prd['product_name']}"? '
                'This action cannot be undone.',
            confirmText: 'Delete',
            onConfirm: () => _deletePrd(prd['id'].toString()),
          ),
    );
  }

  Future<void> _deletePrd(String id) async {
    final prdController = Provider.of<PrdController>(context, listen: false);
    try {
      await prdController.deletePrd(id);
      SnackBarHelper.showSnackBar(context, 'PRD deleted successfully');
    } catch (e) {
      SnackBarHelper.showSnackBar(
        context,
        'Failed to delete PRD: $e',
        isError: true,
      );
    }
  }
}

// Semua widget yang sebelumnya terpisah sekarang digabungkan ke file ini

// 1. SearchFilterBar widget
class SearchFilterBar extends StatelessWidget {
  final String searchQuery;
  final String selectedFilter;
  final List<String> filters;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onFilterChanged;

  const SearchFilterBar({
    super.key,
    required this.searchQuery,
    required this.selectedFilter,
    required this.filters,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            // Search field
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search PRDs...',
                  prefixIcon: const Icon(CupertinoIcons.search, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  isDense: true,
                ),
                onChanged: onSearchChanged,
              ),
            ),
            if (!PlatformHelper.isMobilePlatform(context)) ...[
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => AppRouter.navigateToCreatePrd(context),
                icon: const Icon(CupertinoIcons.add, size: 16),
                label: const Text('New PRD'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        // Filter Chips
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filters.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final filter = filters[index];
              final isSelected = selectedFilter == filter;
              return ChoiceChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    onFilterChanged(filter);
                  }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color:
                        isSelected ? Colors.transparent : Colors.grey.shade300,
                  ),
                ),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: Colors.white,
                selectedColor: Theme.of(context).primaryColor,
                showCheckmark: false,
              );
            },
          ),
        ),
      ],
    );
  }
}

// 2. ErrorState widget
class ErrorState extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onRetry;

  const ErrorState({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.exclamationmark_circle,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load PRDs',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage ?? 'Unknown error',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

// 3. EmptyState widget
class EmptyState extends StatelessWidget {
  final bool isNoData;

  const EmptyState({super.key, required this.isNoData});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isNoData ? CupertinoIcons.doc_text : CupertinoIcons.search,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            isNoData ? 'No PRDs found' : 'No matching PRDs',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Text(
            isNoData
                ? 'Create your first PRD to get started'
                : 'Try adjusting your search or filter',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          if (isNoData) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => AppRouter.navigateToCreatePrd(context),
              icon: const Icon(CupertinoIcons.add, size: 16),
              label: const Text('Create PRD'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// 4. LoadingIndicator widget
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}

// 5. ConfirmationDialog widget
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final bool isDestructive;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    required this.onConfirm,
    this.isDestructive = true,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: TextButton.styleFrom(
            foregroundColor: isDestructive ? Colors.red : null,
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }
}

// 6. FilteredPrdList widget
class FilteredPrdList extends StatelessWidget {
  final List<dynamic> prds;
  final Function(String) onViewDetails;
  final Function(Map<String, dynamic>) onTogglePin;
  final Function(Map<String, dynamic>) onArchive;
  final Function(Map<String, dynamic>) onDelete;
  final Future<void> Function() onRefresh;

  const FilteredPrdList({
    super.key,
    required this.prds,
    required this.onViewDetails,
    required this.onTogglePin,
    required this.onArchive,
    required this.onDelete,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppTheme.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80.0),
        itemCount: prds.length,
        itemBuilder: (context, index) {
          final prd = prds[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: PrdListItem(
              prd: prd,
              onViewDetails: onViewDetails,
              onTogglePin: onTogglePin,
              onArchive: onArchive,
              onDelete: onDelete,
            ),
          );
        },
      ),
    );
  }
}

// 7. PrdListItem widget
class PrdListItem extends StatelessWidget {
  final Map<String, dynamic> prd;
  final Function(String) onViewDetails;
  final Function(Map<String, dynamic>) onTogglePin;
  final Function(Map<String, dynamic>) onArchive;
  final Function(Map<String, dynamic>) onDelete;

  const PrdListItem({
    super.key,
    required this.prd,
    required this.onViewDetails,
    required this.onTogglePin,
    required this.onArchive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Get stage for badge display
    final String stage = prd['document_stage'] ?? 'draft';
    final String displayStage = _getDisplayStage(stage);

    // Get the appropriate color for the stage badge
    final Color badgeColor = _getStageBadgeColor(stage);

    // Format date for display
    final String updatedAt = _formatDate(prd['updated_at']);

    // Check if PRD is pinned
    final bool isPinned = prd['is_pinned'] == true;

    return InkWell(
      onTap: () => onViewDetails(prd['id'].toString()),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        margin: const EdgeInsets.symmetric(vertical: 0),
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PRD icon with colored background
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        _getStageIcon(stage),
                        color: badgeColor,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // PRD details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title row (no pin icon here anymore)
                        Text(
                          prd['product_name'] ?? 'Untitled PRD',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          prd['project_overview'] ?? 'No description',
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            // Stage badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: badgeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                displayStage,
                                style: textTheme.bodySmall?.copyWith(
                                  color: badgeColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            // Pinned badge (if pinned)
                            if (isPinned)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      CupertinoIcons.pin_fill,
                                      size: 12,
                                      color: theme.primaryColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Pinned',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: theme.primaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            // Updated at text
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                updatedAt,
                                style: textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 3-dots menu positioned at top right
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: _buildPrdItemMenu(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrdItemMenu(BuildContext context) {
    final bool isPinned = prd['is_pinned'] == true;
    final bool isArchived = prd['document_stage'] == 'archived';

    return PopupMenuButton<String>(
      icon: const Icon(
        CupertinoIcons.ellipsis_vertical,
        size: 20,
        color: Colors.black87,
      ),
      padding: EdgeInsets.zero,
      splashRadius: 24,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder:
          (context) => [
            // View option
            PopupMenuItem<String>(
              value: 'view',
              child: _buildMenuItemRow(CupertinoIcons.doc_text, 'View Details'),
            ),
            // Pin/Unpin option
            PopupMenuItem<String>(
              value: 'pin',
              child: _buildMenuItemRow(
                isPinned ? CupertinoIcons.pin_fill : CupertinoIcons.pin,
                isPinned ? 'Unpin' : 'Pin',
              ),
            ),
            // Archive/Unarchive option
            PopupMenuItem<String>(
              value: 'archive',
              child: _buildMenuItemRow(
                isArchived
                    ? CupertinoIcons.tray_arrow_up
                    : CupertinoIcons.archivebox,
                isArchived ? 'Unarchive' : 'Archive',
              ),
            ),
            // Delete option
            PopupMenuItem<String>(
              value: 'delete',
              child: _buildMenuItemRow(
                CupertinoIcons.trash,
                'Delete',
                isDestructive: true,
              ),
            ),
          ],
      onSelected: (value) {
        switch (value) {
          case 'view':
            onViewDetails(prd['id'].toString());
            break;
          case 'pin':
            onTogglePin(prd);
            break;
          case 'archive':
            onArchive(prd);
            break;
          case 'delete':
            onDelete(prd);
            break;
        }
      },
    );
  }

  Widget _buildMenuItemRow(
    IconData icon,
    String label, {
    bool isDestructive = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: isDestructive ? Colors.red : null),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: isDestructive ? Colors.red : null)),
      ],
    );
  }

  // Helper methods
  String _formatDate(dynamic dateString) {
    if (dateString == null) return 'Unknown date';

    try {
      final DateTime date = DateTime.parse(dateString.toString());
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  String _getDisplayStage(String stage) {
    switch (stage.toLowerCase()) {
      case 'inprogress':
        return 'In Progress';
      case 'draft':
        return 'Draft';
      case 'finished':
        return 'Finished';
      case 'archived':
        return 'Archived';
      default:
        return stage;
    }
  }

  Color _getStageBadgeColor(String stage) {
    switch (stage.toLowerCase()) {
      case 'draft':
        return AppTheme.badgeColors['Draft']!;
      case 'inprogress':
        return AppTheme.badgeColors['In Progress']!;
      case 'finished':
        return AppTheme.badgeColors['Finished']!;
      case 'archived':
        return AppTheme.badgeColors['Archived']!;
      default:
        return Colors.grey;
    }
  }

  IconData _getStageIcon(String stage) {
    switch (stage.toLowerCase()) {
      case 'draft':
        return CupertinoIcons.doc_text;
      case 'inprogress':
        return CupertinoIcons.doc_chart;
      case 'finished':
        return CupertinoIcons.doc_checkmark;
      case 'archived':
        return CupertinoIcons.archivebox;
      default:
        return CupertinoIcons.doc;
    }
  }
}
