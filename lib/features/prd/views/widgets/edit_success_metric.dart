import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class EditSuccessMetric extends StatelessWidget {
  final String name;
  final String? definition;
  final String? current;
  final String? target;
  final Function(String) onNameChanged;
  final Function(String) onDefinitionChanged;
  final Function(String) onCurrentChanged;
  final Function(String) onTargetChanged;
  final VoidCallback onDelete;

  const EditSuccessMetric({
    super.key,
    required this.name,
    this.definition,
    this.current,
    this.target,
    required this.onNameChanged,
    required this.onDefinitionChanged,
    required this.onCurrentChanged,
    required this.onTargetChanged,
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
                  CupertinoIcons.chart_bar_fill,
                  color: Theme.of(context).primaryColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Success Metric',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: onDelete,
                  tooltip: 'Delete metric',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 24,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Name field
            Text(
              'Metric Name *',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: name,
              decoration: InputDecoration(
                hintText: 'Enter metric name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              onChanged: onNameChanged,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Metric name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Definition field
            Text(
              'Definition',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: definition ?? '',
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Enter metric definition',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              onChanged: onDefinitionChanged,
            ),
            const SizedBox(height: 16),

            // Current and Target in a row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current value
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Value',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: current ?? '',
                        decoration: InputDecoration(
                          hintText: 'Current',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        onChanged: onCurrentChanged,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Target value
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Target Value',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: target ?? '',
                        decoration: InputDecoration(
                          hintText: 'Target',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        onChanged: onTargetChanged,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
