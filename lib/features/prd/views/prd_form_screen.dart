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
      
      // TODO: Implement PRD creation/editing logic
      // final prdData = Prd(
      //   title: _titleController.text,
      //   // ... other fields ...
      // );
      
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
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                title, 
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _personnel.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    thickness: 0.5,
                    color: Colors.grey.shade200,
                  ),
                  itemBuilder: (context, index) {
                    final person = _personnel[index];
                    final isSelected = tempSelection.contains(person['name']);
                    return CheckboxListTile(
                      title: Text(
                        person['name'],
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        person['role'],
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                      value: isSelected,
                      activeColor: primaryColor,
                      checkColor: Colors.white,
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
                      controlAffinity: ListTileControlAffinity.trailing,
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey.shade700),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    onSave(tempSelection);
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(foregroundColor: primaryColor),
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
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit PRD' : 'Create New PRD'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextButton.icon(
                onPressed: _savePrd,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
        elevation: 0,
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
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 1,
                    ),
                    child: Text(
                      isEditing ? 'Update PRD' : 'Create PRD',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 6),
        Divider(
          color: Colors.grey.shade200,
          thickness: 1,
        ),
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
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          prefixIcon: icon != null ? Icon(icon, color: primaryColor, size: 20) : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        validator: validator,
        maxLines: maxLines,
        cursorColor: primaryColor,
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: primaryColor,
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
                    style: TextStyle(
                      fontSize: 15,
                      color: theme.colorScheme.onSurface,
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
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final textTheme = theme.textTheme;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
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
                    Icon(icon, color: primaryColor),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.edit,
                  size: 16,
                  color: primaryColor,
                ),
              ],
            ),
            if (selectedMembers.isEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'No members selected. Tap to select.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                  fontSize: 14,
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selectedMembers.map((member) {
                  return Chip(
                    label: Text(
                      member,
                      style: TextStyle(
                        fontSize: 13,
                        color: primaryColor,
                      ),
                    ),
                    backgroundColor: primaryColor.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    visualDensity: VisualDensity.compact,
                    deleteIcon: Icon(Icons.close, size: 16, color: primaryColor),
                    onDeleted: () {
                      setState(() {
                        selectedMembers.remove(member);
                      });
                    },
                    padding: EdgeInsets.symmetric(horizontal: 4),
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