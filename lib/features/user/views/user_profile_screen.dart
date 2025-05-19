import 'package:flutter/material.dart';
import 'package:genprd/features/auth/views/login_screen.dart';
import 'package:genprd/shared/config/themes/app_theme.dart'; // Import AppTheme

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get the current theme
    final textTheme = theme.textTheme; // Get the text theme

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // User Info Section (formerly User Info Card)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile picture with blue circular background
                Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 179),
                  ),
                  child: const CircleAvatar(
                    radius: 60, // Increased avatar size
                    backgroundImage: AssetImage(
                      'assets/images/profile.jpg',
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                ),
                const SizedBox(height: 24), // Increased spacing
                // User info
                Text(
                  'Mustafa Fathur',
                  style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold), // Using a larger text style
                ),
                const SizedBox(height: 8), // Increased spacing
                // Email
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withValues(alpha: 150), // Using secondary color with transparency
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'mustafa.fathur@gmail.com',
                    style: textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primary), // Using a larger text style
                  ),
                ),
                const SizedBox(height: 12), // Increased spacing
                Text(
                  'Member since: January 2025',
                  style: textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant), // Using a slightly larger text style
                ),
                const SizedBox(height: 32), // Increased spacing
              ],
            ),

            // Settings List (formerly Settings Card)
            _buildSettingsItem(
              context,
              'Edit Profile',
              Icons.edit_outlined,
              () {},
            ),
            _buildDivider(context),

            _buildSettingsItem(
              context,
              'Add Pin',
              Icons.lock_outlined,
              () {},
            ),
            _buildDivider(context),

            _buildSettingsItem(
              context,
              'Settings',
              Icons.settings_outlined,
              () {},
            ),
             _buildDivider(context),

             _buildSettingsItem(
              context,
              'Invite a friend',
              Icons.person_add_alt_1_outlined,
              () {},
            ),
            _buildDivider(context),

            _buildSettingsItem(
              context,
              'Logout',
              Icons.logout,
              () {
                _showLogoutConfirmationDialog(context);
              },
              isDestructive: true,
            ),

            const SizedBox(height: 40),
            // App info
            Center(
              child: Column(
                children: [
                  Text(
                    'GenPRD v1.0',
                    style: textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  Text(
                    'All rights reserved.',
                    style: textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context); // Get theme for color
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : theme.textTheme.bodyMedium?.color,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 102)), // Use themed color with some transparency
      onTap: onTap,
    );
  }

  Widget _buildDivider(BuildContext context) {
    final theme = Theme.of(context); // Get theme for color
    return Divider(
      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 77), // Use themed color with transparency
      thickness: 0.5,
      indent: 64,
      endIndent: 16,
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
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
                // Logout and navigate to login screen
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}