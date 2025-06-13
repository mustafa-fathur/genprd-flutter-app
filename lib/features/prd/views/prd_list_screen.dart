import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:genprd/features/prd/controllers/prd_controller.dart';
import 'package:genprd/features/prd/views/prd_detail_screen.dart';
import 'package:genprd/features/prd/views/prd_form_screen.dart';
import 'package:genprd/features/prd/views/prd_edit_screen.dart';
import 'package:genprd/shared/config/routes/app_router.dart';
import 'package:genprd/shared/config/themes/app_theme.dart';
import 'package:genprd/shared/widgets/loading_widget.dart';
import 'package:genprd/shared/widgets/screen_title_widget.dart';
import 'package:genprd/shared/views/main_layout.dart';
import 'package:intl/intl.dart';

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
                  prdController.errorMessage ?? 'Unknown error',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => prdController.loadAllPrds(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Filter PRDs based on search query and selected filter
        final filteredPrds = _filterPrds(prdController.allPrds);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search and filter row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  // Search field
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search PRDs...',
                        prefixIcon: const Icon(CupertinoIcons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Filter dropdown
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedFilter,
                        icon: const Icon(
                          CupertinoIcons.line_horizontal_3_decrease,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedFilter = newValue;
                            });
                          }
                        },
                        items:
                            _filters.map<DropdownMenuItem<String>>((
                              String value,
                            ) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Show empty state if no PRDs
            if (filteredPrds.isEmpty)
              _buildEmptyState(prdController.allPrds.isEmpty),

            // PRD list
            if (filteredPrds.isNotEmpty)
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => prdController.loadAllPrds(),
                  color: AppTheme.primaryColor,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: filteredPrds.length,
                    separatorBuilder:
                        (context, index) => Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey.shade200,
                        ),
                    itemBuilder: (context, index) {
                      final prd = filteredPrds[index];
                      return _buildPrdListItem(prd);
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

  Widget _buildEmptyState(bool isNoData) {
    return Expanded(
      child: Center(
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
      ),
    );
  }

  Widget _buildPrdListItem(Map<String, dynamic> prd) {
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
      onTap: () {
        AppRouter.navigateToPrdDetail(context, prd['id'].toString());
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        child: Padding(
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            prd['product_name'] ?? 'Untitled PRD',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isPinned)
                          Icon(
                            CupertinoIcons.pin_fill,
                            size: 16,
                            color: theme.primaryColor,
                          ),
                      ],
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
                    Row(
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
                        const SizedBox(width: 8),
                        // Updated at text
                        Expanded(
                          child: Text(
                            updatedAt,
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        // Actions menu
                        _buildActionsMenu(prd),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionsMenu(Map<String, dynamic> prd) {
    final bool isPinned = prd['is_pinned'] == true;
    final bool isArchived = prd['document_stage'] == 'archived';

    return PopupMenuButton<String>(
      icon: const Icon(CupertinoIcons.ellipsis_vertical, size: 18),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder:
          (context) => [
            PopupMenuItem<String>(
              value: 'view',
              child: _buildPopupMenuItem(
                CupertinoIcons.doc_text,
                'View Details',
              ),
            ),
            PopupMenuItem<String>(
              value: 'pin',
              child: _buildPopupMenuItem(
                isPinned ? CupertinoIcons.pin_slash : CupertinoIcons.pin,
                isPinned ? 'Unpin' : 'Pin',
              ),
            ),
            PopupMenuItem<String>(
              value: 'archive',
              child: _buildPopupMenuItem(
                isArchived
                    ? CupertinoIcons.tray_arrow_up
                    : CupertinoIcons.archivebox,
                isArchived ? 'Unarchive' : 'Archive',
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'delete',
              child: _buildPopupMenuItem(
                CupertinoIcons.trash,
                'Delete',
                isDestructive: true,
              ),
            ),
          ],
      onSelected: (value) => _handleMenuAction(value, prd),
    );
  }

  Widget _buildPopupMenuItem(
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

  void _handleMenuAction(String action, Map<String, dynamic> prd) async {
    final prdController = Provider.of<PrdController>(context, listen: false);
    final String id = prd['id'].toString();

    switch (action) {
      case 'view':
        AppRouter.navigateToPrdDetail(context, id);
        break;
      case 'pin':
        try {
          final bool isPinned = await prdController.togglePinPrd(id);
          _showSnackBar(
            isPinned ? 'PRD pinned successfully' : 'PRD unpinned successfully',
          );
        } catch (e) {
          _showSnackBar('Failed to update pin status: $e', isError: true);
        }
        break;
      case 'archive':
        try {
          final bool isArchived = prd['document_stage'] == 'archived';
          final result = await prdController.archivePrd(id);
          _showSnackBar(
            isArchived
                ? 'PRD unarchived successfully'
                : 'PRD archived successfully',
          );
        } catch (e) {
          _showSnackBar('Failed to archive PRD: $e', isError: true);
        }
        break;
      case 'delete':
        _showDeleteConfirmationDialog(prd);
        break;
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
        return AppTheme.badgeColors['Draft'] ?? const Color(0xFFF59E0B);
      case 'inprogress':
        return AppTheme.badgeColors['In Progress'] ?? const Color(0xFF2563EB);
      case 'finished':
        return AppTheme.badgeColors['Finished'] ?? const Color(0xFF10B981);
      case 'archived':
        return AppTheme.badgeColors['Archived'] ?? const Color(0xFF6B7280);
      default:
        return Colors.grey;
    }
  }

  IconData _getStageIcon(String stage) {
    switch (stage.toLowerCase()) {
      case 'draft':
        return CupertinoIcons.pencil_outline;
      case 'inprogress':
        return CupertinoIcons.arrow_right_circle;
      case 'finished':
        return CupertinoIcons.checkmark_circle;
      case 'archived':
        return CupertinoIcons.archivebox;
      default:
        return CupertinoIcons.doc_text;
    }
  }

  String _formatDate(dynamic dateString) {
    if (dateString == null) return 'Unknown date';

    try {
      final DateTime date = DateTime.parse(dateString.toString());
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return DateFormat('dd/MM/yyyy').format(date);
      }
    } catch (e) {
      return 'Invalid date';
    }
  }
}
