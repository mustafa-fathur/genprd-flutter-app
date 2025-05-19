import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class PrdEditScreen extends StatefulWidget {
  final Map<String, dynamic> prdData;
  
  const PrdEditScreen({
    super.key,
    required this.prdData,
  });

  @override
  State<PrdEditScreen> createState() => _PrdEditScreenState();
}

class _PrdEditScreenState extends State<PrdEditScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
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
  late TextEditingController _problemStatementsController;
  late TextEditingController _objectivesController;
  late TextEditingController _timelineController;
  
  // Team & Roles controllers
  late List<String> _stakeholders;
  late List<String> _developers;
  late String? _decisionMaker;
  late String? _accountable;
  late List<String> _responsible;
  late List<String> _consulted;
  late List<String> _informed;
  
  // Project Details controllers
  late TextEditingController _successMetricsController;
  late TextEditingController _userStoriesController;
  late TextEditingController _uiuxLinksController;
  late TextEditingController _referencesController;
  late TextEditingController _additionalNotesController;
  late TextEditingController _constraintsController;

  // Mock personnel data
  final List<Map<String, dynamic>> _personnel = [
    {'name': 'Fulan', 'role': 'AI Engineer'},
    {'name': 'Fulana', 'role': 'Software Engineer'},
    {'name': 'Mustafa Fathur Rahman', 'role': 'Developer'},
    {'name': 'John Doe', 'role': 'Product Manager'},
    {'name': 'Jane Smith', 'role': 'Designer'},
    {'name': 'Maha', 'role': 'Product Owner'},
    {'name': 'Development Team', 'role': 'Engineering'},
    {'name': 'UX Team', 'role': 'Design'},
    {'name': 'QA Team', 'role': 'Quality Assurance'},
    {'name': 'Stakeholders', 'role': 'Business'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeControllers();
  }
  
  void _initializeControllers() {
    // Basic Info
    _titleController = TextEditingController(text: widget.prdData['title'] ?? '');
    _versionController = TextEditingController(text: widget.prdData['version'] ?? '0.1.0');
    _ownerController = TextEditingController(text: widget.prdData['owner'] ?? '');
    _createdDateController = TextEditingController(
        text: DateFormat('MM/dd/yyyy').format(DateTime.now()));
    
    // Dates
    _startDate = widget.prdData['startDate'] != null 
        ? DateTime.parse(widget.prdData['startDate']) 
        : DateTime.now();
    _endDate = widget.prdData['endDate'] != null 
        ? DateTime.parse(widget.prdData['endDate']) 
        : DateTime.now().add(const Duration(days: 30));
    
    // Project Overview
    _overviewController = TextEditingController(text: widget.prdData['overview'] ?? '');
    _problemStatementsController = TextEditingController(text: widget.prdData['problemStatements'] ?? '');
    _objectivesController = TextEditingController(text: widget.prdData['objectives'] ?? '');
    _timelineController = TextEditingController(text: widget.prdData['timeline'] ?? '');
    
    // Team & Roles
    _stakeholders = List<String>.from(widget.prdData['stakeholders'] ?? []);
    _developers = List<String>.from(widget.prdData['developers'] ?? []);
    
    // DARCI roles
    final darci = widget.prdData['darci'] ?? {};
    _decisionMaker = darci['decisionMaker'];
    _accountable = darci['accountable'];
    _responsible = List<String>.from(darci['responsible'] ?? []);
    _consulted = List<String>.from(darci['consulted'] ?? []);
    _informed = List<String>.from(darci['informed'] ?? []);
    
    // Project Details
    _successMetricsController = TextEditingController(text: widget.prdData['successMetrics'] ?? '');
    _userStoriesController = TextEditingController(text: widget.prdData['userStories'] ?? '');
    _uiuxLinksController = TextEditingController(text: widget.prdData['uiuxLinks'] ?? '');
    _referencesController = TextEditingController(text: widget.prdData['references'] ?? '');
    _additionalNotesController = TextEditingController(text: widget.prdData['additionalNotes'] ?? '');
    _constraintsController = TextEditingController(text: widget.prdData['constraints'] ?? '');
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _versionController.dispose();
    _ownerController.dispose();
    _createdDateController.dispose();
    _overviewController.dispose();
    _problemStatementsController.dispose();
    _objectivesController.dispose();
    _timelineController.dispose();
    _successMetricsController.dispose();
    _userStoriesController.dispose();
    _uiuxLinksController.dispose();
    _referencesController.dispose();
    _additionalNotesController.dispose();
    _constraintsController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final firstDate = isStartDate ? DateTime(2020) : _startDate;
    
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
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
        _isDirty = true;
        if (isStartDate) {
          _startDate = pickedDate;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 30));
          }
        } else {
          _endDate = pickedDate;
        }
      });
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
                height: 300,
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
                    setState(() {
                      _isDirty = true;
                    });
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
  
  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Collect all the updated data
      final updatedData = {
        'title': _titleController.text,
        'version': _versionController.text,
        'owner': _ownerController.text,
        'createdDate': _createdDateController.text,
        'startDate': _startDate.toIso8601String(),
        'endDate': _endDate.toIso8601String(),
        'overview': _overviewController.text,
        'problemStatements': _problemStatementsController.text,
        'objectives': _objectivesController.text,
        'timeline': _timelineController.text,
        'stakeholders': _stakeholders,
        'developers': _developers,
        'darci': {
          'decisionMaker': _decisionMaker,
          'accountable': _accountable,
          'responsible': _responsible,
          'consulted': _consulted,
          'informed': _informed,
        },
        'successMetrics': _successMetricsController.text,
        'userStories': _userStoriesController.text,
        'uiuxLinks': _uiuxLinksController.text,
        'references': _referencesController.text,
        'additionalNotes': _additionalNotesController.text,
        'constraints': _constraintsController.text,
        'stage': widget.prdData['stage'] ?? 'In Progress',
        
        // Preserve any other fields that might exist in the original data
        ...widget.prdData,
      };
      
      setState(() {
        _isLoading = false;
        _isDirty = false;
      });
      
      if (mounted) {
        Navigator.pop(context, updatedData);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PRD updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
  
  Future<bool> _onWillPop() async {
    if (!_isDirty) {
      return true;
    }
    
    if (!mounted) return false;
    
    // Use context safely
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('You have unsaved changes. Are you sure you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDirty,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          Navigator.of(context).pop();
        }
      },      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit PRD'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _onWillPop().then((canPop) {
                if (canPop) {
                  Navigator.pop(context);
                }
              });
            },
          ),
          actions: [
            if (_isDirty && !_isLoading)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.save),
                  tooltip: 'Save Changes',
                  onPressed: _saveChanges,
                ),
              ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            indicatorColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Team & Roles'),
              Tab(text: 'Project Details'),
            ],
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 3,
          ),
          elevation: 0,
        ),
        body: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Saving changes...',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ],
                ),
              )
            : Form(
                key: _formKey,
                onChanged: () {
                  if (!_isDirty) {
                    setState(() {
                      _isDirty = true;
                    });
                  }
                },
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildTeamRolesTab(),
                    _buildProjectDetailsTab(),
                  ],
                ),
              ),
        floatingActionButton: _isDirty
            ? FloatingActionButton.extended(
                onPressed: _saveChanges,
                icon: const Icon(Icons.save),
                label: const Text('Save'),
                backgroundColor: Theme.of(context).primaryColor,
              )
            : null,
        bottomNavigationBar: _isDirty
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Color.alphaBlend(
                  Theme.of(context).primaryColor.withAlpha(25),
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
                        backgroundColor: Theme.of(context).primaryColor,
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
  
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PRD Identity Card
          _buildCardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('PRD Identity', icon: Icons.article_outlined),
                _buildTextField(
                  controller: _titleController,
                  label: 'Product Name',
                  hint: 'Enter product name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Product name is required';
                    }
                    return null;
                  },
                  maxLines: 1,
                  prefixIcon: Icons.title,
                ),
                const SizedBox(height: 16),
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _versionController,
                        label: 'Document Version',
                        hint: 'e.g., 1.0.0',
                        maxLines: 1,
                        prefixIcon: Icons.tag,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _ownerController,
                        label: 'Document Owner',
                        hint: 'Enter owner name',
                        maxLines: 1,
                        prefixIcon: Icons.person_outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Created Date
                _buildTextField(
                  controller: _createdDateController,
                  label: 'Created Date',
                  hint: 'MM/DD/YYYY',
                  readOnly: true,
                  maxLines: 1,
                  prefixIcon: Icons.calendar_today,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Project Timeline Card
          _buildCardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Project Timeline', icon: Icons.date_range),
                Row(
                  children: [
                    Expanded(
                      child: _buildDateField(
                        label: 'Start Date',
                        date: _startDate,
                        onTap: () => _selectDate(context, true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDateField(
                        label: 'End Date',
                        date: _endDate,
                        onTap: () => _selectDate(context, false),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Project Overview Card
          _buildCardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Project Overview', icon: Icons.visibility_outlined),
                _buildTextField(
                  controller: _overviewController,
                  label: 'Project Overview',
                  hint: 'Describe the project purpose and goals',
                  maxLines: 6,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Project overview is required';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Problem Statements Card
          _buildCardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Problem Statements', icon: Icons.error_outline),
                _buildTextField(
                  controller: _problemStatementsController,
                  label: 'Problem Statements',
                  hint: 'List the problems this project aims to solve',
                  maxLines: 6,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Objectives Card
          _buildCardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Objectives', icon: Icons.check_circle_outline),
                _buildTextField(
                  controller: _objectivesController,
                  label: 'Objectives',
                  hint: 'List the main objectives of this project',
                  maxLines: 6,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Timeline Details Card
          _buildCardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Timeline Details', icon: Icons.timeline),
                _buildTextField(
                  controller: _timelineController,
                  label: 'Timeline',
                  hint: 'Detail key milestones, phases, and delivery dates',
                  maxLines: 8,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  
  Widget _buildTeamRolesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Team Members Card
          _buildCardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Team Members', icon: Icons.groups),
                
                _buildTeamSection(
                  title: 'Stakeholders',
                  icon: Icons.people_outline,
                  description: 'People who have interest or concern in the project',
                  selectedMembers: _stakeholders,
                  onTap: () {
                    _showPersonnelSelectionDialog(
                      title: 'Select Stakeholders',
                      selectedPersonnel: _stakeholders,
                      onSave: (selected) {
                        setState(() {
                          _stakeholders = selected;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                _buildTeamSection(
                  title: 'Developers',
                  icon: Icons.code,
                  description: 'Team members responsible for implementation',
                  selectedMembers: _developers,
                  onTap: () {
                    _showPersonnelSelectionDialog(
                      title: 'Select Developers',
                      selectedPersonnel: _developers,
                      onSave: (selected) {
                        setState(() {
                          _developers = selected;
                        });
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // DARCI Matrix Card
          _buildCardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('DARCI Matrix', icon: Icons.account_tree),
                
                _buildTeamSection(
                  title: 'Decision Maker (D)',
                  icon: Icons.gavel,
                  description: 'Person with the authority to make final decisions',
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
                
                _buildTeamSection(
                  title: 'Accountable (A)',
                  icon: Icons.account_circle,
                  description: 'Person ultimately answerable for the project',
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
                
                _buildTeamSection(
                  title: 'Responsible (R)',
                  icon: Icons.assignment_ind,
                  description: 'People who do the work to complete tasks',
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
                
                _buildTeamSection(
                  title: 'Consulted (C)',
                  icon: Icons.chat_bubble_outline,
                  description: 'People whose opinions are sought for expertise',
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
                
                _buildTeamSection(
                  title: 'Informed (I)',
                  icon: Icons.notification_important_outlined,
                  description: 'People kept up-to-date on project progress',
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
              ],
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  
  Widget _buildProjectDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success Metrics Card
          _buildCardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Success Metrics', icon: Icons.trending_up),
                _buildTextField(
                  controller: _successMetricsController,
                  label: 'Success Metrics',
                  hint: 'Define how success will be measured for this project',
                  maxLines: 6,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // User Stories Card
          _buildCardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('User Stories', icon: Icons.person_search),
                _buildTextField(
                  controller: _userStoriesController,
                  label: 'User Stories',
                  hint: 'Describe user stories in the format: As a [role], I want [feature] so that [benefit]',
                  maxLines: 10,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // UI/UX Links Card
          _buildCardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('UI/UX Links', icon: Icons.brush),
                _buildTextField(
                  controller: _uiuxLinksController,
                  label: 'UI/UX Design Links',
                  hint: 'Add links to Figma, Sketch or other design files (one per line)',
                  maxLines: 4,
                  suffixIcon: Icons.open_in_new,
                  onSuffixTap: () => _openLinks(_uiuxLinksController.text),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // References Card
          _buildCardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('References', icon: Icons.link),
                _buildTextField(
                  controller: _referencesController,
                  label: 'References',
                  hint: 'Add links to relevant documents, research or resources (one per line)',
                  maxLines: 4,
                  suffixIcon: Icons.open_in_new,
                  onSuffixTap: () => _openLinks(_referencesController.text),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Constraints Card
          _buildCardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Constraints', icon: Icons.block),
                _buildTextField(
                  controller: _constraintsController,
                  label: 'Project Constraints',
                  hint: 'List any constraints (budget, time, technical, etc.)',
                  maxLines: 6,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Additional Notes Card
          _buildCardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Additional Notes', icon: Icons.note_add),
                _buildTextField(
                  controller: _additionalNotesController,
                  label: 'Additional Notes',
                  hint: 'Any other important information about this project',
                  maxLines: 6,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  
  Widget _buildCardContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }
  
  Widget _buildSectionHeader(String title, {IconData? icon}) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: theme.colorScheme.primary, size: 22),
                const SizedBox(width: 10),
              ],
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Divider(
            color: Colors.grey.shade200,
            thickness: 1,
          ),
        ],
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
    bool readOnly = false,
    IconData? prefixIcon,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
  }) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: readOnly ? Colors.grey.shade100 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: primaryColor, size: 20) : null,
              suffixIcon: suffixIcon != null ? 
                IconButton(
                  icon: Icon(suffixIcon, color: primaryColor, size: 20),
                  onPressed: onSuffixTap,
                ) : null,
            ),
            maxLines: maxLines,
            validator: validator,
            style: TextStyle(fontSize: 15),
            cursorColor: primaryColor,
          ),
        ),
      ],
    );
  }
  
  Widget _buildDateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    final formattedDate = DateFormat('MM/dd/yyyy').format(date);
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 20, color: primaryColor),
                const SizedBox(width: 12),
                Text(
                  formattedDate,
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTeamSection({
    required String title,
    required IconData icon,
    required String description,
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
                    Icon(icon, color: primaryColor, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit,
                    size: 16,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
            if (selectedMembers.isEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_add, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Tap to select members',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selectedMembers.map((member) {
                  return Chip(
                    avatar: CircleAvatar(
                      backgroundColor: primaryColor,
                      radius: 12,
                      child: Text(
                        member[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  // Helper method to open links
  Future<void> _openLinks(String linksText) async {
    final links = linksText.split('\n')
        .where((link) => link.trim().isNotEmpty)
        .map((link) => link.trim())
        .toList();
    
    if (links.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No links found'))
        );
      }
      return;
    }
    
    // If just one link, open it directly
    if (links.length == 1) {
      await _launchUrl(links.first);
      return;
    }
    
    // If multiple links, show a dialog to choose
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Open Link'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: links.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    links[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _launchUrl(links[index]);
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.content_copy, size: 16),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: links[index]));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link copied to clipboard'))
                      );
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }
  
  Future<void> _launchUrl(String urlString) async {
    try {
      final url = Uri.parse(urlString);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch URL'))
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid URL: $e'))
        );
      }
    }
  }
}
