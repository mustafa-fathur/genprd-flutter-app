import 'package:flutter/material.dart';
import 'package:genprd/views/screens/prd_detail_screen.dart';
import 'package:genprd/views/screens/prd_form_screen.dart';
import 'package:genprd/views/screens/prd_edit_screen.dart'; // Add this import
import 'package:genprd/views/shared/loading_widget.dart';
import 'package:intl/intl.dart'; // Add this import for DateFormat

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
  
  // Mock data - Updated to include "In Progress" example
  final List<Map<String, dynamic>> _prds = [
    {
      'title': 'SIMSAPRAS',
      'updated': '3/15/2023',
      'stage': 'Draft',
    },
    {
      'title': 'SIRANCAK',
      'updated': '3/15/2023',
      'stage': 'Finished',
    },
    {
      'title': 'Gojek Lite',
      'updated': '3/15/2023',
      'stage': 'Archived',
    },
    {
      'title': 'E-Commerce',
      'updated': '3/15/2023',
      'stage': 'Draft',
    },
    {
      'title': 'Travel App',
      'updated': '3/15/2023',
      'stage': 'Finished',
    },
    {
      'title': 'Food Delivery App',
      'updated': '3/18/2023',
      'stage': 'In Progress',
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
    return Scaffold(
      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Removed "Product Requirement Documents" heading
                
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search PRDs...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
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
                        vertical: 12,
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
                  height: 40,
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
                          backgroundColor: Colors.white,
                          selectedColor: Theme.of(context).primaryColor.withAlpha(30),
                          checkmarkColor: Theme.of(context).primaryColor,
                          labelStyle: TextStyle(
                            color: isSelected ? Theme.of(context).primaryColor : Colors.black,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
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
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredPrds.length,
                            itemBuilder: (context, index) {
                              final prd = _filteredPrds[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: _buildPrdItem(
                                  context,
                                  prd['title'],
                                  'Updated: ${prd['updated']}',
                                  prd['stage'],
                                ),
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
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPrdItem(
    BuildContext context,
    String title,
    String subtitle,
    String stage,
  ) {
    Color stageColor;
    
    switch (stage) {
      case 'Draft':
        stageColor = Colors.amber;
        break;
      case 'In Progress':
        stageColor = Colors.orange;
        break;
      case 'Finished':
        stageColor = Colors.green;
        break;
      case 'Archived':
        stageColor = Colors.blue;
        break;
      default:
        stageColor = Colors.grey;
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PrdDetailScreen(title: title),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, 4),
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
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: stageColor.withAlpha(30),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                stage,
                style: TextStyle(
                  color: stageColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                _showOptionsBottomSheet(context, title);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsBottomSheet(BuildContext context, String prdTitle) {
    // Get the current stage of the PRD
    final prd = _prds.firstWhere((p) => p['title'] == prdTitle);
    final currentStage = prd['stage'] as String;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                title: const Text('Edit PRD'),
                onTap: () {
                  Navigator.pop(context);
                  
                  // Use the new PrdEditScreen instead of PrdFormScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PrdEditScreen(
                        prdData: {
                          'title': prdTitle,
                          'version': '0.8.2',
                          'owner': 'Maha',
                          'stage': prd['stage'],
                          'startDate': '2025-01-01',
                          'endDate': '2025-12-31',
                          'overview': 'This is a project overview for $prdTitle. It describes the purpose, goals, and scope of the project.',
                          'problemStatements': 'The current system has several limitations:\n\n'
                              '1. Performance issues with large datasets\n'
                              '2. Limited mobile support\n'
                              '3. Lack of integration with other systems\n'
                              '4. Poor user experience',
                          'objectives': '1. Improve system performance by 50%\n'
                              '2. Develop a responsive mobile interface\n'
                              '3. Implement API integrations with key systems\n'
                              '4. Redesign the user interface for better UX',
                          'stakeholders': ['John Doe', 'Jane Smith'],
                          'developers': ['Mustafa Fathur Rahman', 'Fulana'],
                          'darci': {
                            'decisionMaker': 'John Doe',
                            'accountable': 'Jane Smith',
                            'responsible': ['Development Team'],
                            'consulted': ['UX Team', 'QA Team'],
                            'informed': ['Stakeholders'],
                          },
                          'successMetrics': '1. 50% improvement in system performance\n'
                              '2. 30% increase in mobile usage\n'
                              '3. 25% reduction in support tickets\n'
                              '4. 90% user satisfaction rating',
                          'timeline': 'January 1, 2025: Project Kickoff\n\n'
                              'January 15, 2025: Requirements Finalization\n\n'
                              'February 1, 2025: Design Phase Completion\n\n'
                              'March 1, 2025: Development Phase Completion\n\n'
                              'March 15, 2025: Testing Phase\n\n'
                              'April 1, 2025: Project Launch',
                        },
                      ),
                    ),
                  ).then((updatedData) {
                    if (updatedData != null && mounted) {
                      // Update the PRD with the new data
                      setState(() {
                        // Find and update the PRD in the list
                        final index = _prds.indexWhere((p) => p['title'] == prdTitle);
                        if (index != -1) {
                          // Update basic fields
                          _prds[index]['title'] = updatedData['title'];
                          _prds[index]['stage'] = updatedData['stage'];
                          _prds[index]['updated'] = DateFormat('MM/dd/yyyy').format(DateTime.now());
                        }
                        
                        // When returning from edit screen, update stage to In Progress if it was Draft
                        if (currentStage == 'Draft') {
                          prd['stage'] = 'In Progress';
                        }
                      });
                    }
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.download, color: Theme.of(context).primaryColor),
                title: const Text('Download PRD'),
                onTap: () {
                  Navigator.pop(context);
                  
                  // Update stage to Finished when downloading
                  setState(() {
                    prd['stage'] = 'Finished';
                  });
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Downloading PRD...')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.archive, color: Theme.of(context).primaryColor),
                title: const Text('Archive PRD'),
                onTap: () {
                  Navigator.pop(context);
                  // Update the PRD stage to 'Archived'
                  setState(() {
                    prd['stage'] = 'Archived';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PRD archived')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete PRD', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmationDialog(context, prdTitle);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String prdTitle) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete PRD'),
          content: Text('Are you sure you want to delete "$prdTitle"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _prds.removeWhere((prd) => prd['title'] == prdTitle);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PRD deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}