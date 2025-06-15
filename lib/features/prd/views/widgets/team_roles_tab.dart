import 'package:flutter/material.dart';
import 'package:genprd/features/prd/models/prd_model.dart';
import 'package:genprd/features/prd/views/widgets/section_header.dart';
import 'package:genprd/features/prd/views/widgets/info_card.dart';
import 'package:genprd/features/prd/views/widgets/darci_role_card.dart';
import 'package:genprd/features/prd/views/widgets/timeline_item.dart';
import 'package:genprd/features/prd/views/widgets/success_metric_item.dart';

class TeamRolesTab extends StatelessWidget {
  final Map<String, dynamic> prdData;
  final PrdModel? prdModel;

  const TeamRolesTab({super.key, required this.prdData, this.prdModel});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Team Members section
          const SectionHeader(title: 'Team Members'),
          InfoCard(
            children: [
              InfoRow(
                label: 'Document Owner:',
                value: _getListAsString(prdData['document_owners']),
              ),
              InfoRow(
                label: 'Stakeholders:',
                value: _getListAsString(prdData['stakeholders']),
              ),
              InfoRow(
                label: 'Developers:',
                value: _getListAsString(prdData['developers']),
              ),
            ],
          ),

          // Timeline section
          if (_hasTimeline()) ...[
            const SizedBox(height: 20),
            const SectionHeader(title: 'Timeline'),
            _buildTimelineSection(),
          ],

          // Success Metrics section
          if (_hasGeneratedSection('success_metrics')) ...[
            const SizedBox(height: 20),
            const SectionHeader(title: 'Success Metrics'),
            _buildSuccessMetricsSection(),
          ],

          // DARCI Roles section
          const SizedBox(height: 20),
          const SectionHeader(title: 'DARCI Roles'),
          _buildDarciRolesSection(),
        ],
      ),
    );
  }

  // Helper methods
  bool _hasTimeline() {
    return prdData['timeline'] != null &&
        (prdData['timeline'] as List).isNotEmpty;
  }

  bool _hasGeneratedSection(String sectionName) {
    return prdData['generated_sections'] != null &&
        prdData['generated_sections'][sectionName] != null;
  }

  String _getListAsString(dynamic list) {
    if (list == null) return 'Not specified';

    if (list is List) {
      return list.map((item) => item.toString()).join(', ');
    }

    return list.toString();
  }

  Widget _buildTimelineSection() {
    final timeline = prdData['timeline'] as List;
    final lastIndex = timeline.length - 1;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children:
              timeline.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;

                return TimelineItem(
                  timePeriod: item['time_period'] ?? 'No date specified',
                  activity: item['activity'] ?? 'No activity specified',
                  pic: item['pic'],
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildSuccessMetricsSection() {
    final metrics =
        prdData['generated_sections']?['success_metrics']?['metrics'] as List?;

    if (metrics == null || metrics.isEmpty) {
      return Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('No success metrics defined'),
        ),
      );
    }

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
        ),
      ),
    );
  }

  Widget _buildDarciRolesSection() {
    // First try to get DARCI roles from PrdModel
    final darciRolesFromModel = prdModel?.darciRolesList;

    if (darciRolesFromModel != null && darciRolesFromModel.isNotEmpty) {
      return Column(
        children:
            darciRolesFromModel.map((role) {
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
    final darciRoles = prdData['darci_roles'] as Map<String, dynamic>?;

    if (darciRoles == null || darciRoles.isEmpty) {
      return Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('No DARCI roles defined'),
        ),
      );
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
}
