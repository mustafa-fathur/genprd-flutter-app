import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class DarciRoleCard extends StatelessWidget {
  final String role;
  final String people;
  final String guidelines;

  const DarciRoleCard({
    super.key,
    required this.role,
    required this.people,
    required this.guidelines,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Capitalize the first letter of the role
    final String capitalizedRole = _capitalizeRole(role);
    final IconData roleIcon = _getRoleIcon(role);
    final Color roleColor = _getRoleColor(role, theme);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Role title with icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(roleIcon, color: roleColor, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  capitalizedRole,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: roleColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // People assigned to this role
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    'People:',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(child: Text(people, style: textTheme.bodyMedium)),
              ],
            ),
            const SizedBox(height: 8),

            // Role guidelines
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    'Guidelines:',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(child: Text(guidelines, style: textTheme.bodyMedium)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _capitalizeRole(String role) {
    if (role.isEmpty) return role;

    // Special case for DARCI acronym roles
    switch (role.toLowerCase()) {
      case 'decider':
        return 'Decider (D)';
      case 'accountable':
        return 'Accountable (A)';
      case 'responsible':
        return 'Responsible (R)';
      case 'consulted':
        return 'Consulted (C)';
      case 'informed':
        return 'Informed (I)';
      default:
        // Generic capitalization
        return '${role[0].toUpperCase()}${role.substring(1).toLowerCase()}';
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'decider':
        return CupertinoIcons.checkmark_seal_fill;
      case 'accountable':
        return CupertinoIcons.person_crop_circle_badge_checkmark;
      case 'responsible':
        return CupertinoIcons.person_crop_circle_fill_badge_checkmark;
      case 'consulted':
        return CupertinoIcons.chat_bubble_2_fill;
      case 'informed':
        return CupertinoIcons.info_circle_fill;
      default:
        return CupertinoIcons.person_fill;
    }
  }

  Color _getRoleColor(String role, ThemeData theme) {
    switch (role.toLowerCase()) {
      case 'decider':
        return Colors.purple;
      case 'accountable':
        return Colors.indigo;
      case 'responsible':
        return theme.primaryColor;
      case 'consulted':
        return Colors.amber.shade700;
      case 'informed':
        return Colors.teal;
      default:
        return Colors.grey.shade700;
    }
  }
}
