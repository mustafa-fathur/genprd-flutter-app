import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:genprd/features/prd/controllers/prd_controller.dart';
import 'package:lottie/lottie.dart';
import 'package:genprd/shared/utils/platform_helper.dart';

class PrdFormScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const PrdFormScreen({super.key, this.initialData});

  @override
  State<PrdFormScreen> createState() => _PrdFormScreenState();
}

class _PrdFormScreenState extends State<PrdFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _documentVersionController =
      TextEditingController();
  final TextEditingController _projectOverviewController =
      TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isGenerating = false;
  int _currentStep = 0;
  double _progressValue = 0.25; // 25% for first step
  String _stepTitle = "Project Information";

  // Form data
  List<String> _documentOwners = [];
  List<String> _developers = [];
  List<String> _stakeholders = [];

  // DARCI roles
  List<String> _deciderRoles = [];
  List<String> _accountableRoles = [];
  List<String> _responsibleRoles = [];
  List<String> _consultedRoles = [];
  List<String> _informedRoles = [];

  @override
  void initState() {
    super.initState();

    // If editing an existing PRD, populate the form
    if (widget.initialData != null) {
      _populateFormWithInitialData();
    } else {
      // Set default document version
      _documentVersionController.text = '1.0';
    }
  }

  void _populateFormWithInitialData() {
    _productNameController.text = widget.initialData!['product_name'] ?? '';
    _documentVersionController.text =
        widget.initialData!['document_version'] ?? '1.0';
    _projectOverviewController.text =
        widget.initialData!['project_overview'] ?? '';

    if (widget.initialData!['start_date'] != null) {
      _startDate = DateTime.parse(widget.initialData!['start_date']);
    }

    if (widget.initialData!['end_date'] != null) {
      _endDate = DateTime.parse(widget.initialData!['end_date']);
    }

    // Load personnel selections if available
    _documentOwners = List<String>.from(
      widget.initialData!['document_owners'] ?? [],
    );
    _stakeholders = List<String>.from(
      widget.initialData!['stakeholders'] ?? [],
    );
    _developers = List<String>.from(widget.initialData!['developers'] ?? []);

    // Load DARCI roles if available
    if (widget.initialData!['darci_roles'] != null) {
      final darci = widget.initialData!['darci_roles'];
      _deciderRoles = List<String>.from(darci['decider'] ?? []);
      _accountableRoles = List<String>.from(darci['accountable'] ?? []);
      _responsibleRoles = List<String>.from(darci['responsible'] ?? []);
      _consultedRoles = List<String>.from(darci['consulted'] ?? []);
      _informedRoles = List<String>.from(darci['informed'] ?? []);
    }
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _documentVersionController.dispose();
    _projectOverviewController.dispose();
    super.dispose();
  }

  // Update step title based on current step
  void _updateStepTitle() {
    switch (_currentStep) {
      case 0:
        _stepTitle = "Project Information";
        break;
      case 1:
        _stepTitle = "Project Overview";
        break;
      case 2:
        _stepTitle = "DARCI Roles";
        break;
      case 3:
        _stepTitle = "Project Timeline";
        break;
      default:
        _stepTitle = "Project Information";
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate =
        isStartDate
            ? _startDate ?? DateTime.now()
            : _endDate ??
                (_startDate != null
                    ? _startDate!.add(const Duration(days: 30))
                    : DateTime.now().add(const Duration(days: 30)));

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

  // Validate the current step
  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Project Information
        if (_productNameController.text.isEmpty) {
          _showValidationError('Please enter a product name');
          return false;
        }
        if (_documentVersionController.text.isEmpty) {
          _showValidationError('Please enter a document version');
          return false;
        }
        if (_documentOwners.isEmpty) {
          _showValidationError('Please select at least one document owner');
          return false;
        }
        return true;

      case 1: // Project Overview
        if (_projectOverviewController.text.isEmpty) {
          _showValidationError('Please enter a project overview');
          return false;
        }
        if (_developers.isEmpty) {
          _showValidationError('Please select at least one developer');
          return false;
        }
        if (_stakeholders.isEmpty) {
          _showValidationError('Please select at least one stakeholder');
          return false;
        }
        return true;

      case 2: // DARCI Roles
        if (_deciderRoles.isEmpty) {
          _showValidationError('Please select at least one decider');
          return false;
        }
        if (_accountableRoles.isEmpty) {
          _showValidationError('Please select at least one accountable person');
          return false;
        }
        if (_responsibleRoles.isEmpty) {
          _showValidationError('Please select at least one responsible person');
          return false;
        }
        return true;

      case 3: // Project Timeline
        if (_startDate == null) {
          _showValidationError('Please select a start date');
          return false;
        }
        if (_endDate == null) {
          _showValidationError('Please select an end date');
          return false;
        }
        return true;

      default:
        return true;
    }
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Go to next step in the form
  void _nextStep() {
    if (_validateCurrentStep()) {
      if (_currentStep < 3) {
        setState(() {
          _currentStep++;
          _progressValue = (_currentStep + 1) * 0.25;
          _updateStepTitle();
        });
      } else {
        _savePrd();
      }
    }
  }

  // Go to previous step in the form
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _progressValue = (_currentStep + 1) * 0.25;
        _updateStepTitle();
      });
    }
  }

  // Save PRD using AI
  Future<void> _savePrd() async {
    if (_validateCurrentStep()) {
      setState(() {
        _isGenerating = true;
      });

      try {
        final prdController = Provider.of<PrdController>(
          context,
          listen: false,
        );

        // Prepare PRD data with DARCI roles
        final Map<String, List<String>> darciRoles = {
          'decider': _deciderRoles,
          'accountable': _accountableRoles,
          'responsible': _responsibleRoles,
          'consulted': _consultedRoles,
          'informed': _informedRoles,
        };

        // Prepare PRD data
        final prdData = {
          'product_name': _productNameController.text,
          'document_version': _documentVersionController.text,
          'project_overview': _projectOverviewController.text,
          'start_date':
              _startDate != null
                  ? DateFormat('yyyy-MM-dd').format(_startDate!)
                  : null,
          'end_date':
              _endDate != null
                  ? DateFormat('yyyy-MM-dd').format(_endDate!)
                  : null,
          'document_owners': _documentOwners,
          'developers': _developers,
          'stakeholders': _stakeholders,
          'darci_roles': darciRoles,
          'generate_content': true,
          'document_stage': 'draft',
        };

        // Create PRD
        final result = await prdController.createNewPrd(prdData);

        if (result.containsKey('id')) {
          // Navigate to PRD detail screen using go_router
          if (mounted) {
            final String prdId = result['id'].toString();
            GoRouter.of(context).pushReplacement('/prds/$prdId');
          }
        } else {
          throw Exception('Failed to create PRD');
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isGenerating = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // Original method with named parameters
  void _showPersonnelSelectionDialog({
    required String title,
    required List<String> selectedPersonnel,
    required Function(List<String>) onSave,
    bool singleSelect = false,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => PersonnelSelectionDialog(
            title: title,
            selectedPersonnel: selectedPersonnel,
            onSave: onSave,
            singleSelect: singleSelect,
          ),
    );
  }

  // Adapter method for DarciRolesStep
  void _showPersonnelSelectionForDarci(
    String title,
    List<String> selectedPersonnel,
    Function(List<String>) onSave,
  ) {
    _showPersonnelSelectionDialog(
      title: title,
      selectedPersonnel: selectedPersonnel,
      onSave: onSave,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen when generating PRD
    if (_isGenerating) {
      return const GeneratingPrdScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            Text('Back to PRDs'),
          ],
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: PlatformHelper.getScreenPadding(context),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Form header with title and progress indicator
                StepIndicator(
                  currentStep: _currentStep,
                  totalSteps: 4,
                  stepTitle: _stepTitle,
                  progressValue: _progressValue,
                ),

                // Form content - scrollable
                Expanded(child: _buildStepContent()),

                // Navigation buttons
                FormNavigationButtons(
                  onNext: _nextStep,
                  onPrevious: _currentStep > 0 ? _previousStep : null,
                  isLastStep: _currentStep == 3,
                  isFirstStep: _currentStep == 0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build the content for the current step
  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return ProjectInformationStep(
          productNameController: _productNameController,
          documentVersionController: _documentVersionController,
          documentOwners: _documentOwners,
          developers: _developers,
          stakeholders: _stakeholders,
          updateDocumentOwners: (selected) {
            setState(() => _documentOwners = selected);
          },
          updateDevelopers: (selected) {
            setState(() => _developers = selected);
          },
          updateStakeholders: (selected) {
            setState(() => _stakeholders = selected);
          },
          showPersonnelSelectionDialog: _showPersonnelSelectionForDarci,
        );
      case 1:
        return ProjectOverviewStep(
          projectOverviewController: _projectOverviewController,
        );
      case 2:
        return DarciRolesStep(
          deciderRoles: _deciderRoles,
          accountableRoles: _accountableRoles,
          responsibleRoles: _responsibleRoles,
          consultedRoles: _consultedRoles,
          informedRoles: _informedRoles,
          updateDeciderRoles: (selected) {
            setState(() => _deciderRoles = selected);
          },
          updateAccountableRoles: (selected) {
            setState(() => _accountableRoles = selected);
          },
          updateResponsibleRoles: (selected) {
            setState(() => _responsibleRoles = selected);
          },
          updateConsultedRoles: (selected) {
            setState(() => _consultedRoles = selected);
          },
          updateInformedRoles: (selected) {
            setState(() => _informedRoles = selected);
          },
          showPersonnelSelectionDialog: _showPersonnelSelectionForDarci,
        );
      case 3:
        return TimelineStep(
          startDate: _startDate,
          endDate: _endDate,
          selectDate: (isStartDate) => _selectDate(context, isStartDate),
        );
      default:
        return ProjectInformationStep(
          productNameController: _productNameController,
          documentVersionController: _documentVersionController,
          documentOwners: _documentOwners,
          developers: _developers,
          stakeholders: _stakeholders,
          updateDocumentOwners: (selected) {
            setState(() => _documentOwners = selected);
          },
          updateDevelopers: (selected) {
            setState(() => _developers = selected);
          },
          updateStakeholders: (selected) {
            setState(() => _stakeholders = selected);
          },
          showPersonnelSelectionDialog: _showPersonnelSelectionForDarci,
        );
    }
  }
}

// GeneratingPrdScreen Widget
class GeneratingPrdScreen extends StatelessWidget {
  const GeneratingPrdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryColor.withOpacity(0.05), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lottie animation
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Lottie.asset(
                    'assets/animations/Animation - 1749904686881.json',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 40),

                // Title
                Text(
                  'Generating your PRD',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Our AI is creating your document based on your inputs',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Progress indicator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// StepIndicator Widget
class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String stepTitle;
  final double progressValue;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepTitle,
    required this.progressValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create New PRD',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Let AI help you create a comprehensive Product Requirements Document',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),

            // Step indicator and progress
            Row(
              children: [
                Text(
                  stepTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                Text(
                  'Step ${currentStep + 1} of $totalSteps',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),

        // Progress bar
        LinearProgressIndicator(
          value: progressValue,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          minHeight: 4,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// FormNavigationButtons Widget
class FormNavigationButtons extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback? onPrevious;
  final bool isLastStep;
  final bool isFirstStep;

  const FormNavigationButtons({
    super.key,
    required this.onNext,
    this.onPrevious,
    this.isLastStep = false,
    this.isFirstStep = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button (hidden on first step)
          if (!isFirstStep)
            TextButton.icon(
              onPressed: onPrevious,
              icon: Icon(Icons.arrow_back, size: 16),
              label: Text('Back'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[700],
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            )
          else
            const SizedBox(width: 80), // Placeholder for alignment
          // Next/Generate button
          ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isLastStep ? 'Generate PRD' : 'Next',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!isLastStep) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward, size: 16),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// PersonnelSelectionDialog Widget
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

// TimelineStep Widget
class TimelineStep extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(bool isStartDate) selectDate;

  const TimelineStep({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.selectDate,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timeline and milestones for your project',
            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Start Date
          Text(
            'Start Date *',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          _buildDateField(
            context: context,
            label: 'Start Date',
            value:
                startDate != null
                    ? DateFormat('MM/dd/yyyy').format(startDate!)
                    : 'Select date',
            onTap: () => selectDate(true),
          ),
          const SizedBox(height: 20),

          // End Date
          Text(
            'End Date *',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          _buildDateField(
            context: context,
            label: 'End Date',
            value:
                endDate != null
                    ? DateFormat('MM/dd/yyyy').format(endDate!)
                    : 'Select date',
            onTap: () => selectDate(false),
          ),

          // Project duration
          if (startDate != null && endDate != null) ...[
            const SizedBox(height: 16),
            _buildDurationInfo(context),
          ],
        ],
      ),
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: primaryColor, size: 18),
            const SizedBox(width: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                color:
                    value == 'Select date'
                        ? Colors.grey.shade500
                        : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationInfo(BuildContext context) {
    final theme = Theme.of(context);
    final days = endDate!.difference(startDate!).inDays;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.calendar_badge_plus,
            color: theme.colorScheme.primary,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Project duration: $days days (${DateFormat('MMM d').format(startDate!)} - ${DateFormat('MMM d, yyyy').format(endDate!)})',
              style: TextStyle(fontSize: 13, color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ProjectOverviewStep Widget
class ProjectOverviewStep extends StatelessWidget {
  final TextEditingController projectOverviewController;

  const ProjectOverviewStep({
    super.key,
    required this.projectOverviewController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detailed description that AI will enhance',
            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Project Description
          _buildFormField(
            context: context,
            label: 'Project Description *',
            controller: projectOverviewController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a project description';
              }
              return null;
            },
            icon: CupertinoIcons.text_alignleft,
            maxLines: 5,
            hint:
                'Describe your product goals, features, target audience, etc.',
          ),
          const SizedBox(height: 20),

          // AI enhancement note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.sparkles,
                  color: theme.colorScheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'AI will enhance this description with detailed requirements',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.primary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
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
}

// ProjectInformationStep Widget
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
      padding: const EdgeInsets.symmetric(vertical: 20),
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
            onChanged: updateDocumentOwners,
          ),
          const SizedBox(height: 20),

          // Developers
          _buildTeamSection(
            context: context,
            title: 'Developers *',
            icon: CupertinoIcons.person_2_fill,
            selectedMembers: developers,
            onChanged: updateDevelopers,
          ),
          const SizedBox(height: 20),

          // Stakeholders
          _buildTeamSection(
            context: context,
            title: 'Stakeholders *',
            icon: CupertinoIcons.person_3,
            selectedMembers: stakeholders,
            onChanged: updateStakeholders,
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
    required ValueChanged<List<String>> onChanged,
  }) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: primaryColor, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: InlinePersonnelInput(
            label: '',
            personnel: selectedMembers,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

// DarciRolesStep Widget
class DarciRolesStep extends StatelessWidget {
  final List<String> deciderRoles;
  final List<String> accountableRoles;
  final List<String> responsibleRoles;
  final List<String> consultedRoles;
  final List<String> informedRoles;
  final Function(List<String>) updateDeciderRoles;
  final Function(List<String>) updateAccountableRoles;
  final Function(List<String>) updateResponsibleRoles;
  final Function(List<String>) updateConsultedRoles;
  final Function(List<String>) updateInformedRoles;
  final Function(String, List<String>, Function(List<String>))
  showPersonnelSelectionDialog;

  const DarciRolesStep({
    super.key,
    required this.deciderRoles,
    required this.accountableRoles,
    required this.responsibleRoles,
    required this.consultedRoles,
    required this.informedRoles,
    required this.updateDeciderRoles,
    required this.updateAccountableRoles,
    required this.updateResponsibleRoles,
    required this.updateConsultedRoles,
    required this.updateInformedRoles,
    required this.showPersonnelSelectionDialog,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Define the roles and responsibilities for this project',
            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Role: Decider
          _buildDarciRoleInline(
            context: context,
            role: 'Decider *',
            selectedMembers: deciderRoles,
            onChanged: updateDeciderRoles,
          ),
          const SizedBox(height: 20),

          // Role: Accountable
          _buildDarciRoleInline(
            context: context,
            role: 'Accountable *',
            selectedMembers: accountableRoles,
            onChanged: updateAccountableRoles,
          ),
          const SizedBox(height: 20),

          // Role: Responsible
          _buildDarciRoleInline(
            context: context,
            role: 'Responsible *',
            selectedMembers: responsibleRoles,
            onChanged: updateResponsibleRoles,
          ),
          const SizedBox(height: 20),

          // Role: Consulted
          _buildDarciRoleInline(
            context: context,
            role: 'Consulted',
            selectedMembers: consultedRoles,
            onChanged: updateConsultedRoles,
          ),
          const SizedBox(height: 20),

          // Role: Informed
          _buildDarciRoleInline(
            context: context,
            role: 'Informed',
            selectedMembers: informedRoles,
            onChanged: updateInformedRoles,
          ),
        ],
      ),
    );
  }

  Widget _buildDarciRoleInline({
    required BuildContext context,
    required String role,
    required List<String> selectedMembers,
    required ValueChanged<List<String>> onChanged,
    bool singleSelect = false,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          role,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: InlinePersonnelInput(
            label: '',
            personnel: selectedMembers,
            onChanged: onChanged,
            singleSelect: singleSelect,
          ),
        ),
      ],
    );
  }
}

// InlinePersonnelInput Widget
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
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addPerson() {
    final name = _controller.text.trim();
    if (name.isNotEmpty && !widget.personnel.contains(name)) {
      final updated =
          widget.singleSelect ? [name] : [...widget.personnel, name];
      widget.onChanged(updated);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty)
          Text(
            widget.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        if (widget.personnel.isNotEmpty) ...[
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                widget.personnel
                    .map(
                      (person) => Chip(
                        label: Text(
                          person,
                          style: TextStyle(color: primaryColor),
                        ),
                        backgroundColor: primaryColor.withOpacity(0.08),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          final updated = List<String>.from(widget.personnel)
                            ..remove(person);
                          widget.onChanged(updated);
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
        ],
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: widget.hintText ?? 'Enter name',
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
