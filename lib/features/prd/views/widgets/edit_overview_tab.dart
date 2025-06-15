import 'package:flutter/material.dart';
import 'package:genprd/features/prd/views/widgets/edit_section_header.dart';
import 'package:genprd/features/prd/views/widgets/edit_text_field.dart';

class EditOverviewTab extends StatelessWidget {
  final TextEditingController projectOverviewController;
  final TextEditingController problemStatementController;
  final TextEditingController objectivesController;
  final List<Map<String, TextEditingController>> customSections;
  final Function(String, String) onAddCustomSection;
  final Function(int) onRemoveCustomSection;

  const EditOverviewTab({
    super.key,
    required this.projectOverviewController,
    required this.problemStatementController,
    required this.objectivesController,
    required this.customSections,
    required this.onAddCustomSection,
    required this.onRemoveCustomSection,
  });

  void _showAddSectionDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Custom Section'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Section Title',
                  hintText: 'Enter section title',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Section Content',
                  hintText: 'Enter section content',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  onAddCustomSection(
                    titleController.text,
                    contentController.text,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Overview
          EditSectionHeader(
            title: 'Project Overview',
            onAddPressed: () => _showAddSectionDialog(context),
            addButtonLabel: 'Add Section',
          ),

          EditTextField(
            controller: projectOverviewController,
            label: 'Project Overview',
            hint: 'Describe the project overview',
            maxLines: 5,
            isRequired: true,
          ),

          // Problem Statement
          const EditSectionHeader(title: 'Problem Statement'),

          EditTextField(
            controller: problemStatementController,
            label: 'Problem Statement',
            hint: 'Describe the problem this project aims to solve',
            maxLines: 5,
          ),

          // Objectives
          const EditSectionHeader(title: 'Objectives'),

          EditTextField(
            controller: objectivesController,
            label: 'Objectives',
            hint: 'List the key objectives of this project',
            maxLines: 5,
          ),

          // Custom Sections
          if (customSections.isNotEmpty)
            ...customSections.asMap().entries.map((entry) {
              final index = entry.key;
              final section = entry.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EditSectionHeader(
                    title: section['title']?.text ?? 'Custom Section',
                    onAddPressed: () => onRemoveCustomSection(index),
                    addButtonLabel: 'Remove',
                  ),
                  EditTextField(
                    controller: section['content']!,
                    label: '',
                    hint: 'Enter content',
                    maxLines: 5,
                  ),
                ],
              );
            }),
        ],
      ),
    );
  }
}
