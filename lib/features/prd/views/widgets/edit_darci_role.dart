import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class EditDarciRole extends StatelessWidget {
  final String roleName;
  final String roleDescription;
  final List<String> selectedPersonnel;
  final Function(List<String>) onPersonnelChanged;
  final Function(String) onDescriptionChanged;
  final List<Map<String, dynamic>> availablePersonnel;
  final bool singleSelect;

  const EditDarciRole({
    super.key,
    required this.roleName,
    required this.roleDescription,
    required this.selectedPersonnel,
    required this.onPersonnelChanged,
    required this.onDescriptionChanged,
    required this.availablePersonnel,
    this.singleSelect = false,
  });

  void _showPersonnelSelectionDialog(BuildContext context) {
    final tempSelection = List<String>.from(selectedPersonnel);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Select $roleName'),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView(
                  shrinkWrap: true,
                  children:
                      availablePersonnel.map((person) {
                        final isSelected = tempSelection.contains(
                          person['name'],
                        );
                        return CheckboxListTile(
                          title: Text(person['name']),
                          subtitle: Text(person['role']),
                          value: isSelected,
                          onChanged: (value) {
                            setDialogState(() {
                              if (singleSelect) {
                                tempSelection.clear();
                                if (value == true) {
                                  tempSelection.add(person['name']);
                                }
                              } else {
                                if (value == true) {
                                  tempSelection.add(person['name']);
                                } else {
                                  tempSelection.remove(person['name']);
                                }
                              }
                            });
                          },
                        );
                      }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    onPersonnelChanged(tempSelection);
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _getCapitalizedRoleName() {
    switch (roleName.toLowerCase()) {
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
        return roleName;
    }
  }

  IconData _getRoleIcon() {
    switch (roleName.toLowerCase()) {
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

  Color _getRoleColor(BuildContext context) {
    switch (roleName.toLowerCase()) {
      case 'decider':
        return Colors.purple;
      case 'accountable':
        return Colors.indigo;
      case 'responsible':
        return Theme.of(context).primaryColor;
      case 'consulted':
        return Colors.amber.shade700;
      case 'informed':
        return Colors.teal;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleColor = _getRoleColor(context);

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
            // Role title with icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_getRoleIcon(), color: roleColor, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  _getCapitalizedRoleName(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: roleColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // People selection
            InkWell(
              onTap: () => _showPersonnelSelectionDialog(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child:
                          selectedPersonnel.isEmpty
                              ? Text(
                                'Select ${singleSelect ? "person" : "people"}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                ),
                              )
                              : Text(
                                selectedPersonnel.join(', '),
                                style: const TextStyle(fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                    ),
                    Icon(
                      CupertinoIcons.person_add,
                      size: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),
            ),

            if (selectedPersonnel.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      selectedPersonnel.map((person) {
                        return Chip(
                          label: Text(person),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            final updatedList = List<String>.from(
                              selectedPersonnel,
                            );
                            updatedList.remove(person);
                            onPersonnelChanged(updatedList);
                          },
                          backgroundColor: Colors.grey.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        );
                      }).toList(),
                ),
              ),

            const SizedBox(height: 16),

            // Guidelines text field
            Text(
              'Guidelines',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: roleDescription,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter guidelines for this role',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                contentPadding: const EdgeInsets.all(16),
                isDense: true,
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: onDescriptionChanged,
            ),
          ],
        ),
      ),
    );
  }
}
