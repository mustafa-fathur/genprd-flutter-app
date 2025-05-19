import 'package:flutter/material.dart';
import 'package:genprd/features/personnel/views/personnel_add_screen.dart';
import 'package:genprd/features/personnel/views/personnel_detail_screen.dart';
import 'package:genprd/features/personnel/views/personnel_edit_screen.dart';
import 'package:genprd/shared/widgets/loading_widget.dart';
import 'package:genprd/shared/widgets/screen_title_widget.dart';

class PersonnelListScreen extends StatefulWidget {
  const PersonnelListScreen({super.key});

  @override
  State<PersonnelListScreen> createState() => _PersonnelListScreenState();
}

class _PersonnelListScreenState extends State<PersonnelListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  
  // Mock data
  final List<Map<String, dynamic>> _personnel = [
    {
      'name': 'Fulan',
      'role': 'AI Engineer',
      'contact': 'fulan@example.com',
    },
    {
      'name': 'Fulana',
      'role': 'Software Engineer',
      'contact': 'fulana@example.com',
    },
    {
      'name': 'Mustafa Fathur Rahman',
      'role': 'Developer',
      'contact': 'mustafa@example.com',
    },
    {
      'name': 'John Doe',
      'role': 'Product Manager',
      'contact': 'john@example.com',
    },
    {
      'name': 'Jane Smith',
      'role': 'Designer',
      'contact': 'jane@example.com',
    },
  ];

  List<Map<String, dynamic>> get _filteredPersonnel {
    if (_searchController.text.isEmpty) {
      return _personnel;
    }
    
    final query = _searchController.text.toLowerCase();
    return _personnel.where((person) {
      return person['name'].toLowerCase().contains(query) ||
             person['role'].toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Title and Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Screen Title
                ScreenTitleWidget(
                  title: 'Personnel',
                  subtitle: 'Manage team members and roles',
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
                      hintText: 'Search personnel...',
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
              ],
            ),
          ),
          
          // Personnel list
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
                    child: _filteredPersonnel.isEmpty
                        ? const Center(
                            child: Text('No personnel found'),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            itemCount: _filteredPersonnel.length,
                            separatorBuilder: (context, index) => Divider(
                              height: 1,
                              thickness: 0.5,
                              indent: 72,
                              color: Colors.grey.shade200,
                            ),
                            itemBuilder: (context, index) {
                              final person = _filteredPersonnel[index];
                              return _buildPersonnelItem(context, person);
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
            MaterialPageRoute(
              builder: (context) => PersonnelAddScreen(onSave: (newPerson) {
                setState(() {
                  _personnel.add(newPerson);
                });
              }),
            ),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }

  Widget _buildPersonnelItem(BuildContext context, Map<String, dynamic> person) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final primaryColor = theme.colorScheme.primary;
    
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PersonnelDetailScreen(person: person),
          ),
        );
      },
      splashColor: primaryColor.withOpacity(0.1),
      highlightColor: primaryColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: primaryColor.withOpacity(0.1),
              radius: 20,
              child: Text(
                person['name'][0].toUpperCase(),
                style: textTheme.titleMedium?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person['name'],
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    person['role'],
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.more_vert,
                color: Colors.grey.shade600,
                size: 20,
              ),
              onPressed: () {
                _showOptionsMenu(context, person);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showOptionsMenu(BuildContext context, Map<String, dynamic> person) {
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
                title: const Text('Edit Personnel'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PersonnelEditScreen(person: person),
                    ),
                  ).then((_) => setState(() {})); // Refresh list after returning
                },
              ),
              ListTile(
                title: const Text('Delete Personnel'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmationDialog(context, person);
                },
              ),
            ],
          ),
        );
      },
    );
  }



  void _showDeleteConfirmationDialog(BuildContext context, Map<String, dynamic> person) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Personnel'),
        content: Text('Are you sure you want to delete "${person['name']}"?'),
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
                _personnel.remove(person);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Personnel deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}