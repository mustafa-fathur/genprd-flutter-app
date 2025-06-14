import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ProjectInformationStep extends StatelessWidget {
  final TextEditingController productNameController;
  final TextEditingController documentVersionController;
  final List<String> documentOwners;
  final List<String> developers;
  final List<String> stakeholders;
  final Function(List<String>) updateDocumentOwners;
  final Function(List<String>) updateDevelopers;
  final Function(List<String>) updateStakeholders;
  final Function(String, List<String>, Function(List<String>))
  showPersonnelSelectionDialog;

  const ProjectInformationStep({
    super.key,
    required this.productNameController,
    required this.documentVersionController,
    required this.documentOwners,
    required this.developers,
    required this.stakeholders,
    required this.updateDocumentOwners,
    required this.updateDevelopers,
    required this.updateStakeholders,
    required this.showPersonnelSelectionDialog,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic information about your project and team',
            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Product Name field
          _buildFormField(
            context: context,
            label: 'Product Name *',
            controller: productNameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a product name';
              }
              return null;
            },
            icon: CupertinoIcons.doc_text,
          ),
          const SizedBox(height: 20),

          // Document Version field
          _buildFormField(
            context: context,
            label: 'Document Version *',
            controller: documentVersionController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a document version';
              }
              return null;
            },
            icon: CupertinoIcons.tag,
          ),
          const SizedBox(height: 20),

          // Document Owners
          _buildTeamSection(
            context: context,
            title: 'Document Owners *',
            icon: CupertinoIcons.person_2,
            selectedMembers: documentOwners,
            onTap: () {
              showPersonnelSelectionDialog(
                'Select Document Owners',
                documentOwners,
                updateDocumentOwners,
              );
            },
          ),
          const SizedBox(height: 20),

          // Developers
          _buildTeamSection(
            context: context,
            title: 'Developers *',
            icon: CupertinoIcons.person_2_fill,
            selectedMembers: developers,
            onTap: () {
              showPersonnelSelectionDialog(
                'Select Developers',
                developers,
                updateDevelopers,
              );
            },
          ),
          const SizedBox(height: 20),

          // Stakeholders
          _buildTeamSection(
            context: context,
            title: 'Stakeholders *',
            icon: CupertinoIcons.person_3,
            selectedMembers: stakeholders,
            onTap: () {
              showPersonnelSelectionDialog(
                'Select Stakeholders',
                stakeholders,
                updateStakeholders,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    IconData? icon,
    int maxLines = 1,
    String? hint,
  }) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              prefixIcon:
                  icon != null
                      ? Icon(icon, color: primaryColor, size: 20)
                      : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            validator: validator,
            maxLines: maxLines,
            cursorColor: primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<String> selectedMembers,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final textTheme = theme.textTheme;

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
                Row(
                  children: [
                    Icon(icon, color: primaryColor, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.edit, size: 16, color: primaryColor),
              ],
            ),
            if (selectedMembers.isEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Tap to select',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                ),
              ),
            ] else ...[
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
            ],
          ],
        ),
      ),
    );
  }
}
