import 'package:flutter/material.dart';
import 'package:genprd/shared/widgets/loading_widget.dart';

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
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
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
                  hintText: 'Search personnel...',
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
                        : ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: _filteredPersonnel.length,
                            itemBuilder: (context, index) {
                              final person = _filteredPersonnel[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: _buildPersonnelCard(context, person, index),
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
          _showAddEditPersonnelDialog(context);
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPersonnelCard(BuildContext context, Map<String, dynamic> person, int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    
    final color = colors[index % colors.length];
    
    // Updated card style to match PRD items
    return InkWell(
      onTap: () {
        // Show personnel details
        _showAddEditPersonnelDialog(context, person: person, readOnly: true);
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
            CircleAvatar(
              backgroundColor: color,
              child: Text(
                person['name'][0],
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    person['role'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.more_vert),
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
                leading: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                title: const Text('Edit Personnel'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddEditPersonnelDialog(context, person: person);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Personnel', style: TextStyle(color: Colors.red)),
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

  void _showAddEditPersonnelDialog(
    BuildContext context, {
    Map<String, dynamic>? person,
    bool readOnly = false,
  }) {
    final isEditing = person != null && !readOnly;
    final isViewing = person != null && readOnly;
    
    final nameController = TextEditingController(text: person?['name'] ?? '');
    final roleController = TextEditingController(text: person?['role'] ?? '');
    final contactController = TextEditingController(text: person?['contact'] ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isViewing
              ? 'Personnel Details'
              : isEditing
                  ? 'Edit Personnel'
                  : 'Add Personnel',
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isViewing)
                const Text('Add a new personnel for the PRD system'),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: !readOnly
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            nameController.clear();
                          },
                        )
                      : null,
                ),
                readOnly: readOnly,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: roleController,
                decoration: InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: !readOnly
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            roleController.clear();
                          },
                        )
                      : null,
                ),
                readOnly: readOnly,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contactController,
                decoration: InputDecoration(
                  labelText: 'Contact',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: !readOnly
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            contactController.clear();
                          },
                        )
                      : null,
                ),
                readOnly: readOnly,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          if (!readOnly)
            TextButton(
              onPressed: () {
                if (nameController.text.isEmpty || roleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Name and Role are required'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                // In a real app, you would save the data to your backend
                setState(() {
                  if (isEditing) {
                    // Update existing personnel
                    person['name'] = nameController.text;
                    person['role'] = roleController.text;
                    person['contact'] = contactController.text;
                  } else {
                    // Add new personnel
                    _personnel.add({
                      'name': nameController.text,
                      'role': roleController.text,
                      'contact': contactController.text,
                    });
                  }
                });
                
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isEditing
                          ? 'Personnel updated successfully'
                          : 'Personnel added successfully',
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                );
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
        ],
      ),
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