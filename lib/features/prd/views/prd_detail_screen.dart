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
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:genprd/shared/utils/platform_helper.dart';

// Embedded widgets (previously in separate files)
class PrdDetailHeader extends StatelessWidget {
  final String version;
  final String updatedAt;
  final String currentStage;
  final Function(String?) onStageChanged;

  const PrdDetailHeader({
    super.key,
    required this.version,
    required this.updatedAt,
    required this.currentStage,
    required this.onStageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final screenPadding = PlatformHelper.getScreenPadding(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
        screenPadding.left,
        12,
        screenPadding.right,
        12,
      ),
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
                  'Version $version',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  'Last Updated: ${_formatDateTime(updatedAt)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          _buildStageSelector(context),
        ],
      ),
    );
  }

  Widget _buildStageSelector(BuildContext context) {
    final Color badgeColor = _getStageBadgeColor(currentStage);
    final String displayStage = _getDisplayStage(currentStage);

    return Container(
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: badgeColor.withOpacity(0.3), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentStage,
          isDense: true,
          borderRadius: BorderRadius.circular(8),
          icon: Icon(CupertinoIcons.chevron_down, size: 14, color: badgeColor),
          style: TextStyle(
            color: badgeColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          items: [
            _buildDropdownItem('draft', 'Draft'),
            _buildDropdownItem('inprogress', 'In Progress'),
            _buildDropdownItem('finished', 'Finished'),
            _buildDropdownItem('archived', 'Archived'),
          ],
          onChanged: onStageChanged,
        ),
      ),
    );
  }

  DropdownMenuItem<String> _buildDropdownItem(String value, String label) {
    final Color badgeColor = _getStageBadgeColor(value);

    return DropdownMenuItem(
      value: value,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          label,
          style: TextStyle(color: badgeColor, fontWeight: FontWeight.w600),
        ),
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

  String _formatDateTime(String dateString) {
    if (dateString.isEmpty) return 'Unknown date';

    try {
      final DateTime date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy HH:mm').format(date);
    } catch (e) {
      return 'Invalid date';
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
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
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
}

class ContentCard extends StatelessWidget {
  final String content;
  final EdgeInsetsGeometry? padding;
  final double? elevation;

  const ContentCard({
    super.key,
    required this.content,
    this.padding,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: elevation ?? 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: Text(
          content,
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final double? elevation;

  const InfoCard({
    super.key,
    required this.children,
    this.padding,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation ?? 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final double? labelWidth;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.labelWidth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth ?? 130,
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
}

class DarciRoleCard extends StatelessWidget {
  final String role;
  final String people;
  final String guidelines;

  const DarciRoleCard({
    super.key,
    required this.role,
    required this.people,
    required this.guidelines,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Minimalist: use only a simple icon, no colored background
    final IconData roleIcon = _getRoleIcon(role);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Minimalist role title with icon
            Row(
              children: [
                Icon(roleIcon, color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  _capitalizeRole(role),
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // People assigned to this role
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    'People:',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(child: Text(people, style: textTheme.bodyMedium)),
              ],
            ),
            const SizedBox(height: 8),
            // Role guidelines
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    'Guidelines:',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(child: Text(guidelines, style: textTheme.bodyMedium)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _capitalizeRole(String role) {
    if (role.isEmpty) return role;
    switch (role.toLowerCase()) {
      case 'decider':
        return 'Decider (D)';
      case 'accountable':
        return 'Accountable (A)';
      case 'responsible':
        return 'Responsible (R)';
      case 'consulted':
        return 'Consulted (C)';
      case 'informed':
        return 'Informed (I)';
      default:
        return '${role[0].toUpperCase()}${role.substring(1).toLowerCase()}';
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'decider':
        return Icons.verified_user_outlined;
      case 'accountable':
        return Icons.account_circle_outlined;
      case 'responsible':
        return Icons.assignment_turned_in_outlined;
      case 'consulted':
        return Icons.chat_bubble_outline;
      case 'informed':
        return Icons.info_outline;
      default:
        return Icons.person_outline;
    }
  }
}

class TimelineItem extends StatelessWidget {
  final String timePeriod;
  final String activity;
  final String? pic;

  const TimelineItem({
    super.key,
    required this.timePeriod,
    required this.activity,
    this.pic,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              Container(width: 2, height: 40, color: Colors.grey.shade300),
            ],
          ),
          const SizedBox(width: 16),
          // Timeline content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timePeriod,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(activity, style: const TextStyle(fontSize: 15)),
                if (pic != null && pic!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'PIC: $pic',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SuccessMetricItem extends StatelessWidget {
  final String name;
  final String? definition;
  final String? current;
  final String? target;

  const SuccessMetricItem({
    super.key,
    required this.name,
    this.definition,
    this.current,
    this.target,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Metric name
            Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),

            // Definition
            if (definition != null && definition!.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 100,
                    child: Text(
                      'Definition:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    child: Text(definition!, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Current value
            if (current != null && current!.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 100,
                    child: Text(
                      'Current:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    child: Text(current!, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Target value
            if (target != null && target!.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 100,
                    child: Text(
                      'Target:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      target!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class UserStoryItem extends StatelessWidget {
  final String title;
  final String userStory;
  final String? acceptanceCriteria;
  final String priority;

  const UserStoryItem({
    super.key,
    required this.title,
    required this.userStory,
    this.acceptanceCriteria,
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
                _buildPriorityBadge(context),
              ],
            ),
            const SizedBox(height: 12),

            // User story
            Text(
              'User Story:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(userStory, style: theme.textTheme.bodyMedium),

            // Acceptance criteria
            if (acceptanceCriteria != null &&
                acceptanceCriteria!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Acceptance Criteria:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(acceptanceCriteria!, style: theme.textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(BuildContext context) {
    Color badgeColor;

    switch (priority.toLowerCase()) {
      case 'high':
        badgeColor = Colors.red.shade700;
        break;
      case 'medium':
        badgeColor = Colors.amber.shade700;
        break;
      case 'low':
        badgeColor = Colors.green.shade700;
        break;
      default:
        badgeColor = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(
          color: badgeColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

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
          'deadline': data.deadline?.toIso8601String(),
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
              padding: PlatformHelper.getScreenPadding(
                context,
              ).copyWith(top: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. PRD Identity section (including team members)
                  _buildExpandableSection(
                    'PRD Identity',
                    'identity',
                    Column(
                      children: [
                        InfoCard(
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
                            if (_prdData!['deadline'] != null)
                              InfoRow(
                                label: 'Deadline:',
                                value: _formatDate(_prdData!['deadline']),
                              ),
                            if (_prdData!['start_date'] != null)
                              InfoRow(
                                label: 'Start Date:',
                                value:
                                    _prdData!['start_date'] ?? 'Not specified',
                              ),
                            if (_prdData!['end_date'] != null)
                              InfoRow(
                                label: 'End Date:',
                                value: _prdData!['end_date'] ?? 'Not specified',
                              ),
                            InfoRow(
                              label: 'Document Owner:',
                              value: _getListAsString(
                                _prdData!['document_owners'],
                              ),
                            ),
                            InfoRow(
                              label: 'Stakeholders:',
                              value: _getListAsString(
                                _prdData!['stakeholders'],
                              ),
                            ),
                            InfoRow(
                              label: 'Developers:',
                              value: _getListAsString(_prdData!['developers']),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2. Project Overview section
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

                  // 3. Problem Statements section
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

                  // 4. Objectives section
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

                  // 5. DARCI Roles section
                  _buildExpandableSection(
                    'DARCI Roles',
                    'darci',
                    _buildDarciRolesSection(),
                  ),

                  const SizedBox(height: 16),

                  // 6. Success Metrics section
                  if (_hasSuccessMetrics()) ...[
                    _buildExpandableSection(
                      'Success Metrics',
                      'success_metrics',
                      _buildSuccessMetricsSection(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 7. User Stories section
                  if (_hasUserStories()) ...[
                    _buildExpandableSection(
                      'User Stories',
                      'user_stories',
                      _buildUserStoriesSection(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 8. Timeline section
                  if (_hasTimeline()) ...[
                    _buildExpandableSection(
                      'Timeline',
                      'timeline',
                      _buildTimelineSection(),
                    ),
                  ],
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
          // Show loading indicator
          _showSnackBar('Downloading PDF...', isError: false);

          final result = await prdController.downloadPrd(id);
          final filePath = result['local_file_path'] as String?;
          final fileName = result['file_name'] as String?;

          if (filePath != null) {
            _showSnackBar('PDF downloaded successfully: ${fileName ?? 'file'}');

            // Optional: Show dialog to open file
            _showOpenFileDialog(filePath, fileName ?? 'PRD');
          } else {
            _showSnackBar(
              'Download completed but file path not found',
              isError: true,
            );
          }
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

  void _showOpenFileDialog(String filePath, String fileName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Download Complete'),
          content: Text('$fileName has been downloaded successfully.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await OpenFile.open(filePath);
                } catch (e) {
                  _showSnackBar('Could not open file: $e', isError: true);
                }
              },
              child: Text('Open File'),
            ),
          ],
        );
      },
    );
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
