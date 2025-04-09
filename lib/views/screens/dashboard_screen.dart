import 'package:flutter/material.dart';
import 'package:genprd/views/screens/prd_detail_screen.dart';
import 'package:genprd/views/screens/prd_list_screen.dart';
import 'package:genprd/views/screens/personnel_list_screen.dart';
import 'package:genprd/views/widgets/navigation_bar_widget.dart';
import 'package:genprd/views/widgets/sidebar.dart';
import 'package:genprd/views/widgets/top_bar_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = [
    const DashboardHomeScreen(),
    const PrdListScreen(),
    const PersonnelListScreen(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'PRDs',
    'Personnel',
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _closeDrawer() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: TopBarWidget(
          title: _titles[_currentIndex],
          onMenuPressed: _openDrawer,
        ),
      ),
      drawer: Sidebar(onClose: _closeDrawer),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBarWidget(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

class DashboardHomeScreen extends StatelessWidget {
  const DashboardHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh data
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User greeting
            const Text(
              'Welcome back,',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Mustafa Fathur',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Stats cards
            Row(
              children: [
                _buildStatCard(
                  context,
                  'Total PRDs',
                  '12',
                  Icons.description,
                  Colors.blue,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  context,
                  'Draft PRDs',
                  '5',
                  Icons.edit_document,
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatCard(
                  context,
                  'Personnel',
                  '12',
                  Icons.people,
                  Colors.green,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  context,
                  'Completed',
                  '7',
                  Icons.check_circle,
                  Colors.purple,
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Recent PRDs section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent PRDs',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Navigate to PRD list
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PrdListScreen()),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('See All'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildRecentPrdItem(
              context,
              'SIMSAPRAS',
              'Last updated: 25/03/2025',
              Colors.blue.shade100,
            ),
            const SizedBox(height: 12),
            
            _buildRecentPrdItem(
              context,
              'SIRANCAK',
              'Last updated: 17/02/2025',
              Colors.green.shade100,
            ),
            const SizedBox(height: 12),
            
            _buildRecentPrdItem(
              context,
              'Gojek Lite',
              'Last updated: 01/01/2026',
              Colors.orange.shade100,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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

  Widget _buildRecentPrdItem(
    BuildContext context,
    String title,
    String subtitle,
    Color backgroundColor,
  ) {
    return InkWell(
      onTap: () {
        // Navigate to PRD detail
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PrdDetailScreen(title: title),
          ),
        );
      },
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.description,
                color: Colors.black54,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}