import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:genprd/features/prd/controllers/prd_controller.dart';

// Embedded Widgets from prd_detail_screen.dart
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(height: 6),
        Divider(color: Colors.grey.shade200, thickness: 1),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _ContentCard extends StatelessWidget {
  final String content;

  const _ContentCard({required this.content});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          content,
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String timePeriod;
  final String activity;
  final String? pic;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TimelineItem({
    required this.timePeriod,
    required this.activity,
    this.pic,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              Container(width: 2, height: 40, color: Colors.grey.shade300),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timePeriod,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
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
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        size: 18,
                        color: Colors.red,
                      ),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessMetricItem extends StatelessWidget {
  final String name;
  final String? definition;
  final String? current;
  final String? target;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SuccessMetricItem({
    required this.name,
    this.definition,
    this.current,
    this.target,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
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
            Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            if (definition != null && definition!.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 100,
                    child: Text(
                      'Definition:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    child: Text(definition!, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (current != null && current!.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 100,
                    child: Text(
                      'Current:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    child: Text(current!, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (target != null && target!.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 100,
                    child: Text(
                      'Target:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      target!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UserStoryItem extends StatelessWidget {
  final String title;
  final String userStory;
  final String? acceptanceCriteria;
  final String priority;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _UserStoryItem({
    required this.title,
    required this.userStory,
    this.acceptanceCriteria,
    required this.priority,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
                _buildPriorityBadge(context),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'User Story:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(userStory, style: theme.textTheme.bodyMedium),
            if (acceptanceCriteria != null &&
                acceptanceCriteria!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Acceptance Criteria:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(acceptanceCriteria!, style: theme.textTheme.bodyMedium),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(BuildContext context) {
    Color badgeColor;

    switch (priority.toLowerCase()) {
      case 'high':
        badgeColor = Colors.red.shade700;
        break;
      case 'medium':
        badgeColor = Colors.amber.shade700;
        break;
      case 'low':
        badgeColor = Colors.green.shade700;
        break;
      default:
        badgeColor = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(
          color: badgeColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _PersonnelSelectionDialog extends StatefulWidget {
  final String title;
  final List<String> selectedPersonnel;
  final Function(List<String>) onSave;
  final bool singleSelect;

  const _PersonnelSelectionDialog({
    required this.title,
    required this.selectedPersonnel,
    required this.onSave,
    this.singleSelect = false,
  });

  @override
  State<_PersonnelSelectionDialog> createState() =>
      _PersonnelSelectionDialogState();
}

class _PersonnelSelectionDialogState extends State<_PersonnelSelectionDialog> {
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: IntrinsicHeight(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title and close button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
                child: Row(
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
              ),
              const SizedBox(height: 8),
              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _newPersonController,
                            decoration: InputDecoration(
                              hintText: 'Enter name',
                              hintStyle: const TextStyle(fontSize: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
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
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
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
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: primaryColor,
                                  ),
                                ),
                                backgroundColor: primaryColor.withValues(
                                  alpha: 0.1,
                                ),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              );
                            }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              // Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        widget.onSave(_tempSelection);
                        Navigator.pop(context);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DarciRoleDialog extends StatefulWidget {
  final String role;
  final List<String> selectedPersonnel;
  final String guidelines;
  final Function(Map<String, dynamic>) onSave;

  const _DarciRoleDialog({
    required this.role,
    required this.selectedPersonnel,
    required this.guidelines,
    required this.onSave,
  });

  @override
  State<_DarciRoleDialog> createState() => _DarciRoleDialogState();
}

class _DarciRoleDialogState extends State<_DarciRoleDialog> {
  late List<String> _tempPersonnel;
  late TextEditingController _guidelinesController;
  final TextEditingController _personController = TextEditingController();
  final FocusNode _personFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _tempPersonnel = List<String>.from(widget.selectedPersonnel);
    _guidelinesController = TextEditingController(text: widget.guidelines);
  }

  @override
  void dispose() {
    _guidelinesController.dispose();
    _personController.dispose();
    _personFocusNode.dispose();
    super.dispose();
  }

  void _addPerson() {
    final name = _personController.text.trim();
    if (name.isNotEmpty && !_tempPersonnel.contains(name)) {
      setState(() {
        _tempPersonnel.add(name);
        _personController.clear();
      });
    }
    _personFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: IntrinsicHeight(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title and close button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit ${widget.role}',
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
              ),
              const SizedBox(height: 8),
              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _guidelinesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Guidelines',
                        hintText: 'Enter guidelines for ${widget.role}',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _personController,
                            focusNode: _personFocusNode,
                            decoration: InputDecoration(
                              hintText: 'Enter person name',
                              hintStyle: const TextStyle(fontSize: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
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
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_tempPersonnel.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      Text(
                        'Personnel:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: primaryColor,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            _tempPersonnel.map((person) {
                              return Chip(
                                label: Text(
                                  person,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: primaryColor,
                                  ),
                                ),
                                backgroundColor: primaryColor.withOpacity(0.08),
                                deleteIcon: const Icon(Icons.close, size: 16),
                                onDeleted: () {
                                  setState(() {
                                    _tempPersonnel.remove(person);
                                  });
                                },
                                visualDensity: VisualDensity.compact,
                                labelPadding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: -2,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              );
                            }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              // Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        widget.onSave({
                          'personnel': _tempPersonnel,
                          'guidelines': _guidelinesController.text.trim(),
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineItemDialog extends StatefulWidget {
  final Map<String, dynamic>? item;
  final Function(Map<String, dynamic>) onSave;

  const _TimelineItemDialog({this.item, required this.onSave});

  @override
  State<_TimelineItemDialog> createState() => _TimelineItemDialogState();
}

class _TimelineItemDialogState extends State<_TimelineItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _activityController;
  late TextEditingController _picController;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    // Parse time period if available, otherwise use today and +7 days
    String? timePeriod = widget.item?['time_period'];
    DateTime now = DateTime.now();
    if (timePeriod != null && timePeriod.contains(' - ')) {
      final parts = timePeriod.split(' - ');
      _startDate = DateTime.tryParse(parts[0]) ?? now;
      _endDate =
          DateTime.tryParse(parts[1]) ?? now.add(const Duration(days: 7));
    } else {
      _startDate = now;
      _endDate = now.add(const Duration(days: 7));
    }
    _activityController = TextEditingController(
      text: widget.item?['activity'] ?? '',
    );
    _picController = TextEditingController(text: widget.item?['pic'] ?? '');
  }

  @override
  void dispose() {
    _activityController.dispose();
    _picController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final DateTime initialDate = isStart ? _startDate : _endDate;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 7));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: IntrinsicHeight(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title and close button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.item == null
                          ? 'Add Timeline Item'
                          : 'Edit Timeline Item',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
              ),
              const SizedBox(height: 8),
              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _pickDate(context, true),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Start Date',
                                  border: OutlineInputBorder(),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 18,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () => _pickDate(context, false),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'End Date',
                                  border: OutlineInputBorder(),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 18,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${_endDate.year}-${_endDate.month.toString().padLeft(2, '0')}-${_endDate.day.toString().padLeft(2, '0')}',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _activityController,
                        decoration: const InputDecoration(
                          labelText: 'Activity *',
                          hintText: 'e.g. Complete UI design',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an activity';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _picController,
                        decoration: const InputDecoration(
                          labelText: 'Person in Charge (PIC)',
                          hintText: 'e.g. John Doe',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              // Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          widget.onSave({
                            'time_period':
                                '${_startDate.toIso8601String().split('T')[0]} - ${_endDate.toIso8601String().split('T')[0]}',
                            'activity': _activityController.text,
                            'pic': _picController.text,
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserStoryDialog extends StatefulWidget {
  final Map<String, dynamic>? story;
  final Function(Map<String, dynamic>) onSave;

  const _UserStoryDialog({this.story, required this.onSave});

  @override
  State<_UserStoryDialog> createState() => _UserStoryDialogState();
}

class _UserStoryDialogState extends State<_UserStoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _userStoryController;
  late TextEditingController _acceptanceCriteriaController;
  late String _priority;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.story?['title'] ?? '',
    );
    _userStoryController = TextEditingController(
      text: widget.story?['user_story'] ?? '',
    );
    _acceptanceCriteriaController = TextEditingController(
      text: widget.story?['acceptance_criteria'] ?? '',
    );
    _priority = widget.story?['priority'] ?? 'Medium';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _userStoryController.dispose();
    _acceptanceCriteriaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: IntrinsicHeight(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title and close button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.story == null
                          ? 'Add User Story'
                          : 'Edit User Story',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
              ),
              const SizedBox(height: 8),
              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title *',
                          hintText: 'e.g. User Login',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _userStoryController,
                        decoration: const InputDecoration(
                          labelText: 'User Story *',
                          hintText: 'As a user, I want to...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a user story';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _acceptanceCriteriaController,
                        decoration: const InputDecoration(
                          labelText: 'Acceptance Criteria',
                          hintText:
                              'e.g. User can log in with email and password',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value:
                            ['High', 'Medium', 'Low'].contains(_priority)
                                ? _priority
                                : 'Medium',
                        decoration: const InputDecoration(
                          labelText: 'Priority *',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            ['High', 'Medium', 'Low']
                                .map(
                                  (priority) => DropdownMenuItem(
                                    value: priority,
                                    child: Text(priority),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _priority = value;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a priority';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              // Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          widget.onSave({
                            'title': _titleController.text,
                            'user_story': _userStoryController.text,
                            'acceptance_criteria':
                                _acceptanceCriteriaController.text,
                            'priority': _priority.toLowerCase(),
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessMetricDialog extends StatefulWidget {
  final Map<String, dynamic>? metric;
  final Function(Map<String, dynamic>) onSave;

  const _SuccessMetricDialog({this.metric, required this.onSave});

  @override
  State<_SuccessMetricDialog> createState() => _SuccessMetricDialogState();
}

class _SuccessMetricDialogState extends State<_SuccessMetricDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _definitionController;
  late TextEditingController _currentController;
  late TextEditingController _targetController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.metric?['name'] ?? '');
    _definitionController = TextEditingController(
      text: widget.metric?['definition'] ?? '',
    );
    _currentController = TextEditingController(
      text: widget.metric?['current'] ?? '',
    );
    _targetController = TextEditingController(
      text: widget.metric?['target'] ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _definitionController.dispose();
    _currentController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: IntrinsicHeight(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title and close button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.metric == null
                          ? 'Add Success Metric'
                          : 'Edit Success Metric',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
              ),
              const SizedBox(height: 8),
              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Metric Name *',
                          hintText: 'e.g. User Retention Rate',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a metric name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _definitionController,
                        decoration: const InputDecoration(
                          labelText: 'Definition',
                          hintText:
                              'e.g. Percentage of users returning after 30 days',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _currentController,
                        decoration: const InputDecoration(
                          labelText: 'Current Value',
                          hintText: 'e.g. 20%',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _targetController,
                        decoration: const InputDecoration(
                          labelText: 'Target Value',
                          hintText: 'e.g. 40%',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              // Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          widget.onSave({
                            'name': _nameController.text,
                            'definition': _definitionController.text,
                            'current': _currentController.text,
                            'target': _targetController.text,
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InlinePersonnelInput extends StatefulWidget {
  final String label;
  final List<String> personnel;
  final ValueChanged<List<String>> onChanged;
  final bool singleSelect;
  final String? hintText;

  const InlinePersonnelInput({
    super.key,
    required this.label,
    required this.personnel,
    required this.onChanged,
    this.singleSelect = false,
    this.hintText,
  });

  @override
  State<InlinePersonnelInput> createState() => _InlinePersonnelInputState();
}

class _InlinePersonnelInputState extends State<InlinePersonnelInput> {
  late List<String> _personnel;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _personnel = List<String>.from(widget.personnel);
  }

  @override
  void didUpdateWidget(covariant InlinePersonnelInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.personnel != widget.personnel) {
      _personnel = List<String>.from(widget.personnel);
    }
  }

  void _addPerson() {
    final name = _controller.text.trim();
    if (name.isNotEmpty && !_personnel.contains(name)) {
      setState(() {
        if (widget.singleSelect) {
          _personnel = [name];
        } else {
          _personnel.add(name);
        }
        widget.onChanged(_personnel);
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _personnel
                  .map(
                    (person) => Chip(
                      label: Text(
                        person,
                        style: TextStyle(color: primaryColor),
                      ),
                      backgroundColor: primaryColor.withOpacity(0.08),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() {
                          _personnel.remove(person);
                          widget.onChanged(_personnel);
                        });
                      },
                      visualDensity: VisualDensity.compact,
                      labelPadding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: -2,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  )
                  .toList(),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: widget.hintText ?? 'Add person',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
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
      ],
    );
  }
}

class PrdEditScreen extends StatefulWidget {
  final Map<String, dynamic> prdData;

  const PrdEditScreen({super.key, required this.prdData});

  @override
  State<PrdEditScreen> createState() => _PrdEditScreenState();
}

class _PrdEditScreenState extends State<PrdEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isDirty = false;

  // Basic Info controllers
  late TextEditingController _titleController;
  late TextEditingController _versionController;
  late TextEditingController _ownerController;
  late DateTime _startDate;
  late DateTime _endDate;

  // Project Overview controllers
  late TextEditingController _overviewController;
  late TextEditingController _problemStatementController;
  late TextEditingController _objectivesController;

  // Team & Roles
  late List<String> _stakeholders;
  late List<String> _developers;
  late String? _decisionMaker;
  late String? _accountable;
  late List<String> _responsible;
  late List<String> _consulted;
  late List<String> _informed;
  late String _deciderGuidelines;
  late String _accountableGuidelines;
  late String _responsibleGuidelines;
  late String _consultedGuidelines;
  late String _informedGuidelines;

  // Timeline, User Stories, Success Metrics
  late List<Map<String, dynamic>> _timeline;
  late List<Map<String, dynamic>> _userStories;
  late List<Map<String, dynamic>> _successMetrics;

  // Add persistent controllers for each guidelines field
  late TextEditingController _deciderGuidelinesController;
  late TextEditingController _accountableGuidelinesController;
  late TextEditingController _responsibleGuidelinesController;
  late TextEditingController _consultedGuidelinesController;
  late TextEditingController _informedGuidelinesController;

  @override
  void initState() {
    super.initState();
    // Initialize Basic Info controllers
    _titleController = TextEditingController(
      text: widget.prdData['product_name'] ?? '',
    );
    _versionController = TextEditingController(
      text: widget.prdData['document_version'] ?? '',
    );
    _ownerController = TextEditingController(
      text:
          (widget.prdData['document_owners'] as List<dynamic>?)?.join(', ') ??
          '',
    );
    _startDate = DateTime.parse(
      widget.prdData['start_date'] ?? DateTime.now().toIso8601String(),
    );
    _endDate = DateTime.parse(
      widget.prdData['end_date'] ??
          DateTime.now().add(const Duration(days: 30)).toIso8601String(),
    );

    // Initialize Project Overview
    _overviewController = TextEditingController(
      text: widget.prdData['project_overview'] ?? '',
    );
    _problemStatementController = TextEditingController(
      text: _getGeneratedSectionContent('overview', 'Problem Statement') ?? '',
    );
    _objectivesController = TextEditingController(
      text: _getGeneratedSectionContent('overview', 'Objective') ?? '',
    );

    // Initialize Team & Roles
    _stakeholders = List<String>.from(widget.prdData['stakeholders'] ?? []);
    _developers = List<String>.from(widget.prdData['developers'] ?? []);
    final Map<String, dynamic>? darciRoles =
        widget.prdData['darci_roles'] as Map<String, dynamic>?;
    _decisionMaker =
        (darciRoles?['decider'] as List<dynamic>?)?.isNotEmpty ?? false
            ? darciRoles!['decider'][0] as String?
            : null;
    _accountable =
        (darciRoles?['accountable'] as List<dynamic>?)?.isNotEmpty ?? false
            ? darciRoles!['accountable'][0] as String?
            : null;
    _responsible = List<String>.from(darciRoles?['responsible'] ?? []);
    _consulted = List<String>.from(darciRoles?['consulted'] ?? []);
    _informed = List<String>.from(darciRoles?['informed'] ?? []);

    // Initialize DARCI Guidelines from generated_sections or fallback
    final darciFromGenerated =
        widget.prdData['generated_sections']?['darci']?['roles']
            as List<dynamic>?;
    if (darciFromGenerated != null) {
      for (var role in darciFromGenerated) {
        final roleName = role['name']?.toLowerCase();
        final guidelines = role['guidelines'] ?? '';
        switch (roleName) {
          case 'decider':
            _deciderGuidelines = guidelines;
            break;
          case 'accountable':
            _accountableGuidelines = guidelines;
            break;
          case 'responsible':
            _responsibleGuidelines = guidelines;
            break;
          case 'consulted':
            _consultedGuidelines = guidelines;
            break;
          case 'informed':
            _informedGuidelines = guidelines;
            break;
        }
      }
    } else {
      _deciderGuidelines =
          darciRoles?['decider'] != null
              ? 'Responsible for making final decisions on project direction and scope.'
              : '';
      _accountableGuidelines =
          darciRoles?['accountable'] != null
              ? 'Accountable for the successful delivery of the project.'
              : '';
      _responsibleGuidelines =
          darciRoles?['responsible'] != null
              ? 'Responsible for implementing the project requirements.'
              : '';
      _consultedGuidelines =
          darciRoles?['consulted'] != null
              ? 'Consulted for expertise in specific areas of the project.'
              : '';
      _informedGuidelines =
          darciRoles?['informed'] != null
              ? 'Kept informed about project progress and milestones.'
              : '';
    }

    // Initialize Timeline, User Stories, Success Metrics
    _timeline = List<Map<String, dynamic>>.from(
      widget.prdData['timeline'] ?? [],
    );
    _userStories = List<Map<String, dynamic>>.from(
      widget.prdData['generated_sections']?['user_stories']?['stories'] ?? [],
    );
    _successMetrics = List<Map<String, dynamic>>.from(
      widget.prdData['generated_sections']?['success_metrics']?['metrics'] ??
          [],
    );

    // Initialize persistent controllers for each guidelines field
    _deciderGuidelinesController = TextEditingController(
      text: _deciderGuidelines,
    );
    _accountableGuidelinesController = TextEditingController(
      text: _accountableGuidelines,
    );
    _responsibleGuidelinesController = TextEditingController(
      text: _responsibleGuidelines,
    );
    _consultedGuidelinesController = TextEditingController(
      text: _consultedGuidelines,
    );
    _informedGuidelinesController = TextEditingController(
      text: _informedGuidelines,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _versionController.dispose();
    _ownerController.dispose();
    _overviewController.dispose();
    _problemStatementController.dispose();
    _objectivesController.dispose();
    _deciderGuidelinesController.dispose();
    _accountableGuidelinesController.dispose();
    _responsibleGuidelinesController.dispose();
    _consultedGuidelinesController.dispose();
    _informedGuidelinesController.dispose();
    super.dispose();
  }

  void _showPersonnelSelectionDialog({
    required String title,
    required List<String> selectedPersonnel,
    required Function(List<String>) onSave,
    bool singleSelect = false,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => _PersonnelSelectionDialog(
            title: title,
            selectedPersonnel: selectedPersonnel,
            onSave: (selected) {
              onSave(selected);
              setState(() {
                _isDirty = true;
              });
            },
            singleSelect: singleSelect,
          ),
    );
  }

  void _showDarciRoleDialog({
    required String role,
    required List<String> selectedPersonnel,
    required String guidelines,
    required Function(Map<String, dynamic>) onSave,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => _DarciRoleDialog(
            role: role,
            selectedPersonnel: selectedPersonnel,
            guidelines: guidelines,
            onSave: (data) {
              onSave(data);
              setState(() {
                _isDirty = true;
              });
            },
          ),
    );
  }

  void _showTimelineItemDialog({Map<String, dynamic>? item, int? index}) {
    showDialog(
      context: context,
      builder:
          (context) => _TimelineItemDialog(
            item: item,
            onSave: (data) {
              setState(() {
                if (index != null) {
                  _timeline[index] = data;
                } else {
                  _timeline.add(data);
                }
                _isDirty = true;
              });
            },
          ),
    );
  }

  void _showUserStoryDialog({Map<String, dynamic>? story, int? index}) {
    showDialog(
      context: context,
      builder:
          (context) => _UserStoryDialog(
            story: story,
            onSave: (data) {
              setState(() {
                if (index != null) {
                  _userStories[index] = data;
                } else {
                  _userStories.add(data);
                }
                _isDirty = true;
              });
            },
          ),
    );
  }

  void _showSuccessMetricDialog({Map<String, dynamic>? metric, int? index}) {
    showDialog(
      context: context,
      builder:
          (context) => _SuccessMetricDialog(
            metric: metric,
            onSave: (data) {
              setState(() {
                if (index != null) {
                  _successMetrics[index] = data;
                } else {
                  _successMetrics.add(data);
                }
                _isDirty = true;
              });
            },
          ),
    );
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final List<String> documentOwners =
          _ownerController.text.isEmpty
              ? []
              : _ownerController.text.split(', ').map((e) => e.trim()).toList();

      final Map<String, dynamic> darciRoles = {
        'decider': _decisionMaker != null ? [_decisionMaker!] : [],
        'accountable': _accountable != null ? [_accountable!] : [],
        'responsible': _responsible,
        'consulted': _consulted,
        'informed': _informed,
      };

      final Map<String, dynamic> updatedGeneratedSections = {
        ...?widget.prdData['generated_sections'],
        'overview': {
          'sections': [
            if (_problemStatementController.text.isNotEmpty)
              {
                'title': 'Problem Statement',
                'content': _problemStatementController.text,
              },
            if (_objectivesController.text.isNotEmpty)
              {'title': 'Objective', 'content': _objectivesController.text},
          ],
        },
        'user_stories': {'stories': _userStories},
        'success_metrics': {'metrics': _successMetrics},
        'darci': {
          'roles': [
            {
              'name': 'Decider',
              'members': darciRoles['decider'],
              'guidelines': _deciderGuidelines,
            },
            {
              'name': 'Accountable',
              'members': darciRoles['accountable'],
              'guidelines': _accountableGuidelines,
            },
            {
              'name': 'Responsible',
              'members': darciRoles['responsible'],
              'guidelines': _responsibleGuidelines,
            },
            {
              'name': 'Consulted',
              'members': darciRoles['consulted'],
              'guidelines': _consultedGuidelines,
            },
            {
              'name': 'Informed',
              'members': darciRoles['informed'],
              'guidelines': _informedGuidelines,
            },
          ],
        },
      };

      final Map<String, dynamic> updatedData = {
        ...widget.prdData,
        'product_name': _titleController.text,
        'document_version': _versionController.text,
        'document_owners': documentOwners,
        'project_overview': _overviewController.text,
        'start_date': _startDate.toIso8601String().split('T')[0],
        'end_date': _endDate.toIso8601String().split('T')[0],
        'stakeholders': _stakeholders,
        'developers': _developers,
        'darci_roles': darciRoles,
        'timeline': _timeline,
        'generated_sections': updatedGeneratedSections,
        'document_stage': widget.prdData['document_stage'] ?? 'draft',
      };

      final prdController = Provider.of<PrdController>(context, listen: false);
      await prdController.updatePrd(
        widget.prdData['id'].toString(),
        updatedData,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isDirty = false;
        });
        Navigator.pop(context, updatedData);
        _showSnackBar('PRD updated successfully');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update PRD: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime initialDate = isStartDate ? _startDate : _endDate;
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 30));
          }
        } else {
          _endDate = pickedDate;
        }
        _isDirty = true;
      });
    }
  }

  String? _getGeneratedSectionContent(String sectionName, String title) {
    final sections =
        widget.prdData['generated_sections']?[sectionName]?['sections']
            as List<dynamic>?;
    if (sections == null) return null;

    for (var section in sections) {
      if (section['title'] == title) {
        return section['content'] as String?;
      }
    }
    return null;
  }

  // Consistent snackbar/toast for all notifications
  void _showSnackBar(String message, {bool isError = false}) {
    final theme = Theme.of(context);
    final backgroundColor =
        isError ? theme.colorScheme.error : theme.primaryColor;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (!_isDirty) {
          Navigator.pop(context);
          return;
        }

        final canPop = await showDialog<bool>(
          context: context,
          builder:
              (dialogContext) => AlertDialog(
                title: const Text('Discard changes?'),
                content: const Text(
                  'You have unsaved changes. Are you sure you want to discard them?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: const Text('Discard'),
                  ),
                ],
              ),
        );

        if (canPop == true && mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit PRD'),
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back),
            onPressed: () async {
              if (!_isDirty) {
                Navigator.pop(context);
                return;
              }

              final canPop = await showDialog<bool>(
                context: context,
                builder:
                    (dialogContext) => AlertDialog(
                      title: const Text('Discard changes?'),
                      content: const Text(
                        'You have unsaved changes. Are you sure you want to discard them?',
                      ),
                      actions: [
                        TextButton(
                          onPressed:
                              () => Navigator.of(dialogContext).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed:
                              () => Navigator.of(dialogContext).pop(true),
                          child: const Text('Discard'),
                        ),
                      ],
                    ),
              );

              if (canPop == true && mounted) {
                Navigator.pop(context);
              }
            },
          ),
          actions: [
            if (_isDirty && !_isLoading)
              IconButton(
                icon: const Icon(Icons.save),
                tooltip: 'Save Changes',
                onPressed: _saveChanges,
              ),
          ],
        ),
        body:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // PRD Identity
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _SectionHeader(title: 'PRD Identity'),
                                TextFormField(
                                  controller: _titleController,
                                  decoration: InputDecoration(
                                    labelText: 'Product Name *',
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a product name';
                                    }
                                    return null;
                                  },
                                  onChanged:
                                      (_) => setState(() => _isDirty = true),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _versionController,
                                  decoration: InputDecoration(
                                    labelText: 'Document Version',
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                  ),
                                  onChanged:
                                      (_) => setState(() => _isDirty = true),
                                ),
                                const SizedBox(height: 12),
                                InlinePersonnelInput(
                                  label: 'Document Owner',
                                  personnel:
                                      _ownerController.text.isEmpty
                                          ? []
                                          : _ownerController.text
                                              .split(', ')
                                              .map((e) => e.trim())
                                              .toList(),
                                  onChanged: (list) {
                                    _ownerController.text = list.join(', ');
                                    setState(() => _isDirty = true);
                                  },
                                  singleSelect: false,
                                  hintText: 'Add owner',
                                ),
                                const SizedBox(height: 12),
                                InlinePersonnelInput(
                                  label: 'Stakeholders',
                                  personnel: _stakeholders,
                                  onChanged:
                                      (list) => setState(() {
                                        _stakeholders = list;
                                        _isDirty = true;
                                      }),
                                  hintText: 'Add stakeholder',
                                ),
                                const SizedBox(height: 12),
                                InlinePersonnelInput(
                                  label: 'Developers',
                                  personnel: _developers,
                                  onChanged:
                                      (list) => setState(() {
                                        _developers = list;
                                        _isDirty = true;
                                      }),
                                  hintText: 'Add developer',
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => _selectDate(context, true),
                                        child: InputDecorator(
                                          decoration: InputDecoration(
                                            labelText: 'Start Date',
                                            filled: true,
                                            fillColor: Colors.grey.shade50,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: Colors.grey.shade200,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_today,
                                                size: 18,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                DateFormat(
                                                  'MM/dd/yyyy',
                                                ).format(_startDate),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: InkWell(
                                        onTap:
                                            () => _selectDate(context, false),
                                        child: InputDecorator(
                                          decoration: InputDecoration(
                                            labelText: 'End Date',
                                            filled: true,
                                            fillColor: Colors.grey.shade50,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: Colors.grey.shade200,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_today,
                                                size: 18,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                DateFormat(
                                                  'MM/dd/yyyy',
                                                ).format(_endDate),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Project Overview
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _SectionHeader(title: 'Project Overview'),
                                TextFormField(
                                  controller: _overviewController,
                                  maxLines: 6,
                                  decoration: InputDecoration(
                                    labelText: 'Project Overview *',
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter project overview';
                                    }
                                    return null;
                                  },
                                  onChanged:
                                      (_) => setState(() => _isDirty = true),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _problemStatementController,
                                  maxLines: 6,
                                  decoration: InputDecoration(
                                    labelText: 'Problem Statement',
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                  ),
                                  onChanged:
                                      (_) => setState(() => _isDirty = true),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _objectivesController,
                                  maxLines: 6,
                                  decoration: InputDecoration(
                                    labelText: 'Objectives',
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                  ),
                                  onChanged:
                                      (_) => setState(() => _isDirty = true),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // DARCI Roles
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _SectionHeader(title: 'DARCI Roles'),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Decider',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller:
                                            _deciderGuidelinesController,
                                        maxLines: 2,
                                        decoration: InputDecoration(
                                          labelText: 'Guidelines',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 10,
                                              ),
                                        ),
                                        onChanged:
                                            (val) => setState(() {
                                              _deciderGuidelines = val;
                                              _isDirty = true;
                                            }),
                                      ),
                                      const SizedBox(height: 8),
                                      InlinePersonnelInput(
                                        label: 'Personnel',
                                        personnel:
                                            _decisionMaker != null
                                                ? [_decisionMaker!]
                                                : [],
                                        onChanged:
                                            (list) => setState(() {
                                              _decisionMaker =
                                                  list.isNotEmpty
                                                      ? list[0]
                                                      : null;
                                              _isDirty = true;
                                            }),
                                        singleSelect: true,
                                        hintText: 'Add decider',
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Accountable',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller:
                                            _accountableGuidelinesController,
                                        maxLines: 2,
                                        decoration: InputDecoration(
                                          labelText: 'Guidelines',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 10,
                                              ),
                                        ),
                                        onChanged:
                                            (val) => setState(() {
                                              _accountableGuidelines = val;
                                              _isDirty = true;
                                            }),
                                      ),
                                      const SizedBox(height: 8),
                                      InlinePersonnelInput(
                                        label: 'Personnel',
                                        personnel:
                                            _accountable != null
                                                ? [_accountable!]
                                                : [],
                                        onChanged:
                                            (list) => setState(() {
                                              _accountable =
                                                  list.isNotEmpty
                                                      ? list[0]
                                                      : null;
                                              _isDirty = true;
                                            }),
                                        singleSelect: true,
                                        hintText: 'Add accountable',
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Responsible',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller:
                                            _responsibleGuidelinesController,
                                        maxLines: 2,
                                        decoration: InputDecoration(
                                          labelText: 'Guidelines',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 10,
                                              ),
                                        ),
                                        onChanged:
                                            (val) => setState(() {
                                              _responsibleGuidelines = val;
                                              _isDirty = true;
                                            }),
                                      ),
                                      const SizedBox(height: 8),
                                      InlinePersonnelInput(
                                        label: 'Personnel',
                                        personnel: _responsible,
                                        onChanged:
                                            (list) => setState(() {
                                              _responsible = list;
                                              _isDirty = true;
                                            }),
                                        hintText: 'Add responsible',
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Consulted',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller:
                                            _consultedGuidelinesController,
                                        maxLines: 2,
                                        decoration: InputDecoration(
                                          labelText: 'Guidelines',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 10,
                                              ),
                                        ),
                                        onChanged:
                                            (val) => setState(() {
                                              _consultedGuidelines = val;
                                              _isDirty = true;
                                            }),
                                      ),
                                      const SizedBox(height: 8),
                                      InlinePersonnelInput(
                                        label: 'Personnel',
                                        personnel: _consulted,
                                        onChanged:
                                            (list) => setState(() {
                                              _consulted = list;
                                              _isDirty = true;
                                            }),
                                        hintText: 'Add consulted',
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Informed',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller:
                                            _informedGuidelinesController,
                                        maxLines: 2,
                                        decoration: InputDecoration(
                                          labelText: 'Guidelines',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 10,
                                              ),
                                        ),
                                        onChanged:
                                            (val) => setState(() {
                                              _informedGuidelines = val;
                                              _isDirty = true;
                                            }),
                                      ),
                                      const SizedBox(height: 8),
                                      InlinePersonnelInput(
                                        label: 'Personnel',
                                        personnel: _informed,
                                        onChanged:
                                            (list) => setState(() {
                                              _informed = list;
                                              _isDirty = true;
                                            }),
                                        hintText: 'Add informed',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // User Stories
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _SectionHeader(title: 'User Stories'),
                                if (_userStories.isEmpty)
                                  const _ContentCard(
                                    content: 'No user stories defined',
                                  )
                                else
                                  Column(
                                    children:
                                        _userStories.asMap().entries.map((
                                          entry,
                                        ) {
                                          final index = entry.key;
                                          final story = entry.value;
                                          return _UserStoryItem(
                                            title: story['title'] ?? '',
                                            userStory:
                                                story['user_story'] ?? '',
                                            acceptanceCriteria:
                                                story['acceptance_criteria']
                                                    as String?,
                                            priority:
                                                (story['priority'] as String?)
                                                    ?.toString()
                                                    .toUpperCaseFirst() ??
                                                'Medium',
                                            onEdit:
                                                () => _showUserStoryDialog(
                                                  story: story,
                                                  index: index,
                                                ),
                                            onDelete: () {
                                              setState(() {
                                                _userStories.removeAt(index);
                                                _isDirty = true;
                                              });
                                            },
                                          );
                                        }).toList(),
                                  ),
                                const SizedBox(height: 16),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _showUserStoryDialog(),
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add User Story'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Success Metrics
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _SectionHeader(title: 'Success Metrics'),
                                if (_successMetrics.isEmpty)
                                  const _ContentCard(
                                    content: 'No success metrics defined',
                                  )
                                else
                                  Column(
                                    children:
                                        _successMetrics.asMap().entries.map((
                                          entry,
                                        ) {
                                          final index = entry.key;
                                          final metric = entry.value;
                                          return _SuccessMetricItem(
                                            name: metric['name'] ?? '',
                                            definition:
                                                metric['definition'] as String?,
                                            current:
                                                metric['current'] as String?,
                                            target: metric['target'] as String?,
                                            onEdit:
                                                () => _showSuccessMetricDialog(
                                                  metric: metric,
                                                  index: index,
                                                ),
                                            onDelete: () {
                                              setState(() {
                                                _successMetrics.removeAt(index);
                                                _isDirty = true;
                                              });
                                            },
                                          );
                                        }).toList(),
                                  ),
                                const SizedBox(height: 16),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _showSuccessMetricDialog(),
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Success Metric'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Timeline
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _SectionHeader(title: 'Timeline'),
                                if (_timeline.isEmpty)
                                  const _ContentCard(
                                    content: 'No timeline items defined',
                                  )
                                else
                                  Column(
                                    children:
                                        _timeline.asMap().entries.map((entry) {
                                          final index = entry.key;
                                          final item = entry.value;
                                          return _TimelineItem(
                                            timePeriod:
                                                item['time_period'] ?? '',
                                            activity: item['activity'] ?? '',
                                            pic: item['pic'] as String?,
                                            onEdit:
                                                () => _showTimelineItemDialog(
                                                  item: item,
                                                  index: index,
                                                ),
                                            onDelete: () {
                                              setState(() {
                                                _timeline.removeAt(index);
                                                _isDirty = true;
                                              });
                                            },
                                          );
                                        }).toList(),
                                  ),
                                const SizedBox(height: 16),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _showTimelineItemDialog(),
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Timeline Item'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        floatingActionButton:
            _isDirty
                ? Padding(
                  padding: const EdgeInsets.only(bottom: 16.0, right: 8.0),
                  child: FloatingActionButton.extended(
                    onPressed: _saveChanges,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Changes'),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                )
                : null,
      ),
    );
  }
}

// Extension for string capitalization
extension StringExtension on String {
  String toUpperCaseFirst() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}
