import 'package:flutter/material.dart';
import 'package:genprd/features/prd/views/widgets/edit_section_header.dart';
import 'package:genprd/features/prd/views/widgets/edit_darci_role.dart';

class EditDarciTab extends StatelessWidget {
  final Map<String, List<String>> darciRoles;
  final Map<String, String> darciGuidelines;
  final Function(String, List<String>) onRoleMembersChanged;
  final Function(String, String) onRoleGuidelinesChanged;
  final List<Map<String, dynamic>> availablePersonnel;

  const EditDarciTab({
    super.key,
    required this.darciRoles,
    required this.darciGuidelines,
    required this.onRoleMembersChanged,
    required this.onRoleGuidelinesChanged,
    required this.availablePersonnel,
  });

  @override
  Widget build(BuildContext context) {
    // Define the DARCI roles in order
    final rolesList = [
      'decider',
      'accountable',
      'responsible',
      'consulted',
      'informed',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const EditSectionHeader(title: 'DARCI Roles'),

          // Description text
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              'DARCI is a responsibility assignment framework that helps clarify roles and responsibilities for each team member.',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
          ),

          // DARCI roles
          ...rolesList.map((role) {
            return EditDarciRole(
              roleName: role,
              roleDescription: darciGuidelines[role] ?? '',
              selectedPersonnel: darciRoles[role] ?? [],
              onPersonnelChanged:
                  (members) => onRoleMembersChanged(role, members),
              onDescriptionChanged:
                  (description) => onRoleGuidelinesChanged(role, description),
              availablePersonnel: availablePersonnel,
              singleSelect: role == 'decider' || role == 'accountable',
            );
          }),
        ],
      ),
    );
  }
}
