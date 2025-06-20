import 'package:flutter/material.dart';
import 'package:genprd/shared/widgets/sidebar.dart';
import 'package:genprd/shared/widgets/top_bar_widget.dart';

class DesktopBody extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final Widget child;
  final String title;
  // onMenuPressed is not needed here as the sidebar is always visible

  const DesktopBody({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.child,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 240,
            color: Colors.white, // Sidebar has its own color
            child: Sidebar(
              onClose: () {}, // No close button needed for desktop sidebar
            ),
          ),
          // Main content area
          Expanded(
            child: Column(
              children: [
                // Top Bar
                TopBarWidget(title: title, onMenuPressed: () {}),
                // Main content
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // No bottomNavigationBar for desktop
    );
  }
}
