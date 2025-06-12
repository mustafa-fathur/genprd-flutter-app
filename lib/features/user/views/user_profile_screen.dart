import 'package:flutter/material.dart';
import 'package:genprd/features/auth/views/login_screen.dart';
import 'package:genprd/features/user/controllers/user_provider.dart';
import 'package:genprd/shared/config/themes/app_theme.dart'; // Import AppTheme
import 'package:provider/provider.dart'; // Import Provider
import 'package:genprd/features/auth/controllers/auth_provider.dart'; // Import AuthProvider

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch user profile data when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.getUserProfile();
    });
  }

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
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.status == UserProfileStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userProvider.status == UserProfileStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Failed to load profile', style: textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    userProvider.errorMessage ?? 'Unknown error',
                    style: textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => userProvider.getUserProfile(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final user = userProvider.user;

          return SingleChildScrollView(
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
                        color: Theme.of(
                          context,
                        ).colorScheme.secondary.withValues(alpha: 179),
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage:
                            user?.avatarUrl != null &&
                                    user!.avatarUrl!.isNotEmpty
                                ? NetworkImage(user.avatarUrl!)
                                : NetworkImage(
                                  'https://ui-avatars.com/api/?name=${user?.name ?? 'User'}&background=random&color=fff',
                                ),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    const SizedBox(height: 24), // Increased spacing
                    // User info
                    Text(
                      user?.name ?? 'User',
                      style: textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ), // Using a larger text style
                    ),
                    const SizedBox(height: 8), // Increased spacing
                    // Email
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withValues(
                          alpha: 150,
                        ), // Using secondary color with transparency
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        user?.email ?? 'email@example.com',
                        style: textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.primary,
                        ), // Using a larger text style
                      ),
                    ),
                    const SizedBox(height: 12), // Increased spacing
                    Text(
                      userProvider.memberSince == 'Unknown'
                          ? 'Member since: Just joined'
                          : userProvider.memberSince == 'New member'
                          ? 'Member since: Recently joined'
                          : 'Member since: ${userProvider.memberSince}',
                      style: textTheme.bodyMedium?.copyWith(
                        color:
                            userProvider.memberSince == 'New member'
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                        fontWeight:
                            userProvider.memberSince == 'New member'
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
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

                _buildSettingsItem(context, 'Logout', Icons.logout, () {
                  _showLogoutConfirmationDialog(context);
                }, isDestructive: true),

                const SizedBox(height: 40),
                // App info
                Center(
                  child: Column(
                    children: [
                      Text(
                        'GenPRD v1.0',
                        style: textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        'All rights reserved.',
                        style: textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 102),
      ), // Use themed color with some transparency
      onTap: onTap,
    );
  }

  Widget _buildDivider(BuildContext context) {
    final theme = Theme.of(context); // Get theme for color
    return Divider(
      color: theme.colorScheme.onSurfaceVariant.withValues(
        alpha: 77,
      ), // Use themed color with transparency
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
              onPressed: () async {
                Navigator.pop(context); // Close the dialog first

                // Get auth provider and call logout
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                await authProvider.logout();

                // Navigate to login screen and remove all previous routes
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                }
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
