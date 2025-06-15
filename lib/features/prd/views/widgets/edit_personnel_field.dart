import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class EditPersonnelField extends StatelessWidget {
  final String label;
  final List<String> selectedPersonnel;
  final Function(List<String>) onPersonnelChanged;
  final bool isRequired;
  final bool singleSelect;
  final List<Map<String, dynamic>> availablePersonnel;

  const EditPersonnelField({
    super.key,
    required this.label,
    required this.selectedPersonnel,
    required this.onPersonnelChanged,
    required this.availablePersonnel,
    this.isRequired = false,
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
              title: Text(label),
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                isRequired ? '$label *' : label,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          InkWell(
            onTap: () => _showPersonnelSelectionDialog(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    CupertinoIcons.person_2_fill,
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
        ],
      ),
    );
  }
}
