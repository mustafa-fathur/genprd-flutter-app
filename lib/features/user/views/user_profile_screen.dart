import 'package:flutter/material.dart';
import 'package:genprd/features/auth/views/login_screen.dart';
import 'package:genprd/features/user/controllers/user_provider.dart';
import 'package:genprd/shared/config/themes/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:genprd/features/auth/controllers/auth_provider.dart';
import 'package:genprd/shared/config/routes/app_router.dart';
import 'package:genprd/shared/utils/logout_helper.dart';
import 'package:genprd/shared/services/token_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/cupertino.dart';

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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final primaryColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Profile',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.status == UserProfileStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }

          if (userProvider.status == UserProfileStatus.error) {
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
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // User Info Section
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile picture with primary color circular background
                    Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor.withOpacity(0.1),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            user?.avatarUrl != null &&
                                    user!.avatarUrl!.isNotEmpty
                                ? NetworkImage(user.avatarUrl!)
                                : null,
                        backgroundColor: primaryColor.withOpacity(0.05),
                        child:
                            user?.avatarUrl == null || user!.avatarUrl!.isEmpty
                                ? Icon(
                                  CupertinoIcons.person_fill,
                                  size: 40,
                                  color: primaryColor.withOpacity(0.7),
                                )
                                : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // User name
                    Text(
                      user?.name ?? 'User',
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Email
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        user?.email ?? 'email@example.com',
                        style: textTheme.bodyMedium?.copyWith(
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Member since
                    Text(
                      userProvider.memberSince == 'Unknown'
                          ? 'Member since: Just joined'
                          : userProvider.memberSince == 'New member'
                          ? 'Member since: Recently joined'
                          : 'Member since: ${userProvider.memberSince}',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryColor,
                        fontWeight:
                            userProvider.memberSince == 'New member'
                                ? FontWeight.w600
                                : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),

                // Settings List
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildSettingsItem(
                        context,
                        'Edit Profile',
                        CupertinoIcons.pencil,
                        () {},
                      ),
                      _buildDivider(context),
                      _buildSettingsItem(
                        context,
                        'Security',
                        CupertinoIcons.shield,
                        () {},
                      ),
                      _buildDivider(context),
                      _buildSettingsItem(
                        context,
                        'Preferences',
                        CupertinoIcons.gear,
                        () {},
                      ),
                      _buildDivider(context),
                      _buildSettingsItem(
                        context,
                        'Invite a Friend',
                        CupertinoIcons.person_add,
                        () {},
                      ),
                      _buildDivider(context),
                      _buildSettingsItem(
                        context,
                        'Logout',
                        CupertinoIcons.square_arrow_right,
                        () {
                          _showLogoutConfirmationDialog(context);
                        },
                        isDestructive: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
                // App info
                Center(
                  child: Column(
                    children: [
                      Text(
                        'GenPRD v1.0',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '© 2025 All rights reserved',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryColor,
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
    final theme = Theme.of(context);
    final color = isDestructive ? theme.colorScheme.error : AppTheme.textColor;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (isDestructive ? theme.colorScheme.error : theme.primaryColor)
              .withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDestructive ? theme.colorScheme.error : theme.primaryColor,
          size: 18,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      trailing: Icon(
        CupertinoIcons.chevron_right,
        color: AppTheme.textSecondaryColor.withOpacity(0.5),
        size: 16,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      color: Colors.grey.shade100,
      thickness: 1,
      height: 1,
      indent: 56,
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppTheme.textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _performLogout();
              },
              child: Text(
                'Logout',
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout() async {
    try {
      // 1. Clear tokens
      await TokenStorage.clearTokens();

      // 2. Get the auth provider and update state
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.forceLogout();

      // 3. Navigate to login screen
      if (mounted) {
        context.go(AppRouter.login);
      }
    } catch (e) {
      debugPrint('Error during logout: $e');
      // Even if there's an error, try to navigate to login
      if (mounted) {
        context.go(AppRouter.login);
      }
    }
  }
}
