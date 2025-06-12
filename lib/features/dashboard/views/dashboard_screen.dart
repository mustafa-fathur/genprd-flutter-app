import 'package:flutter/material.dart';
import 'package:genprd/features/prd/views/prd_detail_screen.dart';
import 'package:genprd/features/prd/views/prd_list_screen.dart';
import 'package:genprd/shared/config/routes/app_router.dart';
import 'package:genprd/shared/views/main_layout.dart';
import 'package:genprd/shared/config/themes/app_theme.dart';
import 'package:genprd/shared/widgets/screen_title_widget.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainLayout(
      title: 'Dashboard',
      selectedItem: NavigationItem.dashboard,
      child: DashboardContent(),
    );
  }
}

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

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
            // Stats display
            GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 2,
              childAspectRatio: 2.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildStatItem(context, 'Total PRDs', '12', Icons.description),
                _buildStatItem(context, 'Draft PRDs', '3', Icons.edit_note),
                _buildStatItem(
                  context,
                  'In Progress',
                  '4',
                  Icons.pending_actions,
                ),
                _buildStatItem(context, 'Finished', '3', Icons.task_alt),
                _buildStatItem(context, 'Archived', '2', Icons.archive),
                _buildStatItem(context, 'Pinned', '1', Icons.push_pin),
              ],
            ),

            const SizedBox(height: 32),

            // Recent PRDs section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent PRDs',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    AppRouter.navigateToAllPrds(context);
                  },
                  icon: Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  label: Text(
                    'See All',
                    style: textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
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
                Divider(
                  height: 1,
                  thickness: 0.5,
                  indent: 72,
                  color: Colors.grey.shade200,
                ),
                _buildRecentPrdItem(
                  context,
                  'SIRANCAK',
                  'Last updated: 17/02/2025',
                  AppTheme.badgeColors['Finished'] ?? Colors.green.shade700,
                ),
                Divider(
                  height: 1,
                  thickness: 0.5,
                  indent: 72,
                  color: Colors.grey.shade200,
                ),
                _buildRecentPrdItem(
                  context,
                  'Gojek Lite',
                  'Last updated: 01/01/2026',
                  AppTheme.badgeColors['Draft'] ?? Colors.orange.shade700,
                ),
                Divider(
                  height: 1,
                  thickness: 0.5,
                  indent: 72,
                  color: Colors.grey.shade200,
                ),
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
          Icon(icon, color: primaryColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
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
    String lastUpdated,
    Color statusColor,
  ) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return InkWell(
      onTap: () {
        AppRouter.navigateToPrdDetail(context, '1');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(Icons.description_outlined, color: statusColor),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastUpdated,
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
