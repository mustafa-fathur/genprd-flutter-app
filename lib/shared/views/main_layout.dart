import 'package:flutter/material.dart';
import 'package:genprd/features/prd/controllers/prd_controller.dart';
import 'package:genprd/shared/config/routes/app_router.dart';
import 'package:genprd/shared/responsive/responsive_layout.dart';
import 'package:provider/provider.dart';
import 'package:genprd/features/user/controllers/user_provider.dart';
import 'package:genprd/shared/config/themes/app_theme.dart';
import 'package:flutter/cupertino.dart';

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

  @override
  void initState() {
    super.initState();
    // Safely load data after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPrdData();
    });
  }

  Future<void> _loadPrdData() async {
    try {
      final prdController = Provider.of<PrdController>(context, listen: false);
      await prdController.loadPinnedPrds();
      await prdController.loadRecentPrds();
    } catch (e) {
      debugPrint('Error loading PRD data: $e');
    }
  }

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        shadowColor: Colors.transparent,
        automaticallyImplyLeading: !showSidebar,
        leading:
            !showSidebar
                ? IconButton(
                  icon: const Icon(Icons.menu),
                  padding: EdgeInsets.zero,
                  onPressed: _openDrawer,
                )
                : null,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo.png', height: 46),
            const SizedBox(width: 2),
            Text(
              'GenPRD',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
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
                    radius: 16,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    backgroundImage:
                        user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                            ? NetworkImage(user.avatarUrl!)
                            : null,
                    child:
                        user?.avatarUrl == null || user!.avatarUrl!.isEmpty
                            ? const Icon(
                              Icons.person,
                              size: 16,
                              color: AppTheme.primaryColor,
                            )
                            : null,
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
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    widget.title,
                    style: theme.textTheme.headlineMedium?.copyWith(
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
      floatingActionButton:
          widget.selectedItem != NavigationItem.dashboard
              ? Container(
                margin: const EdgeInsets.only(bottom: 24.0, right: 8.0),
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(
                    0xFF1F2937,
                  ), // Dark color matching app theme
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      AppRouter.navigateToCreatePrd(context);
                    },
                    child: const Center(
                      child: Icon(Icons.add, color: Colors.white, size: 30),
                    ),
                  ),
                ),
              )
              : null,
      floatingActionButtonLocation: CustomFloatingActionButtonLocation(
        FloatingActionButtonLocation.endFloat,
        24.0,
      ),
    );
  }

  Widget _buildSidebar({bool isDrawer = true}) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final textTheme = theme.textTheme;

    return Container(
      width: isDrawer ? null : 240,
      constraints: BoxConstraints(maxWidth: isDrawer ? 280 : 240),
      color: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDrawer)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
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
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _closeDrawer,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            _buildNavItem(
              icon: CupertinoIcons.square_grid_2x2,
              label: 'Dashboard',
              selected: widget.selectedItem == NavigationItem.dashboard,
              onTap: () => _navigateTo(NavigationItem.dashboard),
            ),
            _buildNavItem(
              icon: CupertinoIcons.doc_text,
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
                  color: AppTheme.textSecondaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Consumer<PrdController>(
              builder: (context, prdController, _) {
                final pinnedPrds = prdController.pinnedPrds;

                if (pinnedPrds.isEmpty) {
                  return _buildNavItem(
                    icon: CupertinoIcons.pin,
                    label: 'Pinned PRDs',
                    selected: widget.selectedItem == NavigationItem.pinnedPrds,
                    onTap: () => _navigateTo(NavigationItem.pinnedPrds),
                  );
                }

                return Column(
                  children: [
                    _buildNavItem(
                      icon: CupertinoIcons.pin,
                      label: 'Pinned PRDs',
                      selected:
                          widget.selectedItem == NavigationItem.pinnedPrds,
                      onTap: () => _navigateTo(NavigationItem.pinnedPrds),
                    ),
                    ...pinnedPrds
                        .take(3)
                        .map(
                          (prd) => _buildPrdItem(
                            prd['product_name'] ?? 'Untitled PRD',
                            onTap:
                                () => AppRouter.navigateToPrdDetail(
                                  context,
                                  prd['id'].toString(),
                                ),
                          ),
                        ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Recent',
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Consumer<PrdController>(
              builder: (context, prdController, _) {
                final recentPrds = prdController.recentPrds;

                if (recentPrds.isEmpty) {
                  return _buildNavItem(
                    icon: CupertinoIcons.clock,
                    label: 'Recent PRDs',
                    selected: widget.selectedItem == NavigationItem.recentPrds,
                    onTap: () => _navigateTo(NavigationItem.recentPrds),
                  );
                }

                return Column(
                  children: [
                    _buildNavItem(
                      icon: CupertinoIcons.clock,
                      label: 'Recent PRDs',
                      selected:
                          widget.selectedItem == NavigationItem.recentPrds,
                      onTap: () => _navigateTo(NavigationItem.recentPrds),
                    ),
                    ...recentPrds
                        .take(3)
                        .map(
                          (prd) => _buildPrdItem(
                            prd['product_name'] ?? 'Untitled PRD',
                            onTap:
                                () => AppRouter.navigateToPrdDetail(
                                  context,
                                  prd['id'].toString(),
                                ),
                          ),
                        ),
                  ],
                );
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: () {
                    AppRouter.navigateToCreatePrd(context);
                  },
                  icon: const Icon(
                    CupertinoIcons.add,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: const Text(
                    'New PRD',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: selected ? primaryColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: selected ? primaryColor : AppTheme.textSecondaryColor,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? primaryColor : AppTheme.textColor,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
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

  Widget _buildPrdItem(String title, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(left: 42, right: 12, top: 4, bottom: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.doc_text,
                size: 14,
                color: AppTheme.textSecondaryColor.withOpacity(0.7),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
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
        AppRouter.navigateToPinnedPrds(context);
        break;
      case NavigationItem.recentPrds:
        AppRouter.navigateToRecentPrds(context);
        break;
    }
  }
}

/// Custom FloatingActionButtonLocation that positions the FAB higher up from the bottom
class CustomFloatingActionButtonLocation extends FloatingActionButtonLocation {
  final FloatingActionButtonLocation _location;
  final double _offsetY;

  const CustomFloatingActionButtonLocation(this._location, this._offsetY);

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final Offset offset = _location.getOffset(scaffoldGeometry);
    return Offset(offset.dx, offset.dy - _offsetY);
  }
}
