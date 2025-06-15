import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:genprd/features/prd/controllers/prd_controller.dart';
import 'package:genprd/features/prd/services/prd_service.dart';
import 'package:genprd/features/prd/views/prd_edit_screen.dart';
import 'package:genprd/shared/config/themes/app_theme.dart';
import 'package:genprd/shared/widgets/loading_widget.dart';
import 'package:genprd/shared/config/routes/app_router.dart';
import 'package:genprd/features/prd/models/prd_model.dart';
import 'package:genprd/features/prd/views/widgets/prd_detail_header.dart';
import 'package:genprd/features/prd/views/widgets/section_header.dart';
import 'package:genprd/features/prd/views/widgets/content_card.dart';
import 'package:genprd/features/prd/views/widgets/info_card.dart';
import 'package:genprd/features/prd/views/widgets/darci_role_card.dart';
import 'package:genprd/features/prd/views/widgets/timeline_item.dart';
import 'package:genprd/features/prd/views/widgets/success_metric_item.dart';
import 'package:genprd/features/prd/views/widgets/user_story_item.dart';
import 'package:intl/intl.dart';

class PrdDetailScreen extends StatefulWidget {
  final String prdId;

  const PrdDetailScreen({super.key, required this.prdId});

  @override
  State<PrdDetailScreen> createState() => _PrdDetailScreenState();
}

class _PrdDetailScreenState extends State<PrdDetailScreen> {
  final PrdService _prdService = PrdService();

  // State variables
  PrdModel? _prdModel;
  Map<String, dynamic>? _prdData;
  bool _isLoading = true;
  String? _error;

  // Section expansion states
  final Map<String, bool> _expandedSections = {
    'overview': true,
    'problem': true,
    'objectives': true,
    'team': true,
    'timeline': true,
    'user_stories': true,
    'success_metrics': true,
    'darci': true,
  };

  @override
  void initState() {
    super.initState();
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
        elevation: 0,
      ),
      body: Column(
        children: [
          // Status bar with stage selector
          PrdDetailHeader(
            version: _prdData!['document_version'] ?? '1.0',
            updatedAt: _prdData!['updated_at'] ?? '',
            currentStage: _prdData!['document_stage'] ?? 'draft',
            onStageChanged: _updatePrdStage,
          ),

          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PRD Identity section
                  _buildExpandableSection(
                    'PRD Identity',
                    'overview',
                    _buildPrdIdentitySection(),
                  ),

                  const SizedBox(height: 16),

                  // Project Overview section
                  _buildExpandableSection(
                    'Project Overview',
                    'overview',
                    ContentCard(
                      content:
                          _prdData!['project_overview'] ??
                          'No overview available',
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Problem Statements section
                  if (_hasGeneratedSectionContent(
                    'overview',
                    'Problem Statement',
                  )) ...[
                    _buildExpandableSection(
                      'Problem Statements',
                      'problem',
                      ContentCard(
                        content: _getOverviewSectionContent(
                          'Problem Statement',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Objectives section
                  if (_hasGeneratedSectionContent('overview', 'Objective')) ...[
                    _buildExpandableSection(
                      'Objectives',
                      'objectives',
                      ContentCard(
                        content: _getOverviewSectionContent('Objective'),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Team Members section
                  _buildExpandableSection(
                    'Team Members',
                    'team',
                    InfoCard(
                      children: [
                        InfoRow(
                          label: 'Document Owner:',
                          value: _getListAsString(_prdData!['document_owners']),
                        ),
                        InfoRow(
                          label: 'Stakeholders:',
                          value: _getListAsString(_prdData!['stakeholders']),
                        ),
                        InfoRow(
                          label: 'Developers:',
                          value: _getListAsString(_prdData!['developers']),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Timeline section
                  if (_hasTimeline()) ...[
                    _buildExpandableSection(
                      'Timeline',
                      'timeline',
                      _buildTimelineSection(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // User Stories section
                  if (_hasUserStories()) ...[
                    _buildExpandableSection(
                      'User Stories',
                      'user_stories',
                      _buildUserStoriesSection(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Success Metrics section
                  if (_hasSuccessMetrics()) ...[
                    _buildExpandableSection(
                      'Success Metrics',
                      'success_metrics',
                      _buildSuccessMetricsSection(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // DARCI Roles section
                  _buildExpandableSection(
                    'DARCI Roles',
                    'darci',
                    _buildDarciRolesSection(),
                  ),
                ],
              ),
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

  Widget _buildExpandableSection(
    String title,
    String sectionKey,
    Widget content,
  ) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Header with expand/collapse button
          InkWell(
            onTap: () {
              setState(() {
                _expandedSections[sectionKey] =
                    !(_expandedSections[sectionKey] ?? true);
              });
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  Icon(
                    _expandedSections[sectionKey] ?? true
                        ? CupertinoIcons.chevron_up
                        : CupertinoIcons.chevron_down,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),

          // Content (expandable)
          if (_expandedSections[sectionKey] ?? true)
            Padding(
              padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
              child: content,
            ),
        ],
      ),
    );
  }

  Widget _buildPrdIdentitySection() {
    return InfoCard(
      children: [
        InfoRow(
          label: 'Product Name:',
          value: _prdData!['product_name'] ?? 'Untitled',
        ),
        InfoRow(
          label: 'Document Version:',
          value: _prdData!['document_version'] ?? '1.0',
        ),
        InfoRow(
          label: 'Created Date:',
          value: _formatDate(_prdData!['created_at']),
        ),
        if (_prdData!['start_date'] != null)
          InfoRow(
            label: 'Start Date:',
            value: _prdData!['start_date'] ?? 'Not specified',
          ),
        if (_prdData!['end_date'] != null)
          InfoRow(
            label: 'End Date:',
            value: _prdData!['end_date'] ?? 'Not specified',
          ),
      ],
    );
  }

  Widget _buildTimelineSection() {
    final timeline = _prdData!['timeline'] as List;

    return Column(
      children:
          timeline.map((item) {
            return TimelineItem(
              timePeriod: item['time_period'] ?? 'No date specified',
              activity: item['activity'] ?? 'No activity specified',
              pic: item['pic'],
            );
          }).toList(),
    );
  }

  Widget _buildUserStoriesSection() {
    final userStories =
        _prdData!['generated_sections']?['user_stories']?['stories'] as List?;

    if (userStories == null || userStories.isEmpty) {
      return const ContentCard(content: 'No user stories defined');
    }

    return Column(
      children:
          userStories.map((story) {
            return UserStoryItem(
              title: story['title'] ?? 'Unnamed Story',
              userStory: story['user_story'] ?? 'No description',
              acceptanceCriteria: story['acceptance_criteria'],
              priority: story['priority'] ?? 'medium',
            );
          }).toList(),
    );
  }

  Widget _buildSuccessMetricsSection() {
    final metrics =
        _prdData!['generated_sections']?['success_metrics']?['metrics']
            as List?;

    if (metrics == null || metrics.isEmpty) {
      return const ContentCard(content: 'No success metrics defined');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          metrics.map((metric) {
            return SuccessMetricItem(
              name: metric['name'] ?? 'Unnamed Metric',
              definition: metric['definition'],
              current: metric['current']?.toString(),
              target: metric['target']?.toString(),
            );
          }).toList(),
    );
  }

  Widget _buildDarciRolesSection() {
    // First try to get DARCI roles from generated_sections
    final darciRolesFromGenerated =
        _prdData!['generated_sections']?['darci']?['roles'] as List?;

    if (darciRolesFromGenerated != null && darciRolesFromGenerated.isNotEmpty) {
      return Column(
        children:
            darciRolesFromGenerated.map((role) {
              return DarciRoleCard(
                role: role['name'] ?? 'Unknown Role',
                people:
                    (role['members'] as List?)?.join(', ') ?? 'None assigned',
                guidelines: role['guidelines'] ?? 'No guidelines provided',
              );
            }).toList(),
      );
    }

    // Fallback to old structure
    final darciRoles = _prdData!['darci_roles'] as Map<String, dynamic>?;

    if (darciRoles == null || darciRoles.isEmpty) {
      return const ContentCard(content: 'No DARCI roles defined');
    }

    return Column(
      children: [
        if (darciRoles['decider'] != null)
          DarciRoleCard(
            role: 'Decider',
            people: _getListAsString(darciRoles['decider']),
            guidelines:
                'Responsible for making final decisions on project direction and scope.',
          ),

        if (darciRoles['accountable'] != null)
          DarciRoleCard(
            role: 'Accountable',
            people: _getListAsString(darciRoles['accountable']),
            guidelines:
                'Accountable for the successful delivery of the project.',
          ),

        if (darciRoles['responsible'] != null)
          DarciRoleCard(
            role: 'Responsible',
            people: _getListAsString(darciRoles['responsible']),
            guidelines:
                'Responsible for implementing the project requirements.',
          ),

        if (darciRoles['consulted'] != null)
          DarciRoleCard(
            role: 'Consulted',
            people: _getListAsString(darciRoles['consulted']),
            guidelines:
                'Consulted for expertise in specific areas of the project.',
          ),

        if (darciRoles['informed'] != null)
          DarciRoleCard(
            role: 'Informed',
            people: _getListAsString(darciRoles['informed']),
            guidelines: 'Kept informed about project progress and milestones.',
          ),
      ],
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

      // Update local state
      setState(() {
        _prdData!['document_stage'] = newStage;
      });

      // Show success message
      _showSnackBar('PRD stage updated to ${_getDisplayStage(newStage)}');
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

  // Helper methods
  bool _hasTimeline() {
    return _prdData!['timeline'] != null &&
        (_prdData!['timeline'] as List).isNotEmpty;
  }

  bool _hasUserStories() {
    return _prdData!['generated_sections'] != null &&
        _prdData!['generated_sections']['user_stories'] != null &&
        _prdData!['generated_sections']['user_stories']['stories'] != null &&
        (_prdData!['generated_sections']['user_stories']['stories'] as List)
            .isNotEmpty;
  }

  bool _hasSuccessMetrics() {
    return _prdData!['generated_sections'] != null &&
        _prdData!['generated_sections']['success_metrics'] != null &&
        _prdData!['generated_sections']['success_metrics']['metrics'] != null &&
        (_prdData!['generated_sections']['success_metrics']['metrics'] as List)
            .isNotEmpty;
  }

  bool _hasGeneratedSectionContent(String sectionName, String title) {
    if (_prdData!['generated_sections'] == null ||
        _prdData!['generated_sections'][sectionName] == null ||
        _prdData!['generated_sections'][sectionName]['sections'] == null) {
      return false;
    }

    final sections =
        _prdData!['generated_sections'][sectionName]['sections'] as List;
    return sections.any(
      (section) =>
          section['title'] != null &&
          section['title'].toString().contains(title) &&
          section['content'] != null &&
          section['content'].toString().isNotEmpty,
    );
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

  bool _hasGeneratedSection(String sectionName) {
    return _prdData!['generated_sections'] != null &&
        _prdData!['generated_sections'][sectionName] != null;
  }

  String _getListAsString(dynamic list) {
    if (list == null) return 'Not specified';

    if (list is List) {
      return list.map((item) => item.toString()).join(', ');
    }

    return list.toString();
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
}
