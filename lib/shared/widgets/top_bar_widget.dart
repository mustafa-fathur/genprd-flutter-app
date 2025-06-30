import 'package:flutter/material.dart';
import 'package:genprd/shared/config/routes/app_router.dart';
import 'package:genprd/features/prd/views/notification_settings_screen.dart';

class TopBarWidget extends StatelessWidget {
  final String title;
  final VoidCallback onMenuPressed;

  const TopBarWidget({
    super.key,
    required this.title,
    required this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.white,
      shadowColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(Icons.menu, color: primaryColor),
        padding: EdgeInsets.zero,
        onPressed: onMenuPressed,
      ),
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
        IconButton(
          icon: const Icon(Icons.notifications),
          tooltip: 'Notification Settings',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const NotificationSettingsScreen(),
              ),
            );
          },
        ),
        GestureDetector(
          onTap: () {
            AppRouter.navigateToUserProfile(context);
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: const AssetImage('assets/images/profile.jpg'),
            ),
          ),
        ),
      ],
    );
  }
}
