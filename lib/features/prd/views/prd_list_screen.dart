import 'package:flutter/material.dart';
import 'package:genprd/features/prd/views/prd_detail_screen.dart';
import 'package:genprd/features/prd/views/prd_form_screen.dart';
import 'package:genprd/features/prd/views/prd_edit_screen.dart';
import 'package:genprd/shared/widgets/loading_widget.dart';
import 'package:genprd/shared/config/themes/app_theme.dart';
import 'package:genprd/shared/widgets/screen_title_widget.dart';

class PrdListScreen extends StatefulWidget {
  const PrdListScreen({super.key});

  @override
  State<PrdListScreen> createState() => _PrdListScreenState();
}

class _PrdListScreenState extends State<PrdListScreen> {
  String _selectedFilter = 'All Stage';
  final List<String> _filters = ['All Stage', 'Draft', 'In Progress', 'Finished', 'Archived'];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  
  // Mock data - One example for each status
  final List<Map<String, dynamic>> _prds = [
    {
      'title': 'Customer Feedback Portal',
      'updated': '3/15/2023',
      'stage': 'Draft',
    },
    {
      'title': 'Mobile Payment App',
      'updated': '4/18/2023',
      'stage': 'In Progress',
    },
    {
      'title': 'E-commerce Platform',
      'updated': '2/10/2023',
      'stage': 'Finished',
    },
    {
      'title': 'Legacy CRM System',
      'updated': '1/05/2023',
      'stage': 'Archived',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredPrds {
    if (_selectedFilter == 'All Stage' && _searchController.text.isEmpty) {
      return _prds;
    }
    
    return _prds.where((prd) {
      final matchesStage = _selectedFilter == 'All Stage' || prd['stage'] == _selectedFilter;
      final matchesSearch = _searchController.text.isEmpty || 
                           prd['title'].toLowerCase().contains(_searchController.text.toLowerCase());
      return matchesStage && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get the current theme
    final textTheme = theme.textTheme; // Get the text theme

    return Scaffold(
      body: Column(
        children: [
          // Title and Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Screen Title
                ScreenTitleWidget(
                  title: 'Product Requirement Documents',
                  subtitle: 'Manage and view all PRDs',
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search PRDs...',
                      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey[500], size: 18),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Filter chips
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      final isSelected = _selectedFilter == filter;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = selected ? filter : 'All Stage';
                            });
                          },
                          backgroundColor: Colors.transparent,
                          side: BorderSide(color: isSelected ? theme.colorScheme.primary : Colors.grey.shade300),
                          selectedColor: theme.colorScheme.primary.withOpacity(0.12),
                          checkmarkColor: theme.colorScheme.primary,
                          visualDensity: VisualDensity.compact,
                          labelStyle: textTheme.labelMedium?.copyWith(
                            color: isSelected ? theme.colorScheme.primary : Colors.grey[700],
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // PRD list
          Expanded(
            child: _isLoading
                ? const LoadingWidget()
                : RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      
                      // Simulate API call
                      await Future.delayed(const Duration(seconds: 1));
                      
                      setState(() {
                        _isLoading = false;
                      });
                    },
                    child: _filteredPrds.isEmpty
                        ? const Center(
                            child: Text('No PRDs found'),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            itemCount: _filteredPrds.length,
                            separatorBuilder: (context, index) => Divider(
                              height: 1,
                              thickness: 0.5,
                              indent: 72,
                              color: Colors.grey.shade200,
                            ),
                            itemBuilder: (context, index) {
                              final prd = _filteredPrds[index];
                              return _buildPrdItem(
                                context,
                                prd['title'],
                                'Updated: ${prd['updated']}',
                                prd['stage'],
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
      // Add FAB at bottom right corner
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PrdFormScreen()),
          );
        },
        backgroundColor: theme.colorScheme.primary, // Use primary color from theme
        child: const Icon(Icons.add, color: Colors.white), // Keep white icon
      ),
    );
  }

  Widget _buildPrdItem(
    BuildContext context,
    String title,
    String subtitle,
    String stage,
  ) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final primaryColor = theme.colorScheme.primary;
    Color stageColor = AppTheme.badgeColors[stage] ?? Colors.grey;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PrdDetailScreen(title: title),
          ),
        );
      },
      splashColor: theme.colorScheme.primary.withOpacity(0.1),
      highlightColor: theme.colorScheme.primary.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: primaryColor.withOpacity(0.1),
              radius: 20,
              child: Icon(
                Icons.description,
                color: primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: stageColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                stage,
                style: textTheme.bodySmall?.copyWith(
                  color: stageColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(
                Icons.more_vert,
                color: Colors.grey.shade600,
                size: 20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: 24,
              onPressed: () {
                _showOptionsMenu(context, title, stage);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showConfirmationDialog(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
            ),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: TextButton.styleFrom(
              foregroundColor: primaryColor,
            ),
            child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu(BuildContext context, String title, String stage) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              ListTile(
                title: const Text('View Details'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PrdDetailScreen(title: title),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('Edit PRD'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => PrdEditScreen(
                        prdData: {'title': title, 'stage': stage},
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('Archive PRD'),
                onTap: () {
                  Navigator.pop(context);
                  _showConfirmationDialog(
                    context, 
                    'Archive PRD', 
                    'Are you sure you want to archive "$title"?',
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$title archived'),
                          backgroundColor: primaryColor,
                        ),
                      );
                    },
                  );
                },
              ),
              ListTile(
                title: const Text('Delete PRD'),
                onTap: () {
                  Navigator.pop(context);
                  _showConfirmationDialog(
                    context, 
                    'Delete PRD', 
                    'Are you sure you want to delete "$title"? This action cannot be undone.',
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$title deleted'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}