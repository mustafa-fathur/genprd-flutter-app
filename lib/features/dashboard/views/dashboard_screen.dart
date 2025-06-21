import 'package:flutter/material.dart';
import 'package:genprd/features/dashboard/controllers/dashboard_provider.dart';
import 'package:genprd/shared/config/routes/app_router.dart';
import 'package:genprd/shared/views/main_layout.dart';
import 'package:genprd/shared/config/themes/app_theme.dart';
import 'package:genprd/shared/utils/platform_helper.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainLayout(
      title: 'Dashboard',
      subtitle: 'Overview of your Product Requirements Documents',
      selectedItem: NavigationItem.dashboard,
      child: DashboardContent(),
    );
  }
}

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  @override
  void initState() {
    super.initState();
    // Load dashboard data when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(
        context,
        listen: false,
      ).loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, child) {
        return RefreshIndicator(
          onRefresh: () async {
            await dashboardProvider.refreshDashboardData();
          },
          color: AppTheme.primaryColor,
          child: _buildDashboardContent(context, dashboardProvider),
        );
      },
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    DashboardProvider dashboardProvider,
  ) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    switch (dashboardProvider.status) {
      case DashboardStatus.loading:
        if (dashboardProvider.dashboardData.recentPRDs.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          );
        }
        // If we have data but are refreshing, show the data with loading indicator
        break;
      case DashboardStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.exclamationmark_circle,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load dashboard data',
                style: textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                dashboardProvider.errorMessage ?? 'Unknown error',
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => dashboardProvider.loadDashboardData(),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      default:
        break;
    }

    // Show data if available (even during refresh)
    final data = dashboardProvider.dashboardData;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats display
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: PlatformHelper.getGridCrossAxisCount(context),
            childAspectRatio:
                PlatformHelper.isDesktopPlatform(context) ? 2.0 : 1.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildStatItem(
                context,
                'Total PRDs',
                data.counts.totalPRD.toString(),
                CupertinoIcons.doc_text,
                theme.primaryColor,
              ),
              _buildStatItem(
                context,
                'Draft PRDs',
                data.counts.totalDraft.toString(),
                CupertinoIcons.pencil_outline,
                AppTheme.badgeColors['Draft']!,
              ),
              _buildStatItem(
                context,
                'In Progress',
                data.counts.totalInProgress.toString(),
                CupertinoIcons.arrow_right_circle,
                AppTheme.badgeColors['In Progress']!,
              ),
              _buildStatItem(
                context,
                'Finished',
                data.counts.totalFinished.toString(),
                CupertinoIcons.checkmark_circle,
                AppTheme.badgeColors['Finished']!,
              ),
              _buildStatItem(
                context,
                'Archived',
                data.counts.totalArchived.toString(),
                CupertinoIcons.archivebox,
                AppTheme.badgeColors['Archived']!,
              ),
              _buildStatItem(
                context,
                'Pinned',
                data.counts.totalPinned.toString(),
                CupertinoIcons.pin,
                const Color(0xFF9333EA), // Purple
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Recent PRDs section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent PRDs', style: textTheme.headlineSmall),
              TextButton.icon(
                onPressed: () {
                  AppRouter.navigateToAllPrds(context);
                },
                icon: Icon(
                  CupertinoIcons.arrow_right,
                  size: 14,
                  color: theme.primaryColor,
                ),
                label: Text(
                  'View all',
                  style: textTheme.labelLarge?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w500,
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
          const SizedBox(height: 16),

          // Recent PRDs list
          if (data.recentPRDs.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(
                      CupertinoIcons.doc_text,
                      size: 48,
                      color: AppTheme.textSecondaryColor.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No PRDs found',
                      style: textTheme.titleMedium?.copyWith(
                        color: AppTheme.textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first PRD to get started',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        AppRouter.navigateToCreatePrd(context);
                      },
                      icon: const Icon(CupertinoIcons.add, size: 16),
                      label: const Text('Create PRD'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children:
                    data.recentPRDs.asMap().entries.map((entry) {
                      final index = entry.key;
                      final prd = entry.value;

                      return Column(
                        children: [
                          _buildRecentPrdItem(
                            context,
                            prd.productName,
                            'Last updated: ${_formatDate(prd.updatedAt)}',
                            _getStatusColor(prd.documentStage),
                            prd.id,
                            prd.documentStage,
                          ),
                          if (index < data.recentPRDs.length - 1)
                            Divider(
                              height: 1,
                              thickness: 1,
                              indent: 72,
                              color: Colors.grey.shade100,
                            ),
                        ],
                      );
                    }).toList(),
              ),
            ),

          // Loading indicator at the bottom during refresh
          if (dashboardProvider.status == DashboardStatus.loading)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.primaryColor,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Text(
                value,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textColor,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondaryColor,
              fontWeight: FontWeight.w500,
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
    String prdId,
    String status,
  ) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Choose appropriate icon based on status
    IconData statusIcon;
    switch (status.toLowerCase()) {
      case 'draft':
        statusIcon = CupertinoIcons.pencil_outline;
        break;
      case 'inprogress':
        statusIcon = CupertinoIcons.arrow_right_circle;
        break;
      case 'finished':
        statusIcon = CupertinoIcons.checkmark_circle;
        break;
      case 'archived':
        statusIcon = CupertinoIcons.archivebox;
        break;
      default:
        statusIcon = CupertinoIcons.doc_text;
    }

    return InkWell(
      onTap: () {
        AppRouter.navigateToPrdDetail(context, prdId);
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(statusIcon, color: statusColor, size: 18),
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
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: AppTheme.textSecondaryColor.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return AppTheme.badgeColors['Draft'] ?? const Color(0xFFF59E0B);
      case 'inprogress':
        return AppTheme.badgeColors['In Progress'] ?? const Color(0xFF2563EB);
      case 'finished':
        return AppTheme.badgeColors['Finished'] ?? const Color(0xFF10B981);
      case 'archived':
        return AppTheme.badgeColors['Archived'] ?? const Color(0xFF6B7280);
      default:
        return AppTheme.textSecondaryColor;
    }
  }
}
