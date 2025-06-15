import 'package:flutter/material.dart';
import 'package:genprd/features/prd/views/widgets/section_header.dart';
import 'package:genprd/features/prd/views/widgets/content_card.dart';
import 'package:genprd/features/prd/views/widgets/info_card.dart';
import 'package:intl/intl.dart';

class OverviewTab extends StatelessWidget {
  final Map<String, dynamic> prdData;

  const OverviewTab({super.key, required this.prdData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PRD Identity section
          const SectionHeader(title: 'PRD Identity'),
          InfoCard(
            children: [
              InfoRow(
                label: 'Product Name:',
                value: prdData['product_name'] ?? 'Untitled',
              ),
              InfoRow(
                label: 'Document Version:',
                value: prdData['document_version'] ?? '1.0',
              ),
              InfoRow(label: 'Document Owner:', value: _getDocumentOwners()),
              InfoRow(
                label: 'Created Date:',
                value: _formatDate(prdData['created_at']),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Project Overview section
          const SectionHeader(title: 'Project Overview'),
          ContentCard(
            content: prdData['project_overview'] ?? 'No overview available',
          ),

          // Problem Statements section (if available)
          if (_hasGeneratedSection('overview')) ...[
            const SizedBox(height: 20),
            const SectionHeader(title: 'Problem Statements'),
            ContentCard(
              content: _getOverviewSectionContent('Problem Statement'),
            ),
          ],

          // Objectives section (if available)
          if (_hasGeneratedSection('overview')) ...[
            const SizedBox(height: 20),
            const SectionHeader(title: 'Objectives'),
            ContentCard(content: _getOverviewSectionContent('Objectives')),
          ],
        ],
      ),
    );
  }

  // Helper methods
  String _getDocumentOwners() {
    if (prdData['document_owners'] == null) return 'Not specified';

    if (prdData['document_owners'] is List) {
      return (prdData['document_owners'] as List)
          .map((item) => item.toString())
          .join(', ');
    }

    return prdData['document_owners'].toString();
  }

  bool _hasGeneratedSection(String sectionName) {
    return prdData['generated_sections'] != null &&
        prdData['generated_sections'][sectionName] != null;
  }

  String _getOverviewSectionContent(String title) {
    if (!_hasGeneratedSection('overview')) return 'No content available';

    final sections =
        prdData['generated_sections']['overview']['sections'] as List?;
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
}
