import 'package:flutter/material.dart';
import 'package:genprd/features/prd/views/prd_detail_screen.dart';
import 'package:genprd/features/prd/views/prd_list_screen.dart';
import 'package:genprd/features/personnel/views/personnel_list_screen.dart';
import 'package:genprd/shared/widgets/navigation_bar_widget.dart';
import 'package:genprd/shared/widgets/sidebar.dart';
import 'package:genprd/shared/widgets/top_bar_widget.dart';
import 'package:genprd/shared/config/themes/app_theme.dart';
import 'package:genprd/shared/widgets/screen_title_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh data
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen title
            ScreenTitleWidget(
              title: 'Dashboard', 
              subtitle: 'Welcome back, Mustafa Fathur',
            ),
            const SizedBox(height: 16),
            
            // Stats display
            GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 2,
              childAspectRatio: 2.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildStatItem(
                  context,
                  'Total PRDs',
                  '12',
                  Icons.description,
                ),
                _buildStatItem(
                  context,
                  'Personnel',
                  '8',
                  Icons.people,
                ),
                _buildStatItem(
                  context,
                  'Draft PRDs',
                  '3',
                  Icons.edit_note,
                ),
                _buildStatItem(
                  context,
                  'In Progress',
                  '4',
                  Icons.pending_actions,
                ),
                _buildStatItem(
                  context,
                  'Finished',
                  '3',
                  Icons.task_alt,
                ),
                _buildStatItem(
                  context,
                  'Archived',
                  '2',
                  Icons.archive,
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            const SizedBox(height: 24),
            
            // Recent PRDs section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent PRDs',
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Navigate to PRD list by changing the current index
                    final dashboardState = context.findAncestorStateOfType<_DashboardScreenState>();
                    if (dashboardState != null) {
                      dashboardState._onTabTapped(1); // Index for PRD tab
                    }
                  },
                  icon: Icon(Icons.arrow_forward, size: 16, color: theme.colorScheme.primary),
                  label: Text('See All', style: textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary)),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Column(
              children: [
                _buildRecentPrdItem(
                  context,
                  'SIMSAPRAS',
                  'Last updated: 25/03/2025',
                  AppTheme.badgeColors['In Progress'] ?? Colors.blue.shade700,
                ),
                Divider(height: 1, thickness: 0.5, indent: 72, color: Colors.grey.shade200),
                _buildRecentPrdItem(
                  context,
                  'SIRANCAK',
                  'Last updated: 17/02/2025',
                  AppTheme.badgeColors['Finished'] ?? Colors.green.shade700,
                ),
                Divider(height: 1, thickness: 0.5, indent: 72, color: Colors.grey.shade200),
                _buildRecentPrdItem(
                  context,
                  'Gojek Lite',
                  'Last updated: 01/01/2026',
                  AppTheme.badgeColors['Draft'] ?? Colors.orange.shade700,
                ),
                Divider(height: 1, thickness: 0.5, indent: 72, color: Colors.grey.shade200),
                _buildRecentPrdItem(
                  context,
                  'Food Delivery App',
                  'Last updated: 18/04/2025',
                  AppTheme.badgeColors['Archived'] ?? Colors.grey.shade700,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final primaryColor = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPrdItem(
    BuildContext context,
    String title,
    String subtitle,
    Color backgroundColor, // We'll reuse this parameter for badge color
  ) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final primaryColor = theme.colorScheme.primary;
    
    // Determine status from background color (temporary solution until refactoring)
    String status = 'Draft';
    if (backgroundColor == AppTheme.badgeColors['Finished'] || backgroundColor == Colors.green.shade100) {
      status = 'Finished';
    } else if (backgroundColor == AppTheme.badgeColors['In Progress'] || backgroundColor == Colors.blue.shade100) {
      status = 'In Progress';
    } else if (backgroundColor == AppTheme.badgeColors['Archived'] || backgroundColor == Colors.grey.shade100) {
      status = 'Archived';
    }

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
      splashColor: theme.colorScheme.primary.withOpacity(0.1),
      highlightColor: theme.colorScheme.primary.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: primaryColor.withOpacity(0.1),
              radius: 20,
              child: Icon(
                Icons.description,
                color: primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.badgeColors[status]?.withOpacity(0.15) ?? backgroundColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: textTheme.bodySmall?.copyWith(
                  color: AppTheme.badgeColors[status] ?? backgroundColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}