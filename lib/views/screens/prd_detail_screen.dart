import 'package:flutter/material.dart';
import 'package:genprd/views/screens/prd_edit_screen.dart';

class PrdDetailScreen extends StatefulWidget {
  final String title;
  
  const PrdDetailScreen({
    super.key,
    required this.title,
  });

  @override
  State<PrdDetailScreen> createState() => _PrdDetailScreenState();
}

class _PrdDetailScreenState extends State<PrdDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Add a map to store PRD data
  late Map<String, dynamic> _prdData;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Initialize PRD data - in a real app, this would come from an API or database
    _prdData = {
      'title': widget.title,
      'version': '0.8.2',
      'owner': 'Maha',
      'stage': 'Draft',
      'startDate': '2025-01-01',
      'endDate': '2025-12-31',
      'overview': 'This is a project overview for ${widget.title}. It describes the purpose, goals, and scope of the project.',
      'problemStatements': 'The current system has several limitations:\n\n'
          '1. Performance issues with large datasets\n'
          '2. Limited mobile support\n'
          '3. Lack of integration with other systems\n'
          '4. Poor user experience',
      'objectives': '1. Improve system performance by 50%\n'
          '2. Develop a responsive mobile interface\n'
          '3. Implement API integrations with key systems\n'
          '4. Redesign the user interface for better UX',
      'stakeholders': ['John Doe', 'Jane Smith'],
      'developers': ['Mustafa Fathur Rahman', 'Fulana'],
      'darci': {
        'decisionMaker': 'John Doe',
        'accountable': 'Jane Smith',
        'responsible': ['Development Team'],
        'consulted': ['UX Team', 'QA Team'],
        'informed': ['Stakeholders'],
      },
      'successMetrics': '1. 50% improvement in system performance\n'
          '2. 30% increase in mobile usage\n'
          '3. 25% reduction in support tickets\n'
          '4. 90% user satisfaction rating',
      'timeline': 'January 1, 2025: Project Kickoff\n\n'
          'January 15, 2025: Requirements Finalization\n\n'
          'February 1, 2025: Design Phase Completion\n\n'
          'March 1, 2025: Development Phase Completion\n\n'
          'March 15, 2025: Testing Phase\n\n'
          'April 1, 2025: Project Launch',
    };
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_prdData['title']),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit screen with full prdData
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PrdEditScreen(
                    prdData: _prdData,
                  ),
                ),
              ).then((updatedData) {
                if (updatedData != null) {
                  setState(() {
                    _prdData = updatedData;
                  });
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showOptionsMenu(context);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Team & Roles'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Status bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Version ${_prdData['version']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'Last Updated: 01/01/2025',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _prdData['stage'],
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildTeamRolesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('PRD Identity'),
          _buildInfoCard([
            _buildInfoRow('Product Name:', _prdData['title']),
            _buildInfoRow('Document Version:', _prdData['version']),
            _buildInfoRow('Document Owner:', _prdData['owner']),
            _buildInfoRow('Created Date:', '01/01/2025'),
          ]),
          
          const SizedBox(height: 20),
          _buildSectionHeader('Project Overview'),
          _buildContentCard(_prdData['overview']),
          
          const SizedBox(height: 20),
          _buildSectionHeader('Problem Statements'),
          _buildContentCard(_prdData['problemStatements']),
          
          const SizedBox(height: 20),
          _buildSectionHeader('Objectives'),
          _buildContentCard(_prdData['objectives']),
        ],
      ),
    );
  }

  Widget _buildTeamRolesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Team Members'),
          _buildInfoCard([
            _buildInfoRow('Document Owner:', _prdData['owner']),
            _buildInfoRow('Stakeholders:', _prdData['stakeholders'].join(', ')),
            _buildInfoRow('Developers:', _prdData['developers'].join(', ')),
          ]),
          
          const SizedBox(height: 20),
          _buildSectionHeader('Timeline'),
          _buildContentCard(_prdData['timeline']),
          
          const SizedBox(height: 20),
          _buildSectionHeader('Success Metrics'),
          _buildContentCard(_prdData['successMetrics']),
          
          const SizedBox(height: 20),
          _buildSectionHeader('DARCI Roles'),
          
          _buildDarciRoleCard(
            'Decider',
            _prdData['darci']['decisionMaker'],
            'Responsible for making final decisions on project direction and scope.',
          ),
          const SizedBox(height: 12),
          
          _buildDarciRoleCard(
            'Accountable',
            _prdData['darci']['accountable'],
            'Accountable for the successful delivery of the project.',
          ),
          const SizedBox(height: 12),
          
          _buildDarciRoleCard(
            'Responsible',
            _prdData['darci']['responsible'].join(', '),
            'Responsible for implementing the project requirements.',
          ),
          const SizedBox(height: 12),
          
          _buildDarciRoleCard(
            'Consulted',
            _prdData['darci']['consulted'].join(', '),
            'Consulted for expertise in specific areas of the project.',
          ),
          const SizedBox(height: 12),
          
          _buildDarciRoleCard(
            'Informed',
            _prdData['darci']['informed'].join(', '),
            'Kept informed about project progress and milestones.',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
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
        children: children,
      ),
    );
  }

  Widget _buildContentCard(String content) {
    return Container(
      width: double.infinity,
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
      child: Text(
        content,
        style: const TextStyle(
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildDarciRoleCard(String role, String people, String guidelines) {
    return Container(
      width: double.infinity,
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
          Text(
            role,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            people,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            guidelines,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                title: const Text('Edit PRD'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to edit screen with full prdData
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PrdEditScreen(
                        prdData: _prdData,
                      ),
                    ),
                  ).then((updatedData) {
                    if (updatedData != null) {
                      setState(() {
                        _prdData = updatedData;
                      });
                    }
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.download, color: Theme.of(context).primaryColor),
                title: const Text('Download PRD'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Downloading PRD...')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.archive, color: Theme.of(context).primaryColor),
                title: const Text('Archive PRD'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PRD archived')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete PRD', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmationDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete PRD'),
          content: Text('Are you sure you want to delete "${widget.title}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Go back to PRD list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PRD deleted')),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}