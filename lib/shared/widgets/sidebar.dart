import 'package:flutter/material.dart'; 

class Sidebar extends StatelessWidget {
  final VoidCallback onClose;

  const Sidebar({
    super.key,
    required this.onClose,
  });

  /// Returns true if the sidebar should be shown (desktop/tablet), false for mobile.
  static bool shouldShowSidebar(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get the current theme
    final primaryColor = theme.primaryColor;
    final textTheme = theme.textTheme; // Get the text theme

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              color: primaryColor, // Use primary color from theme
              child: Row(
                children: [
                  Text(
                    'GenPRD',
                    style: textTheme.titleLarge?.copyWith(
                      color: Colors.white, // Keep white color for text in primary colored header
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ), // Use themed text style
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white), // Keep white color for icon
                    onPressed: onClose,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Menu items
            _SidebarMenuItem(
              icon: Icons.dashboard,
              label: 'Dashboard',
              selected: true,
              onTap: () {
                onClose();
                // Navigate to dashboard if not already there
              },
              primaryColor: primaryColor, // Pass primary color
            ),
            _SidebarMenuItem(
              icon: Icons.description_outlined,
              label: 'PRDs',
              selected: false,
              onTap: () {
                onClose();
                // Navigate to PRD list
              },
              primaryColor: primaryColor, // Pass primary color
            ),
            _SidebarMenuItem(
              icon: Icons.people_outline,
              label: 'Personnel',
              selected: false,
              onTap: () {
                onClose();
                // Navigate to personnel list
              },
              primaryColor: primaryColor, // Pass primary color
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Recent',
                style: textTheme.labelLarge?.copyWith(
                  color: Colors.grey[700], // Use a specific grey or theme color if available
                  fontWeight: FontWeight.w600,
                ), // Use themed text style
              ),
            ),
            const SizedBox(height: 8),
            _SidebarRecentItem(title: 'SIMSAPRAS'), // Will update _SidebarRecentItem next
            _SidebarRecentItem(title: 'SIRANCAK'),
            _SidebarRecentItem(title: 'Gojek Lite'),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // New PRD action
                  },
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white), // Keep white icon
                  label: Text(
                    'New PRD',
                    style: textTheme.labelLarge?.copyWith(
                      color: Colors.white, // Keep white text
                      fontWeight: FontWeight.bold,
                    ), // Use themed text style
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor, // Use primary color from theme
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
}

class _SidebarMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color primaryColor;

  const _SidebarMenuItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get theme for color
    final textTheme = theme.textTheme; // Get text theme
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: selected ? primaryColor.withValues(alpha: 128) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: selected ? primaryColor : Colors.grey[700], // Use primary for selected, specific grey otherwise
                  size: 22,
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: selected
                      ? textTheme.bodyMedium?.copyWith(color: primaryColor, fontWeight: FontWeight.bold) // Themed selected style
                      : textTheme.bodyMedium?.copyWith(color: Colors.grey[800]), // Themed unselected style
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarRecentItem extends StatelessWidget {
  final String title;
  const _SidebarRecentItem({required this.title});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme; // Get text theme
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 2),
      child: Text(
        title,
        style: textTheme.bodyMedium?.copyWith(color: Colors.grey[800]), // Use themed text style
      ),
    );
  }
}