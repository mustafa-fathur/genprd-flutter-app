import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PrdFormScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  
  const PrdFormScreen({super.key, this.initialData});

  @override
  State<PrdFormScreen> createState() => _PrdFormScreenState();
}

class _PrdFormScreenState extends State<PrdFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _documentVersionController = TextEditingController();
  final TextEditingController _documentOwnerController = TextEditingController();
  final TextEditingController _projectOverviewController = TextEditingController();
  
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;
  
  // Mock personnel data for dropdown selections
  final List<Map<String, dynamic>> _personnel = [
    {'name': 'Fulan', 'role': 'AI Engineer'},
    {'name': 'Fulana', 'role': 'Software Engineer'},
    {'name': 'Mustafa Fathur Rahman', 'role': 'Developer'},
    {'name': 'John Doe', 'role': 'Product Manager'},
    {'name': 'Jane Smith', 'role': 'Designer'},
  ];
  
  // Selected personnel for different roles
  List<String> _selectedStakeholders = [];
  List<String> _selectedDevelopers = [];
  
  // DARCI roles
  String? _decisionMaker; // D
  String? _accountable; // A
  List<String> _responsible = []; // R
  List<String> _consulted = []; // C
  List<String> _informed = []; // I
  
  @override
  void initState() {
    super.initState();
    
    // Set default values for new PRD
    _documentVersionController.text = '0.1.0';
    
    // If editing an existing PRD, populate the form
    if (widget.initialData != null) {
      _productNameController.text = widget.initialData!['productName'] ?? '';
      _documentVersionController.text = widget.initialData!['documentVersion'] ?? '0.1.0';
      _documentOwnerController.text = widget.initialData!['documentOwner'] ?? '';
      _projectOverviewController.text = widget.initialData!['projectOverview'] ?? '';
      
      if (widget.initialData!['startDate'] != null) {
        _startDate = DateTime.parse(widget.initialData!['startDate']);
      }
      
      if (widget.initialData!['endDate'] != null) {
        _endDate = DateTime.parse(widget.initialData!['endDate']);
      }
      
      // Load personnel selections if available
      _selectedStakeholders = List<String>.from(widget.initialData!['stakeholders'] ?? []);
      _selectedDevelopers = List<String>.from(widget.initialData!['developers'] ?? []);
      
      // Load DARCI roles if available
      _decisionMaker = widget.initialData!['darci']?['decisionMaker'];
      _accountable = widget.initialData!['darci']?['accountable'];
      _responsible = List<String>.from(widget.initialData!['darci']?['responsible'] ?? []);
      _consulted = List<String>.from(widget.initialData!['darci']?['consulted'] ?? []);
      _informed = List<String>.from(widget.initialData!['darci']?['informed'] ?? []);
    }
  }
  
  @override
  void dispose() {
    _productNameController.dispose();
    _documentVersionController.dispose();
    _documentOwnerController.dispose();
    _projectOverviewController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate 
        ? _startDate ?? DateTime.now() 
        : _endDate ?? (_startDate != null ? _startDate!.add(const Duration(days: 30)) : DateTime.now().add(const Duration(days: 30)));
    
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: isStartDate ? DateTime(2020) : (_startDate ?? DateTime(2020)),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          // If end date is before start date, update it
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate!.add(const Duration(days: 30));
          }
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  Future<void> _savePrd() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // In a real app, you would save all form data including:
      final prdData = {
        'productName': _productNameController.text,
        'documentVersion': _documentVersionController.text,
        'documentOwner': _documentOwnerController.text,
        'projectOverview': _projectOverviewController.text,
        'startDate': _startDate?.toIso8601String(),
        'endDate': _endDate?.toIso8601String(),
        'stakeholders': _selectedStakeholders,
        'developers': _selectedDevelopers,
        'darci': {
          'decisionMaker': _decisionMaker,
          'accountable': _accountable,
          'responsible': _responsible,
          'consulted': _consulted,
          'informed': _informed,
        }
      };
      
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.initialData != null
                  ? 'PRD updated successfully'
                  : 'PRD created successfully',
            ),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
      }
    }
  }

  void _showPersonnelSelectionDialog({
    required String title, 
    required List<String> selectedPersonnel,
    required Function(List<String>) onSave,
    bool singleSelect = false,
  }) {
    final tempSelection = List<String>.from(selectedPersonnel);
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(title),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: _personnel.map((person) {
                    final isSelected = tempSelection.contains(person['name']);
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
                    onSave(tempSelection);
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
    final isEditing = widget.initialData != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit PRD' : 'Create New PRD'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isLoading)
            TextButton.icon(
              onPressed: _savePrd,
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Basic Information Section
                  _buildSectionHeader('Basic Information'),
                  _buildFormField(
                    label: 'Product Name',
                    controller: _productNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a product name';
                      }
                      return null;
                    },
                    icon: Icons.title,
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildFormField(
                          label: 'Document Version',
                          controller: _documentVersionController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                          icon: Icons.tag,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFormField(
                          label: 'Document Owner',
                          controller: _documentOwnerController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                          icon: Icons.person,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Date Selection
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                          label: 'Start Date',
                          value: _startDate != null 
                              ? DateFormat('MM/dd/yyyy').format(_startDate!)
                              : 'Select date',
                          onTap: () => _selectDate(context, true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDateField(
                          label: 'End Date',
                          value: _endDate != null 
                              ? DateFormat('MM/dd/yyyy').format(_endDate!)
                              : 'Select date',
                          onTap: () => _selectDate(context, false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Project Overview
                  _buildSectionHeader('Project Overview'),
                  _buildFormField(
                    label: 'Project Overview',
                    controller: _projectOverviewController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a project overview';
                      }
                      return null;
                    },
                    icon: Icons.description,
                    maxLines: 5,
                    hint: 'Describe your project goals, scope, and objectives...',
                  ),
                  const SizedBox(height: 24),
                  
                  // Team Members Section
                  _buildSectionHeader('Team Members'),
                  
                  // Stakeholders
                  _buildTeamSection(
                    title: 'Stakeholders',
                    icon: Icons.people_outline,
                    selectedMembers: _selectedStakeholders,
                    onTap: () {
                      _showPersonnelSelectionDialog(
                        title: 'Select Stakeholders',
                        selectedPersonnel: _selectedStakeholders,
                        onSave: (selected) {
                          setState(() {
                            _selectedStakeholders = selected;
                          });
                        },
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Developers
                  _buildTeamSection(
                    title: 'Developers',
                    icon: Icons.code,
                    selectedMembers: _selectedDevelopers,
                    onTap: () {
                      _showPersonnelSelectionDialog(
                        title: 'Select Developers',
                        selectedPersonnel: _selectedDevelopers,
                        onSave: (selected) {
                          setState(() {
                            _selectedDevelopers = selected;
                          });
                        },
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // DARCI Matrix Section
                  _buildSectionHeader('DARCI Matrix'),
                  
                  // Decision Maker (D)
                  _buildTeamSection(
                    title: 'Decision Maker (D)',
                    icon: Icons.gavel,
                    selectedMembers: _decisionMaker != null ? [_decisionMaker!] : [],
                    onTap: () {
                      _showPersonnelSelectionDialog(
                        title: 'Select Decision Maker',
                        selectedPersonnel: _decisionMaker != null ? [_decisionMaker!] : [],
                        onSave: (selected) {
                          setState(() {
                            _decisionMaker = selected.isNotEmpty ? selected.first : null;
                          });
                        },
                        singleSelect: true,
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Accountable (A)
                  _buildTeamSection(
                    title: 'Accountable (A)',
                    icon: Icons.account_circle,
                    selectedMembers: _accountable != null ? [_accountable!] : [],
                    onTap: () {
                      _showPersonnelSelectionDialog(
                        title: 'Select Accountable Person',
                        selectedPersonnel: _accountable != null ? [_accountable!] : [],
                        onSave: (selected) {
                          setState(() {
                            _accountable = selected.isNotEmpty ? selected.first : null;
                          });
                        },
                        singleSelect: true,
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Responsible (R)
                  _buildTeamSection(
                    title: 'Responsible (R)',
                    icon: Icons.assignment_ind,
                    selectedMembers: _responsible,
                    onTap: () {
                      _showPersonnelSelectionDialog(
                        title: 'Select Responsible Members',
                        selectedPersonnel: _responsible,
                        onSave: (selected) {
                          setState(() {
                            _responsible = selected;
                          });
                        },
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Consulted (C)
                  _buildTeamSection(
                    title: 'Consulted (C)',
                    icon: Icons.chat_bubble_outline,
                    selectedMembers: _consulted,
                    onTap: () {
                      _showPersonnelSelectionDialog(
                        title: 'Select Consulted Members',
                        selectedPersonnel: _consulted,
                        onSave: (selected) {
                          setState(() {
                            _consulted = selected;
                          });
                        },
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Informed (I)
                  _buildTeamSection(
                    title: 'Informed (I)',
                    icon: Icons.notification_important_outlined,
                    selectedMembers: _informed,
                    onTap: () {
                      _showPersonnelSelectionDialog(
                        title: 'Select Informed Members',
                        selectedPersonnel: _informed,
                        onSave: (selected) {
                          setState(() {
                            _informed = selected;
                          });
                        },
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  ElevatedButton(
                    onPressed: _savePrd,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(isEditing ? 'Update PRD' : 'Create PRD'),
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    IconData? icon,
    int maxLines = 1,
    String? hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        validator: validator,
        maxLines: maxLines,
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              color: Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamSection({
    required String title,
    required IconData icon,
    required List<String> selectedMembers,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.edit,
                  size: 16,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
            if (selectedMembers.isEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'No members selected. Tap to select.',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selectedMembers.map((member) {
                  return Chip(
                    label: Text(member),
                    backgroundColor: Color.alphaBlend(
                      Theme.of(context).primaryColor.withAlpha(25), // Using withAlpha instead of withOpacity
                      Colors.white,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() {
                        selectedMembers.remove(member);
                      });
                    },
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