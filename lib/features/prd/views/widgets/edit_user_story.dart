import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class EditUserStory extends StatelessWidget {
  final String title;
  final String userStory;
  final String? acceptanceCriteria;
  final String priority;
  final Function(String) onTitleChanged;
  final Function(String) onUserStoryChanged;
  final Function(String) onAcceptanceCriteriaChanged;
  final Function(String) onPriorityChanged;
  final VoidCallback onDelete;

  const EditUserStory({
    super.key,
    required this.title,
    required this.userStory,
    this.acceptanceCriteria,
    required this.priority,
    required this.onTitleChanged,
    required this.onUserStoryChanged,
    required this.onAcceptanceCriteriaChanged,
    required this.onPriorityChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
            // Header with delete button
            Row(
              children: [
                Icon(
                  CupertinoIcons.person_2_fill,
                  color: Theme.of(context).primaryColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'User Story',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: onDelete,
                  tooltip: 'Delete user story',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 24,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Title field
            Text(
              'Title *',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: title,
              decoration: InputDecoration(
                hintText: 'Enter story title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              onChanged: onTitleChanged,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // User story field
            Text(
              'User Story *',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: userStory,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    'As a [type of user], I want [goal] so that [benefit]',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              onChanged: onUserStoryChanged,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'User story is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Acceptance criteria field
            Text(
              'Acceptance Criteria',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: acceptanceCriteria ?? '',
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter acceptance criteria',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              onChanged: onAcceptanceCriteriaChanged,
            ),
            const SizedBox(height: 16),

            // Priority dropdown
            Text(
              'Priority *',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: priority,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              items:
                  ['High', 'Medium', 'Low'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  onPriorityChanged(newValue);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
