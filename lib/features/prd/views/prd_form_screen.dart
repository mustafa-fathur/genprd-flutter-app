import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:genprd/features/prd/controllers/prd_controller.dart';
import 'package:genprd/features/prd/views/widgets/project_information_step.dart';
import 'package:genprd/features/prd/views/widgets/project_overview_step.dart';
import 'package:genprd/features/prd/views/widgets/darci_roles_step.dart';
import 'package:genprd/features/prd/views/widgets/timeline_step.dart';
import 'package:genprd/features/prd/views/widgets/personnel_selection_dialog.dart';
import 'package:genprd/features/prd/views/widgets/generating_prd_screen.dart';
import 'package:genprd/features/prd/views/widgets/step_indicator.dart';
import 'package:genprd/features/prd/views/widgets/form_navigation_buttons.dart';

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
