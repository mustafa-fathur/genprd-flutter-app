import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class TimelineStep extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(bool isStartDate) selectDate;

  const TimelineStep({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.selectDate,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timeline and milestones for your project',
            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Start Date
          Text(
            'Start Date *',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          _buildDateField(
            context: context,
            label: 'Start Date',
            value:
                startDate != null
                    ? DateFormat('MM/dd/yyyy').format(startDate!)
                    : 'Select date',
            onTap: () => selectDate(true),
          ),
          const SizedBox(height: 20),

          // End Date
          Text(
            'End Date *',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          _buildDateField(
            context: context,
            label: 'End Date',
            value:
                endDate != null
                    ? DateFormat('MM/dd/yyyy').format(endDate!)
                    : 'Select date',
            onTap: () => selectDate(false),
          ),

          // Project duration
          if (startDate != null && endDate != null) ...[
            const SizedBox(height: 16),
            _buildDurationInfo(context),
          ],
        ],
      ),
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: primaryColor, size: 18),
            const SizedBox(width: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                color:
                    value == 'Select date'
                        ? Colors.grey.shade500
                        : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationInfo(BuildContext context) {
    final theme = Theme.of(context);
    final days = endDate!.difference(startDate!).inDays;

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
            CupertinoIcons.calendar_badge_plus,
            color: theme.colorScheme.primary,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Project duration: $days days (${DateFormat('MMM d').format(startDate!)} - ${DateFormat('MMM d, yyyy').format(endDate!)})',
              style: TextStyle(fontSize: 13, color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
