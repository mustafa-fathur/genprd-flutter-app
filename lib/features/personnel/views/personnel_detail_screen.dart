import 'package:flutter/material.dart';
import 'package:genprd/features/personnel/views/personnel_edit_screen.dart';
import 'package:genprd/shared/widgets/screen_title_widget.dart';

class PersonnelDetailScreen extends StatelessWidget {
  final Map<String, dynamic> person;

  const PersonnelDetailScreen({
    Key? key,
    required this.person,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personnel Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PersonnelEditScreen(person: person),
                ),
              ).then((_) => Navigator.pop(context)); // Return to personnel list after editing
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen title
              ScreenTitleWidget(
                title: person['name'],
                subtitle: person['role'],
              ),
              const SizedBox(height: 24),
              
              // Personnel avatar
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: primaryColor.withOpacity(0.1),
                  child: Text(
                    person['name'][0].toUpperCase(),
                    style: textTheme.displayMedium?.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Personnel info
              _buildInfoTile(
                context, 
                'Full Name', 
                person['name'], 
                Icons.person,
              ),
              const Divider(),
              
              _buildInfoTile(
                context, 
                'Role / Position', 
                person['role'], 
                Icons.work,
              ),
              const Divider(),
              
              _buildInfoTile(
                context, 
                'Contact', 
                person['contact'] ?? 'No contact information', 
                Icons.email,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final primaryColor = theme.colorScheme.primary;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: primaryColor,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
