import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:genprd/features/prd/controllers/prd_controller.dart';
import 'package:genprd/features/prd/services/prd_service.dart';
import 'package:genprd/features/prd/views/prd_edit_screen.dart';
import 'package:genprd/shared/config/themes/app_theme.dart';
import 'package:genprd/shared/widgets/loading_widget.dart';
import 'package:genprd/shared/config/routes/app_router.dart';
import 'package:intl/intl.dart';
import 'package:genprd/features/prd/models/prd_model.dart';

class PrdDetailScreen extends StatefulWidget {
  final String prdId;

  const PrdDetailScreen({super.key, required this.prdId});

  @override
  State<PrdDetailScreen> createState() => _PrdDetailScreenState();
}

class _PrdDetailScreenState extends State<PrdDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PrdService _prdService = PrdService();

  // State variables
  PrdModel? _prdModel;
  Map<String, dynamic>? _prdData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchPrdData();
  }

  Future<void> _fetchPrdData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final data = await _prdService.getPrdById(widget.prdId);

      setState(() {
        _prdModel = data;
        // Convert PrdModel to Map for backward compatibility
        _prdData = {
          'id': data.id,
          'product_name': data.productName,
          'document_version': data.documentVersion,
          'document_stage': data.documentStage,
          'project_overview': data.projectOverview,
          'start_date': data.startDate,
          'end_date': data.endDate,
          'document_owners': data.documentOwners,
          'developers': data.developers,
          'stakeholders': data.stakeholders,
          'darci_roles': data.darciRoles,
          'generated_sections': data.generatedSections,
          'timeline': data.timeline,
          'is_pinned': data.isPinned,
          'created_at': data.createdAt.toIso8601String(),
          'updated_at': data.updatedAt.toIso8601String(),
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      debugPrint('Error fetching PRD data: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading state
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('PRD Details'),
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back),
            onPressed: () => AppRouter.navigateToAllPrds(context),
          ),
        ),
        body: const Center(
          child: LoadingWidget(message: 'Loading PRD details...'),
        ),
      );
    }

    // Show error state
    if (_error != null || _prdData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('PRD Details'),
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back),
            onPressed: () => AppRouter.navigateToAllPrds(context),
          ),
        ),
        body: Center(
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
                'Failed to load PRD details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _error ?? 'Unknown error',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _fetchPrdData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final bool isPinned = _prdData!['is_pinned'] == true;
    final String stage = _prdData!['document_stage'] ?? 'draft';
    final bool isArchived = stage == 'archived';

    return Scaffold(
      appBar: AppBar(
        title: Text(_prdData!['product_name'] ?? 'PRD Details'),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => AppRouter.navigateToAllPrds(context),
        ),
        actions: [
          // More options menu with all actions
          PopupMenuButton<String>(
            icon: const Icon(CupertinoIcons.ellipsis_vertical),
            tooltip: 'More options',
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder:
                (context) => [
                  // Pin/Unpin option
                  PopupMenuItem<String>(
                    value: 'pin',
                    child: _buildPopupMenuItem(
                      isPinned ? CupertinoIcons.pin_fill : CupertinoIcons.pin,
                      isPinned ? 'Unpin' : 'Pin',
                    ),
                  ),
                  // Edit option
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: _buildPopupMenuItem(CupertinoIcons.pencil, 'Edit'),
                  ),
                  // Download option
                  PopupMenuItem<String>(
                    value: 'download',
                    child: _buildPopupMenuItem(
                      CupertinoIcons.arrow_down_doc,
                      'Download PDF',
                    ),
                  ),
                  // Archive option
                  PopupMenuItem<String>(
                    value: 'archive',
                    child: _buildPopupMenuItem(
                      isArchived
                          ? CupertinoIcons.tray_arrow_up
                          : CupertinoIcons.archivebox,
                      isArchived ? 'Unarchive' : 'Archive',
                    ),
                  ),
                  // Delete option
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: _buildPopupMenuItem(
                      CupertinoIcons.trash,
                      'Delete',
                      isDestructive: true,
                    ),
                  ),
                ],
            onSelected: _handleMenuAction,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          indicatorWeight: 3.0,
          tabs: const [Tab(text: 'Overview'), Tab(text: 'Team & Roles')],
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Status bar with stage selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Version ${_prdData!['document_version'] ?? '1.0'}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Last Updated: ${_formatDateTime(_prdData!['updated_at'])}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStageDropdown(),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildOverviewTab(), _buildTeamRolesTab()],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to edit screen with full prdData
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PrdEditScreen(prdData: _prdData!),
            ),
          ).then((updatedData) {
            if (updatedData != null) {
              setState(() {
                _prdData = updatedData;
              });
            }
          });
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(CupertinoIcons.pencil, color: Colors.white),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('PRD Identity'),
          _buildInfoCard([
            _buildInfoRow(
              'Product Name:',
              _prdData!['product_name'] ?? 'Untitled',
            ),
            _buildInfoRow(
              'Document Version:',
              _prdData!['document_version'] ?? '1.0',
            ),
            _buildInfoRow('Document Owner:', _getDocumentOwners()),
            _buildInfoRow(
              'Created Date:',
              _formatDate(_prdData!['created_at']),
            ),
          ]),

          const SizedBox(height: 20),
          _buildSectionHeader('Project Overview'),
          _buildContentCard(
            _prdData!['project_overview'] ?? 'No overview available',
          ),

          // Problem Statements from generated sections if available
          if (_hasGeneratedSection('overview')) ...[
            const SizedBox(height: 20),
            _buildSectionHeader('Problem Statements'),
            _buildContentCard(_getOverviewSectionContent('Problem Statement')),
          ],

          // Objectives from generated sections if available
          if (_hasGeneratedSection('overview')) ...[
            const SizedBox(height: 20),
            _buildSectionHeader('Objectives'),
            _buildContentCard(_getOverviewSectionContent('Objectives')),
          ],
        ],
      ),
    );
  }

  Widget _buildTeamRolesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Team Members'),
          _buildInfoCard([
            _buildInfoRow('Document Owner:', _getDocumentOwners()),
            _buildInfoRow(
              'Stakeholders:',
              _getListAsString(_prdData!['stakeholders']),
            ),
            _buildInfoRow(
              'Developers:',
              _getListAsString(_prdData!['developers']),
            ),
          ]),

          // Timeline section
          if (_prdData!['timeline'] != null &&
              (_prdData!['timeline'] as List).isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildSectionHeader('Timeline'),
            _buildTimelineSection(),
          ],

          // Success Metrics from generated sections if available
          if (_hasGeneratedSection('success_metrics')) ...[
            const SizedBox(height: 20),
            _buildSectionHeader('Success Metrics'),
            _buildSuccessMetricsSection(),
          ],

          // DARCI Roles section
          _buildDarciRolesSection(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(height: 6),
        Divider(color: Colors.grey.shade200, thickness: 1),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildContentCard(String content) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        content,
        style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.primaryColor,
              ),
            ),
          ),
          Expanded(child: Text(value, style: textTheme.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildTimelineSection() {
    final timeline = _prdData!['timeline'] as List;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            timeline.map<Widget>((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['time_period'] ?? 'No date specified',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['activity'] ?? 'No activity specified',
                      style: const TextStyle(fontSize: 15),
                    ),
                    if (item['pic'] != null &&
                        item['pic'].toString().isNotEmpty)
                      Text(
                        'PIC: ${item['pic']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildSuccessMetricsSection() {
    final metrics =
        _prdData!['generated_sections']?['success_metrics']?['metrics']
            as List?;

    if (metrics == null || metrics.isEmpty) {
      return _buildContentCard('No success metrics defined');
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            metrics.map<Widget>((metric) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metric['name'] ?? 'Unnamed Metric',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (metric['definition'] != null)
                      Text(
                        metric['definition'],
                        style: const TextStyle(fontSize: 15),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (metric['current'] != null)
                          Text(
                            'Current: ${metric['current']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        const SizedBox(width: 16),
                        if (metric['target'] != null)
                          Text(
                            'Target: ${metric['target']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildDarciRolesSection() {
    // First try to get DARCI roles from generated_sections
    final darciRolesFromGenerated = _prdModel?.darciRolesList;

    if (darciRolesFromGenerated != null && darciRolesFromGenerated.isNotEmpty) {
      return Column(
        children:
            darciRolesFromGenerated.map((role) {
              return Column(
                children: [
                  _buildDarciRoleCard(
                    role['name'] ?? 'Unknown Role',
                    (role['members'] as List?)?.join(', ') ?? 'None assigned',
                    role['guidelines'] ?? 'No guidelines provided',
                  ),
                  const SizedBox(height: 12),
                ],
              );
            }).toList(),
      );
    }

    // Fallback to old structure if generated sections don't have DARCI
    final darciRoles = _prdData!['darci_roles'] as Map<String, dynamic>?;

    if (darciRoles == null || darciRoles.isEmpty) {
      return _buildContentCard('No DARCI roles defined');
    }

    return Column(
      children: [
        if (darciRoles['decider'] != null)
          _buildDarciRoleCard(
            'Decider',
            _getListAsString(darciRoles['decider']),
            'Responsible for making final decisions on project direction and scope.',
          ),
        const SizedBox(height: 12),

        if (darciRoles['accountable'] != null)
          _buildDarciRoleCard(
            'Accountable',
            _getListAsString(darciRoles['accountable']),
            'Accountable for the successful delivery of the project.',
          ),
        const SizedBox(height: 12),

        if (darciRoles['responsible'] != null)
          _buildDarciRoleCard(
            'Responsible',
            _getListAsString(darciRoles['responsible']),
            'Responsible for implementing the project requirements.',
          ),
        const SizedBox(height: 12),

        if (darciRoles['consulted'] != null)
          _buildDarciRoleCard(
            'Consulted',
            _getListAsString(darciRoles['consulted']),
            'Consulted for expertise in specific areas of the project.',
          ),
        const SizedBox(height: 12),

        if (darciRoles['informed'] != null)
          _buildDarciRoleCard(
            'Informed',
            _getListAsString(darciRoles['informed']),
            'Kept informed about project progress and milestones.',
          ),
      ],
    );
  }

  Widget _buildDarciRoleCard(String role, String people, String guidelines) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            role,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(people, style: textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(
            guidelines,
            style: textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageDropdown() {
    final String stage = _prdData!['document_stage'] ?? 'draft';
    final Color badgeColor = _getStageBadgeColor(stage);

    return Container(
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: stage,
          isDense: true,
          borderRadius: BorderRadius.circular(8),
          icon: Icon(CupertinoIcons.chevron_down, size: 14, color: badgeColor),
          style: TextStyle(
            color: badgeColor,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          items: [
            DropdownMenuItem(
              value: 'draft',
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('Draft'),
              ),
            ),
            DropdownMenuItem(
              value: 'inprogress',
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('In Progress'),
              ),
            ),
            DropdownMenuItem(
              value: 'finished',
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('Finished'),
              ),
            ),
            DropdownMenuItem(
              value: 'archived',
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('Archived'),
              ),
            ),
          ],
          onChanged: _updatePrdStage,
        ),
      ),
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

  void _handleMenuAction(String action) async {
    final String id = widget.prdId;
    final prdController = Provider.of<PrdController>(context, listen: false);

    switch (action) {
      case 'pin':
        await _togglePinStatus();
        break;
      case 'edit':
        // Navigate to edit screen with full prdData
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PrdEditScreen(prdData: _prdData!),
          ),
        ).then((updatedData) {
          if (updatedData != null) {
            setState(() {
              _prdData = updatedData;
            });
          }
        });
        break;
      case 'download':
        try {
          final result = await prdController.downloadPrd(id);
          _showSnackBar('PDF generated successfully. Check your downloads.');
        } catch (e) {
          _showSnackBar('Failed to download PRD: $e', isError: true);
        }
        break;
      case 'archive':
        try {
          final bool isArchived = _prdData!['document_stage'] == 'archived';
          final result = await prdController.archivePrd(id);
          _showSnackBar(
            isArchived
                ? 'PRD unarchived successfully'
                : 'PRD archived successfully',
          );
          // Update local state
          setState(() {
            _prdData!['document_stage'] = result['document_stage'];
          });
        } catch (e) {
          _showSnackBar('Failed to archive PRD: $e', isError: true);
        }
        break;
      case 'delete':
        _showDeleteConfirmationDialog();
        break;
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete PRD'),
            content: Text(
              'Are you sure you want to delete "${_prdData!['product_name']}"? '
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
                  await _deletePrd();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  Future<void> _deletePrd() async {
    final prdController = Provider.of<PrdController>(context, listen: false);
    try {
      final result = await prdController.deletePrd(widget.prdId);
      if (result) {
        _showSnackBar('PRD deleted successfully');
        // Navigate to PRD list screen using AppRouter
        AppRouter.navigateToAllPrds(context);
      }
    } catch (e) {
      _showSnackBar('Failed to delete PRD: $e', isError: true);
    }
  }

  Future<void> _togglePinStatus() async {
    final prdController = Provider.of<PrdController>(context, listen: false);
    try {
      final bool isPinned = await prdController.togglePinPrd(widget.prdId);
      _showSnackBar(
        isPinned ? 'PRD pinned successfully' : 'PRD unpinned successfully',
      );
      // Update local state
      setState(() {
        _prdData!['is_pinned'] = isPinned;
      });
    } catch (e) {
      _showSnackBar('Failed to update pin status: $e', isError: true);
    }
  }

  Future<void> _updatePrdStage(String? newStage) async {
    if (newStage == null || newStage == _prdData!['document_stage']) return;

    final prdController = Provider.of<PrdController>(context, listen: false);
    try {
      final result = await prdController.updatePrdStage(widget.prdId, newStage);
      _showSnackBar('PRD stage updated to ${_getDisplayStage(newStage)}');
      // Update local state
      setState(() {
        _prdData!['document_stage'] = newStage;
      });
    } catch (e) {
      _showSnackBar('Failed to update PRD stage: $e', isError: true);
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

  // Helper methods for handling data
  String _getDocumentOwners() {
    if (_prdData!['document_owners'] == null) return 'Not specified';

    if (_prdData!['document_owners'] is List) {
      return (_prdData!['document_owners'] as List)
          .map((item) => item.toString())
          .join(', ');
    }

    return _prdData!['document_owners'].toString();
  }

  String _getListAsString(dynamic list) {
    if (list == null) return 'Not specified';

    if (list is List) {
      return list.map((item) => item.toString()).join(', ');
    }

    return list.toString();
  }

  bool _hasGeneratedSection(String sectionName) {
    return _prdData!['generated_sections'] != null &&
        _prdData!['generated_sections'][sectionName] != null;
  }

  String _getOverviewSectionContent(String title) {
    if (!_hasGeneratedSection('overview')) return 'No content available';

    final sections =
        _prdData!['generated_sections']['overview']['sections'] as List?;
    if (sections == null || sections.isEmpty) return 'No content available';

    // Find section with matching title
    for (final section in sections) {
      if (section['title'].toString().contains(title)) {
        return section['content'] ?? 'No content available';
      }
    }

    return 'No content available';
  }

  String _formatDate(dynamic dateString) {
    if (dateString == null) return 'Unknown date';

    try {
      final DateTime date = DateTime.parse(dateString.toString());
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  String _formatDateTime(dynamic dateString) {
    if (dateString == null) return 'Unknown date';

    try {
      final DateTime date = DateTime.parse(dateString.toString());
      return DateFormat('dd MMM yyyy HH:mm').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  Color _getStageBadgeColor(String? stage) {
    switch (stage?.toLowerCase()) {
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
}
