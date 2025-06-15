import 'package:flutter/material.dart';
import 'package:genprd/features/prd/views/widgets/edit_section_header.dart';
import 'package:genprd/features/prd/views/widgets/edit_user_story.dart';
import 'package:genprd/features/prd/views/widgets/edit_success_metric.dart';
import 'package:genprd/features/prd/views/widgets/edit_timeline_item.dart';

class EditDetailsTab extends StatelessWidget {
  final List<Map<String, dynamic>> userStories;
  final List<Map<String, dynamic>> successMetrics;
  final List<Map<String, dynamic>> timelineItems;
  final Function(int, String, String) onUserStoryTitleChanged;
  final Function(int, String) onUserStoryContentChanged;
  final Function(int, String) onUserStoryAcceptanceCriteriaChanged;
  final Function(int, String) onUserStoryPriorityChanged;
  final Function() onAddUserStory;
  final Function(int) onDeleteUserStory;
  final Function(int, String) onSuccessMetricNameChanged;
  final Function(int, String) onSuccessMetricDefinitionChanged;
  final Function(int, String) onSuccessMetricCurrentChanged;
  final Function(int, String) onSuccessMetricTargetChanged;
  final Function() onAddSuccessMetric;
  final Function(int) onDeleteSuccessMetric;
  final Function(int, String) onTimelinePersonChanged;
  final Function(int, String) onTimelineActivityChanged;
  final Function(int, DateTime) onTimelineStartDateChanged;
  final Function(int, DateTime) onTimelineEndDateChanged;
  final Function() onAddTimelineItem;
  final Function(int) onDeleteTimelineItem;
  final DateTime prdStartDate;
  final DateTime prdEndDate;
  final List<Map<String, dynamic>> availablePersonnel;

  const EditDetailsTab({
    super.key,
    required this.userStories,
    required this.successMetrics,
    required this.timelineItems,
    required this.onUserStoryTitleChanged,
    required this.onUserStoryContentChanged,
    required this.onUserStoryAcceptanceCriteriaChanged,
    required this.onUserStoryPriorityChanged,
    required this.onAddUserStory,
    required this.onDeleteUserStory,
    required this.onSuccessMetricNameChanged,
    required this.onSuccessMetricDefinitionChanged,
    required this.onSuccessMetricCurrentChanged,
    required this.onSuccessMetricTargetChanged,
    required this.onAddSuccessMetric,
    required this.onDeleteSuccessMetric,
    required this.onTimelinePersonChanged,
    required this.onTimelineActivityChanged,
    required this.onTimelineStartDateChanged,
    required this.onTimelineEndDateChanged,
    required this.onAddTimelineItem,
    required this.onDeleteTimelineItem,
    required this.prdStartDate,
    required this.prdEndDate,
    required this.availablePersonnel,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Stories
          EditSectionHeader(
            title: 'User Stories',
            onAddPressed: onAddUserStory,
            addButtonLabel: 'Add Story',
          ),

          if (userStories.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Text(
                  'No user stories added yet',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            ...userStories.asMap().entries.map((entry) {
              final index = entry.key;
              final story = entry.value;
              return EditUserStory(
                title: story['title'] ?? '',
                userStory: story['userStory'] ?? '',
                acceptanceCriteria: story['acceptanceCriteria'],
                priority: story['priority'] ?? 'Medium',
                onTitleChanged:
                    (value) => onUserStoryTitleChanged(
                      index,
                      value,
                      story['title'] ?? '',
                    ),
                onUserStoryChanged:
                    (value) => onUserStoryContentChanged(index, value),
                onAcceptanceCriteriaChanged:
                    (value) =>
                        onUserStoryAcceptanceCriteriaChanged(index, value),
                onPriorityChanged:
                    (value) => onUserStoryPriorityChanged(index, value),
                onDelete: () => onDeleteUserStory(index),
              );
            }),

          const SizedBox(height: 24),

          // Success Metrics
          EditSectionHeader(
            title: 'Success Metrics',
            onAddPressed: onAddSuccessMetric,
            addButtonLabel: 'Add Metric',
          ),

          if (successMetrics.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Text(
                  'No success metrics added yet',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            ...successMetrics.asMap().entries.map((entry) {
              final index = entry.key;
              final metric = entry.value;
              return EditSuccessMetric(
                name: metric['name'] ?? '',
                definition: metric['definition'],
                current: metric['current'],
                target: metric['target'],
                onNameChanged:
                    (value) => onSuccessMetricNameChanged(index, value),
                onDefinitionChanged:
                    (value) => onSuccessMetricDefinitionChanged(index, value),
                onCurrentChanged:
                    (value) => onSuccessMetricCurrentChanged(index, value),
                onTargetChanged:
                    (value) => onSuccessMetricTargetChanged(index, value),
                onDelete: () => onDeleteSuccessMetric(index),
              );
            }),

          const SizedBox(height: 24),

          // Timeline
          EditSectionHeader(
            title: 'Project Timeline',
            onAddPressed: onAddTimelineItem,
            addButtonLabel: 'Add Phase',
          ),

          if (timelineItems.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Text(
                  'No timeline phases added yet',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            ...timelineItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return EditTimelineItem(
                personInCharge: item['personInCharge'] ?? '',
                activity: item['activity'] ?? '',
                startDate: item['startDate'] ?? prdStartDate,
                endDate: item['endDate'] ?? prdEndDate,
                prdStartDate: prdStartDate,
                prdEndDate: prdEndDate,
                onPersonChanged:
                    (value) => onTimelinePersonChanged(index, value),
                onActivityChanged:
                    (value) => onTimelineActivityChanged(index, value),
                onStartDateChanged:
                    (value) => onTimelineStartDateChanged(index, value),
                onEndDateChanged:
                    (value) => onTimelineEndDateChanged(index, value),
                onDelete: () => onDeleteTimelineItem(index),
                availablePersonnel: availablePersonnel,
              );
            }),
        ],
      ),
    );
  }
}
