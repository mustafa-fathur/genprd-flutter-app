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
        : _endDate ?? (DateTime.now().add(const Duration(days: 30)));
    
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
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildFormField(
              label: 'Product Name',
              controller: _productNameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a product name';
                }
                return null;
              },
              icon: Icons.edit,
            ),
            const SizedBox(height: 16),
            
            _buildFormField(
              label: 'Document Version',
              controller: _documentVersionController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a document version';
                }
                return null;
              },
              icon: Icons.edit,
            ),
            const SizedBox(height: 16),
            
            _buildFormField(
              label: 'Document Owner',
              controller: _documentOwnerController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a document owner';
                }
                return null;
              },
              icon: Icons.edit,
            ),
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to team & roles screen
                // This would be implemented in a real app
              },
              icon: const Icon(Icons.people),
              label: const Text('Team & Roles'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            _buildFormField(
              label: 'Project Overview',
              controller: _projectOverviewController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a project overview';
                }
                return null;
              },
              icon: Icons.edit,
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            
            _buildDateField(
              label: 'Start Date',
              value: _startDate != null 
                  ? DateFormat('MM/dd/yyyy').format(_startDate!)
                  : 'mm/dd/yyyy',
              onTap: () => _selectDate(context, true),
            ),
            const SizedBox(height: 16),
            
            _buildDateField(
              label: 'End Date',
              value: _endDate != null 
                  ? DateFormat('MM/dd/yyyy').format(_endDate!)
                  : 'mm/dd/yyyy',
              onTap: () => _selectDate(context, false),
            ),
            const SizedBox(height: 32),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _savePrd,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(isEditing ? 'Update PRD' : 'Create PRD'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    IconData? icon,
    int maxLines = 1,
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
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
            const Icon(
              Icons.calendar_today,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}