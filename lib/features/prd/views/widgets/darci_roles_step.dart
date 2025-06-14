import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class DarciRolesStep extends StatelessWidget {
  final List<String> deciderRoles;
  final List<String> accountableRoles;
  final List<String> responsibleRoles;
  final List<String> consultedRoles;
  final List<String> informedRoles;
  final Function(
    String title,
    List<String> selectedPersonnel,
    Function(List<String>) onSave,
  )
  showPersonnelSelectionDialog;
  final Function(List<String>) updateDeciderRoles;
  final Function(List<String>) updateAccountableRoles;
  final Function(List<String>) updateResponsibleRoles;
  final Function(List<String>) updateConsultedRoles;
  final Function(List<String>) updateInformedRoles;

  const DarciRolesStep({
    super.key,
    required this.deciderRoles,
    required this.accountableRoles,
    required this.responsibleRoles,
    required this.consultedRoles,
    required this.informedRoles,
    required this.showPersonnelSelectionDialog,
    required this.updateDeciderRoles,
    required this.updateAccountableRoles,
    required this.updateResponsibleRoles,
    required this.updateConsultedRoles,
    required this.updateInformedRoles,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Define roles and responsibilities',
            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          // DARCI Framework compact explanation
          _buildDarciExplanation(context),
          const SizedBox(height: 20),

          // Decider role
          _buildRoleSection(
            context: context,
            title: 'Decider (D) *',
            icon: CupertinoIcons.hammer,
            description: 'Makes final decisions',
            selectedMembers: deciderRoles,
            onTap: () {
              showPersonnelSelectionDialog(
                'Select Decider',
                deciderRoles,
                updateDeciderRoles,
              );
            },
          ),
          const SizedBox(height: 16),

          // Accountable role
          _buildRoleSection(
            context: context,
            title: 'Accountable (A) *',
            icon: CupertinoIcons.person_crop_circle_badge_checkmark,
            description: 'Ultimately responsible',
            selectedMembers: accountableRoles,
            onTap: () {
              showPersonnelSelectionDialog(
                'Select Accountable Person',
                accountableRoles,
                updateAccountableRoles,
              );
            },
          ),
          const SizedBox(height: 16),

          // Responsible role
          _buildRoleSection(
            context: context,
            title: 'Responsible (R) *',
            icon: CupertinoIcons.person_crop_circle_fill_badge_checkmark,
            description: 'Does the work',
            selectedMembers: responsibleRoles,
            onTap: () {
              showPersonnelSelectionDialog(
                'Select Responsible Members',
                responsibleRoles,
                updateResponsibleRoles,
              );
            },
          ),
          const SizedBox(height: 16),

          // Consulted role
          _buildRoleSection(
            context: context,
            title: 'Consulted (C)',
            icon: CupertinoIcons.bubble_left,
            description: 'Provides input',
            selectedMembers: consultedRoles,
            onTap: () {
              showPersonnelSelectionDialog(
                'Select Consulted Members',
                consultedRoles,
                updateConsultedRoles,
              );
            },
          ),
          const SizedBox(height: 16),

          // Informed role
          _buildRoleSection(
            context: context,
            title: 'Informed (I)',
            icon: CupertinoIcons.info_circle,
            description: 'Kept updated',
            selectedMembers: informedRoles,
            onTap: () {
              showPersonnelSelectionDialog(
                'Select Informed Members',
                informedRoles,
                updateInformedRoles,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDarciExplanation(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.info_circle,
            color: theme.colorScheme.primary,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'DARCI defines project responsibilities and decision-making roles',
              style: TextStyle(fontSize: 13, color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String description,
    required List<String> selectedMembers,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(icon, color: primaryColor, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.edit, size: 16, color: primaryColor),
              ],
            ),
            if (selectedMembers.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children:
                    selectedMembers.map((member) {
                      return Chip(
                        label: Text(
                          member,
                          style: TextStyle(fontSize: 12, color: primaryColor),
                        ),
                        backgroundColor: primaryColor.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        visualDensity: VisualDensity.compact,
                        labelPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: -2,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
              ),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                'Tap to select',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
