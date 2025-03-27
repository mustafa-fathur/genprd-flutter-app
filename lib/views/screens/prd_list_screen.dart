import 'package:flutter/material.dart';
import 'package:genprd/views/screens/prd_detail_screen.dart';

class PrdListScreen extends StatefulWidget {
  const PrdListScreen({super.key});

  @override
  State<PrdListScreen> createState() => _PrdListScreenState();
}

class _PrdListScreenState extends State<PrdListScreen> {
  String _selectedFilter = 'All Stage';
  final List<String> _filters = ['All Stage', 'Draft', 'Finished', 'Archived'];
  final TextEditingController _searchController = TextEditingController();
  
  // Mock data
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
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredPrds {
    if (_selectedFilter == 'All Stage') {
      return _prds;
    }
    return _prds.where((prd) => prd['stage'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PRDs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Profile action
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Product Requirement Documents',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // Search field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
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
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                        },
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Filter dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedFilter,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down),
                      elevation: 16,
                      style: const TextStyle(color: Colors.black),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedFilter = value!;
                        });
                      },
                      items: _filters.map<DropdownMenuItem<String>>((String value) {
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
          
          // PRD list
          Expanded(
            child: ListView.builder(
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
        ],
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
      case 'Finished':
        stageColor = Colors.green;
        break;
      case 'Archived':
        stageColor = Colors.blue;
        break;
      default:
        stageColor = Colors.grey;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PrdDetailScreen(title: title),
          ),
        );
      },
// Continuing with the _buildPrdItem method in prd_list_screen.dart
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
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
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: stageColor.withOpacity(0.2),
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
                  // Navigate to edit screen
                },
              ),
              ListTile(
                leading: Icon(Icons.download, color: Theme.of(context).primaryColor),
                title: const Text('Download PRD'),
                onTap: () {
                  Navigator.pop(context);
                  // Download PRD logic
                },
              ),
              ListTile(
                leading: Icon(Icons.archive, color: Theme.of(context).primaryColor),
                title: const Text('Archive PRD'),
                onTap: () {
                  Navigator.pop(context);
                  // Archive PRD logic
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
                Navigator.pop(context);
                // Delete PRD logic
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}