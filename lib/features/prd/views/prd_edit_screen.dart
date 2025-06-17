import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:genprd/features/prd/controllers/prd_controller.dart';

// PersonnelSelectionDialog class
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
  State<PersonnelSelectionDialog> createState() => _PersonnelSelectionDialogState();
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
                children: _tempSelection.map((person) {
                  return Chip(
                    label: Text(
                      person,
                      style: TextStyle(fontSize: 13, color: primaryColor),
                    ),
                    backgroundColor: primaryColor.withAlpha(26),
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
  late TextEditingController _createdDateController;
  late DateTime _startDate;
  late DateTime _endDate;

  // Project Overview controllers
  late TextEditingController _overviewController;

  // Team & Roles
  late List<String> _stakeholders;
  late List<String> _developers;
  late String? _decisionMaker;
  late String? _accountable;
  late List<String> _responsible;
  late List<String> _consulted;
  late List<String> _informed;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with data
    _titleController = TextEditingController(text: widget.prdData['product_name'] ?? '');
    _versionController = TextEditingController(text: widget.prdData['document_version'] ?? '');
    _ownerController = TextEditingController(text: (widget.prdData['document_owners'] as List<dynamic>?)?.join(', ') ?? '');
    _createdDateController = TextEditingController(text: widget.prdData['created_date'] ?? '');
    _startDate = DateTime.parse(widget.prdData['start_date'] ?? DateTime.now().toIso8601String());
    _endDate = DateTime.parse(widget.prdData['end_date'] ?? DateTime.now().add(const Duration(days: 30)).toIso8601String());
    _overviewController = TextEditingController(text: widget.prdData['project_overview'] ?? '');
    
    // Initialize team & roles
    _stakeholders = List<String>.from(widget.prdData['stakeholders'] ?? []);
    _developers = List<String>.from(widget.prdData['developers'] ?? []);
    final darciRoles = widget.prdData['darci_roles'] as Map<String, dynamic>? ?? {};
    _decisionMaker = (darciRoles['decider'] as List<dynamic>?)?.isNotEmpty == true ? darciRoles['decider'][0] : null;
    _accountable = (darciRoles['accountable'] as List<dynamic>?)?.isNotEmpty == true ? darciRoles['accountable'][0] : null;
    _responsible = List<String>.from(darciRoles['responsible'] ?? []);
    _consulted = List<String>.from(darciRoles['consulted'] ?? []);
    _informed = List<String>.from(darciRoles['informed'] ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _versionController.dispose();
    _ownerController.dispose();
    _createdDateController.dispose();
    _overviewController.dispose();
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
      builder: (context) => PersonnelSelectionDialog(
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

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      List<String> documentOwners = _ownerController.text.isNotEmpty
          ? _ownerController.text.split(',').map((e) => e.trim()).toList()
          : [];

      final Map<String, List<String>> darciRoles = {
        'decider': _decisionMaker != null ? [_decisionMaker!] : [],
        'accountable': _accountable != null ? [_accountable!] : [],
        'responsible': _responsible,
        'consulted': _consulted,
        'informed': _informed,
      };

      final updatedData = {
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
        'document_stage': widget.prdData['document_stage'] ?? 'draft',
      };

      final prdController = Provider.of<PrdController>(context, listen: false);
      await prdController.updatePrd(widget.prdData['id'].toString(), updatedData);

      setState(() {
        _isLoading = false;
        _isDirty = false;
      });

      if (!mounted) return;
      
      Navigator.pop(context, updatedData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PRD updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update PRD: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: isStartDate ? DateTime(2020) : _startDate,
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;

        if (!_isDirty) {
          Navigator.pop(context);
          return;
        }

        final result = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
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

        if (result == true && mounted) {
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
                builder: (dialogContext) => AlertDialog(
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
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // PRD Identity Card
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.article_outlined,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'PRD Identity',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                const SizedBox(height: 16),

                                // Product Name
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Product Name',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        const Text(
                                          ' *',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _titleController,
                                      decoration: InputDecoration(
                                        hintText: 'Enter product name',
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.grey.shade200),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.grey.shade200),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a product name';
                                        }
                                        return null;
                                      },
                                      onChanged: (_) => setState(() => _isDirty = true),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Document Version & Owner
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Document Version',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          TextFormField(
                                            controller: _versionController,
                                            decoration: InputDecoration(
                                              hintText: 'e.g. 1.0',
                                              filled: true,
                                              fillColor: Colors.grey.shade50,
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide(color: Colors.grey.shade200),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide(color: Colors.grey.shade200),
                                              ),
                                            ),
                                            onChanged: (_) => setState(() => _isDirty = true),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Document Owner',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          TextFormField(
                                            controller: _ownerController,
                                            decoration: InputDecoration(
                                              hintText: 'Enter owner name',
                                              filled: true,
                                              fillColor: Colors.grey.shade50,
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide(color: Colors.grey.shade200),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide(color: Colors.grey.shade200),
                                              ),
                                            ),
                                            onChanged: (_) => setState(() => _isDirty = true),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Created Date
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Created Date',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _createdDateController,
                                      decoration: InputDecoration(
                                        hintText: 'MM/DD/YYYY',
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.grey.shade200),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.grey.shade200),
                                        ),
                                      ),
                                      readOnly: true,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Project Timeline Card
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Project Timeline',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                const SizedBox(height: 16),

                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Start Date',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          InkWell(
                                            onTap: () => _selectDate(context, true),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                vertical: 12,
                                                horizontal: 16,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: Colors.grey.shade200),
                                                color: Colors.grey.shade50,
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.calendar_today,
                                                    size: 18,
                                                    color: Theme.of(context).colorScheme.primary,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    DateFormat('MM/dd/yyyy').format(_startDate),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'End Date',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          InkWell(
                                            onTap: () => _selectDate(context, false),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                vertical: 12,
                                                horizontal: 16,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: Colors.grey.shade200),
                                                color: Colors.grey.shade50,
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.calendar_today,
                                                    size: 18,
                                                    color: Theme.of(context).colorScheme.primary,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    DateFormat('MM/dd/yyyy').format(_endDate),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Project Overview Card
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.visibility_outlined,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Project Overview',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                const SizedBox(height: 16),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Project Overview',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        const Text(
                                          ' *',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _overviewController,
                                      maxLines: 6,
                                      decoration: InputDecoration(
                                        hintText: 'Describe the project purpose and goals',
                                        filled: true,
                                        fillColor: Colors.grey.shade50,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.grey.shade200),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.grey.shade200),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter project overview';
                                        }
                                        return null;
                                      },
                                      onChanged: (_) => setState(() => _isDirty = true),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Team & Roles
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Team & Roles',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        ActionChip(
                                          label: const Text('Stakeholders'),
                                          onPressed: () => _showPersonnelSelectionDialog(
                                            title: 'Select Stakeholders',
                                            selectedPersonnel: _stakeholders,
                                            onSave: (selected) => setState(() => _stakeholders = selected),
                                          ),
                                        ),
                                        ActionChip(
                                          label: const Text('Developers'),
                                          onPressed: () => _showPersonnelSelectionDialog(
                                            title: 'Select Developers',
                                            selectedPersonnel: _developers,
                                            onSave: (selected) => setState(() => _developers = selected),
                                          ),
                                        ),
                                        ActionChip(
                                          label: const Text('Decision Maker'),
                                          onPressed: () => _showPersonnelSelectionDialog(
                                            title: 'Select Decision Maker',
                                            selectedPersonnel: _decisionMaker != null ? [_decisionMaker!] : [],
                                            onSave: (selected) => setState(() => _decisionMaker = selected.isNotEmpty ? selected[0] : null),
                                            singleSelect: true,
                                          ),
                                        ),
                                        ActionChip(
                                          label: const Text('Accountable'),
                                          onPressed: () => _showPersonnelSelectionDialog(
                                            title: 'Select Accountable',
                                            selectedPersonnel: _accountable != null ? [_accountable!] : [],
                                            onSave: (selected) => setState(() => _accountable = selected.isNotEmpty ? selected[0] : null),
                                            singleSelect: true,
                                          ),
                                        ),
                                        ActionChip(
                                          label: const Text('Responsible'),
                                          onPressed: () => _showPersonnelSelectionDialog(
                                            title: 'Select Responsible',
                                            selectedPersonnel: _responsible,
                                            onSave: (selected) => setState(() => _responsible = selected),
                                          ),
                                        ),
                                        ActionChip(
                                          label: const Text('Consulted'),
                                          onPressed: () => _showPersonnelSelectionDialog(
                                            title: 'Select Consulted',
                                            selectedPersonnel: _consulted,
                                            onSave: (selected) => setState(() => _consulted = selected),
                                          ),
                                        ),
                                        ActionChip(
                                          label: const Text('Informed'),
                                          onPressed: () => _showPersonnelSelectionDialog(
                                            title: 'Select Informed',
                                            selectedPersonnel: _informed,
                                            onSave: (selected) => setState(() => _informed = selected),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        floatingActionButton: _isDirty
            ? FloatingActionButton.extended(
                onPressed: _saveChanges,
                icon: const Icon(Icons.save),
                label: const Text('Save'),
                backgroundColor: Theme.of(context).colorScheme.primary,
              )
            : null,
        bottomNavigationBar: _isDirty
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Color.alphaBlend(
                  Theme.of(context).colorScheme.primary.withAlpha(26),
                  Colors.white,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'You have unsaved changes.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }
}