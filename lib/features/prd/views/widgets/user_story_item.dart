import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class UserStoryItem extends StatelessWidget {
  final String title;
  final String userStory;
  final String? acceptanceCriteria;
  final String priority;

  const UserStoryItem({
    super.key,
    required this.title,
    required this.userStory,
    this.acceptanceCriteria,
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
                _buildPriorityBadge(context),
              ],
            ),
            const SizedBox(height: 12),

            // User story
            Text(
              'User Story:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(userStory, style: theme.textTheme.bodyMedium),

            // Acceptance criteria
            if (acceptanceCriteria != null &&
                acceptanceCriteria!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Acceptance Criteria:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(acceptanceCriteria!, style: theme.textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(BuildContext context) {
    Color badgeColor;

    switch (priority.toLowerCase()) {
      case 'high':
        badgeColor = Colors.red.shade700;
        break;
      case 'medium':
        badgeColor = Colors.amber.shade700;
        break;
      case 'low':
        badgeColor = Colors.green.shade700;
        break;
      default:
        badgeColor = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(
          color: badgeColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
