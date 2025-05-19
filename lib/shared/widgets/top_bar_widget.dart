import 'package:flutter/material.dart';
import 'package:genprd/features/user/views/user_profile_screen.dart';

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
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Text(
        'GenPRD',
        style: const TextStyle(
          fontFamily: 'Helvetica Neue',
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
      ),
      centerTitle: false,
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
              radius: 18,
              backgroundImage: const AssetImage('assets/images/profile.jpg'),
            ),
          ),
        ),
      ],
    );
  }
}