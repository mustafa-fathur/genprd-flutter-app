import 'package:flutter/material.dart';
import 'package:genprd/features/prd/views/widgets/edit_section_header.dart';
import 'package:genprd/features/prd/views/widgets/edit_text_field.dart';
import 'package:genprd/features/prd/views/widgets/edit_date_field.dart';
import 'package:genprd/features/prd/views/widgets/edit_personnel_field.dart';

class EditPrdIdentityTab extends StatelessWidget {
  final TextEditingController productNameController;
  final TextEditingController versionController;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> documentOwners;
  final List<String> developers;
  final List<String> stakeholders;
  final Function(DateTime) onStartDateChanged;
  final Function(DateTime) onEndDateChanged;
  final Function(List<String>) onDocumentOwnersChanged;
  final Function(List<String>) onDevelopersChanged;
  final Function(List<String>) onStakeholdersChanged;
  final List<Map<String, dynamic>> availablePersonnel;

  const EditPrdIdentityTab({
    super.key,
    required this.productNameController,
    required this.versionController,
    required this.startDate,
    required this.endDate,
    required this.documentOwners,
    required this.developers,
    required this.stakeholders,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onDocumentOwnersChanged,
    required this.onDevelopersChanged,
    required this.onStakeholdersChanged,
    required this.availablePersonnel,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const EditSectionHeader(title: 'PRD Identity'),

          // Product Name
          EditTextField(
            controller: productNameController,
            label: 'Product Name',
            hint: 'Enter product name',
            isRequired: true,
          ),

          // Document Version
          EditTextField(
            controller: versionController,
            label: 'Document Version',
            hint: 'e.g. 1.0.0',
            isRequired: true,
          ),

          // Date Range
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: EditDateField(
                  label: 'Start Date',
                  selectedDate: startDate,
                  onDateChanged: onStartDateChanged,
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: EditDateField(
                  label: 'End Date',
                  selectedDate: endDate,
                  onDateChanged: onEndDateChanged,
                  firstDate: startDate,
                  isRequired: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const EditSectionHeader(title: 'Personnel'),

          // Document Owners
          EditPersonnelField(
            label: 'Document Owners',
            selectedPersonnel: documentOwners,
            onPersonnelChanged: onDocumentOwnersChanged,
            availablePersonnel: availablePersonnel,
          ),

          // Developers
          EditPersonnelField(
            label: 'Developers',
            selectedPersonnel: developers,
            onPersonnelChanged: onDevelopersChanged,
            availablePersonnel: availablePersonnel,
          ),

          // Stakeholders
          EditPersonnelField(
            label: 'Stakeholders',
            selectedPersonnel: stakeholders,
            onPersonnelChanged: onStakeholdersChanged,
            availablePersonnel: availablePersonnel,
          ),
        ],
      ),
    );
  }
}
