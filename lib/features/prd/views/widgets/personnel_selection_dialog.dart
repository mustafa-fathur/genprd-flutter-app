import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PersonnelSelectionDialog extends StatefulWidget {
  final String title;
  final List<String> selectedPersonnel;
  final Function(List<String>) onSave;
  final bool singleSelect;

  const PersonnelSelectionDialog({
    super.key,
    required this.title,
    required this.selectedPersonnel,
    required this.onSave,
    this.singleSelect = false,
  });

  @override
  State<PersonnelSelectionDialog> createState() =>
      _PersonnelSelectionDialogState();
}

class _PersonnelSelectionDialogState extends State<PersonnelSelectionDialog> {
  late List<String> _tempSelection;
  final TextEditingController _newPersonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tempSelection = List<String>.from(widget.selectedPersonnel);
  }

  @override
  void dispose() {
    _newPersonController.dispose();
    super.dispose();
  }

  void _addPerson() {
    final name = _newPersonController.text.trim();
    if (name.isNotEmpty) {
      setState(() {
        if (widget.singleSelect) {
          _tempSelection.clear();
        }
        if (!_tempSelection.contains(name)) {
          _tempSelection.add(name);
        }
        _newPersonController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dialog title and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Add new person field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newPersonController,
                    decoration: InputDecoration(
                      hintText: 'Enter name',
                      hintStyle: TextStyle(fontSize: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _addPerson(),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _addPerson,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),

            // Selected people chips
            if (_tempSelection.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Text(
                'Selected:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: primaryColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _tempSelection.map((person) {
                      return Chip(
                        label: Text(
                          person,
                          style: TextStyle(fontSize: 13, color: primaryColor),
                        ),
                        backgroundColor: primaryColor.withOpacity(0.1),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          setState(() {
                            _tempSelection.remove(person);
                          });
                        },
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

            const SizedBox(height: 24),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    // Add any current input before saving
                    if (_newPersonController.text.trim().isNotEmpty) {
                      _addPerson();
                    }
                    widget.onSave(_tempSelection);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
