import 'package:flutter/material.dart';

class TimelineItem extends StatelessWidget {
  final String timePeriod;
  final String activity;
  final String? pic;

  const TimelineItem({
    super.key,
    required this.timePeriod,
    required this.activity,
    this.pic,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              Container(width: 2, height: 40, color: Colors.grey.shade300),
            ],
          ),
          const SizedBox(width: 16),
          // Timeline content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timePeriod,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(activity, style: const TextStyle(fontSize: 15)),
                if (pic != null && pic!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'PIC: $pic',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
