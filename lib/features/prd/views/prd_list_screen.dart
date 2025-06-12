import 'package:flutter/material.dart';
import 'package:genprd/features/prd/views/prd_detail_screen.dart';
import 'package:genprd/features/prd/views/prd_form_screen.dart';
import 'package:genprd/features/prd/views/prd_edit_screen.dart';
import 'package:genprd/shared/widgets/loading_widget.dart';
import 'package:genprd/shared/config/themes/app_theme.dart';
import 'package:genprd/shared/widgets/screen_title_widget.dart';
import 'package:genprd/shared/views/main_layout.dart';

class PrdListScreen extends StatefulWidget {
  const PrdListScreen({super.key});

  @override
  State<PrdListScreen> createState() => _PrdListScreenState();
}

class _PrdListScreenState extends State<PrdListScreen> {
  final List<Map<String, dynamic>> _prds = [
    {
      'id': '1',
      'title': 'SIMSAPRAS',
      'description':
          'Management system for school facilities and infrastructure',
      'stage': 'In Progress',
      'updatedAt': 'Today',
    },
    {
      'id': '2',
      'title': 'SIRANCAK',
      'description': 'Integrated academic planning system for universities',
      'stage': 'Finished',
      'updatedAt': 'Today',
    },
    {
      'id': '3',
      'title': 'Gojek Lite',
      'description': 'Lightweight version of Gojek for low-end devices',
      'stage': 'Draft',
      'updatedAt': 'Yesterday',
    },
  ];

  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Draft',
    'In Progress',
    'Finished',
    'Archived',
  ];

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'All PRDs',
      selectedItem: NavigationItem.allPrds,
      child: _buildPrdListContent(),
    );
  }

  Widget _buildPrdListContent() {
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
                    prefixIcon: const Icon(Icons.search),
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
                    icon: const Icon(Icons.filter_list),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedFilter = newValue;
                        });
                      }
                    },
                    items:
                        _filters.map<DropdownMenuItem<String>>((String value) {
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
        // PRD list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: _prds.length,
            separatorBuilder:
                (context, index) => Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.shade200,
                ),
            itemBuilder: (context, index) {
              final prd = _prds[index];
              return _buildPrdListItem(prd);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPrdListItem(Map<String, dynamic> prd) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Get the appropriate color for the stage badge
    final Color badgeColor = AppTheme.badgeColors[prd['stage']] ?? Colors.grey;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PrdDetailScreen(prdId: prd['id']),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                  Icons.description_outlined,
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
                  Text(
                    prd['title'],
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    prd['description'],
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
                          prd['stage'],
                          style: textTheme.bodySmall?.copyWith(
                            color: badgeColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Updated at text
                      Text(
                        prd['updatedAt'],
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Chevron icon
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
