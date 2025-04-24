import 'package:flutter/material.dart';
import 'package:genprd/views/screens/user_profile_screen.dart';

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
    return AppBar(
      title: Text(title),
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: onMenuPressed,
      ),
      actions: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserProfileScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).primaryColor.withAlpha(50),
              backgroundImage: const AssetImage(
                'assets/images/profile.jpg',
              ),
            ),
          ),
        ),
      ],
    );
  }
}