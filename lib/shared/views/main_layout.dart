import 'package:flutter/material.dart';
import 'package:genprd/features/dashboard/views/dashboard_screen.dart';
import 'package:genprd/features/prd/views/prd_form_screen.dart';
import 'package:genprd/features/prd/views/prd_list_screen.dart';
import 'package:genprd/features/user/views/user_profile_screen.dart';
import 'package:genprd/shared/config/routes/app_router.dart';
import 'package:genprd/shared/responsive/responsive_layout.dart';
import 'package:provider/provider.dart';
import 'package:genprd/features/user/controllers/user_provider.dart';

enum NavigationItem { dashboard, allPrds, pinnedPrds, recentPrds }

class MainLayout extends StatefulWidget {
  final Widget child;
  final String title;
  final NavigationItem selectedItem;

  const MainLayout({
    super.key,
    required this.child,
    required this.title,
    required this.selectedItem,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _closeDrawer() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveLayout.isDesktop(context);
    final bool isTablet = ResponsiveLayout.isTablet(context);
    final bool showSidebar = isDesktop || isTablet;
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: !showSidebar,
        leading:
            !showSidebar
                ? IconButton(
                  icon: Icon(Icons.menu, color: primaryColor),
                  padding: EdgeInsets.zero,
                  onPressed: _openDrawer,
                )
                : null,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo.png', height: 48),
            const SizedBox(width: 2),
            Text(
              'GenPRD',
              style: TextStyle(
                fontFamily: 'Helvetica Neue',
                fontWeight: FontWeight.w700,
                fontSize: 24,
                color: primaryColor,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        titleSpacing: 0,
        centerTitle: false,
        actions: [
          InkWell(
            onTap: () {
              AppRouter.navigateToUserProfile(context);
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  final user = userProvider.user;
                  return CircleAvatar(
                    radius: 18,
                    backgroundImage:
                        user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                            ? NetworkImage(user.avatarUrl!)
                            : const AssetImage('assets/images/profile.jpg')
                                as ImageProvider,
                  );
                },
              ),
            ),
          ),
        ],
      ),
      drawer: !showSidebar ? _buildSidebar() : null,
      body: Row(
        children: [
          if (showSidebar) _buildSidebar(isDrawer: false),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AppRouter.navigateToCreatePrd(context);
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSidebar({bool isDrawer = true}) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Container(
      width: isDrawer ? null : 250,
      constraints: BoxConstraints(maxWidth: isDrawer ? 280 : 250),
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDrawer)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                color: Colors.white,
                child: Row(
                  children: [
                    Image.asset('assets/images/logo.png', height: 48),
                    const SizedBox(width: 2),
                    Text(
                      'GenPRD',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.close, color: primaryColor),
                      onPressed: _closeDrawer,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            _buildNavItem(
              icon: Icons.dashboard,
              label: 'Dashboard',
              selected: widget.selectedItem == NavigationItem.dashboard,
              onTap: () => _navigateTo(NavigationItem.dashboard),
            ),
            _buildNavItem(
              icon: Icons.description_outlined,
              label: 'All PRDs',
              selected: widget.selectedItem == NavigationItem.allPrds,
              onTap: () => _navigateTo(NavigationItem.allPrds),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Pinned',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildNavItem(
              icon: Icons.push_pin_outlined,
              label: 'Pinned PRDs',
              selected: widget.selectedItem == NavigationItem.pinnedPrds,
              onTap: () => _navigateTo(NavigationItem.pinnedPrds),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Recent',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildNavItem(
              icon: Icons.history_outlined,
              label: 'Recent PRDs',
              selected: widget.selectedItem == NavigationItem.recentPrds,
              onTap: () => _navigateTo(NavigationItem.recentPrds),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    AppRouter.navigateToCreatePrd(context);
                  },
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'New PRD',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: selected ? primaryColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: selected ? primaryColor : Colors.grey[700],
                  size: 22,
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? primaryColor : Colors.grey[800],
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateTo(NavigationItem item) {
    // Close the drawer if it's open
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    // If already on the selected page, don't navigate
    if (widget.selectedItem == item) {
      return;
    }

    switch (item) {
      case NavigationItem.dashboard:
        AppRouter.navigateToDashboard(context);
        break;
      case NavigationItem.allPrds:
        AppRouter.navigateToAllPrds(context);
        break;
      case NavigationItem.pinnedPrds:
        // For now, navigate to all PRDs
        AppRouter.navigateToAllPrds(context);
        break;
      case NavigationItem.recentPrds:
        // For now, navigate to all PRDs
        AppRouter.navigateToAllPrds(context);
        break;
    }
  }
}
