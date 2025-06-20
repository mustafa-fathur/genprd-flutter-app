import 'package:flutter/material.dart';
import 'package:genprd/shared/widgets/top_bar_widget.dart';

class MobileBody extends StatelessWidget {
  final int currentIndex;
  final Function(int) onNavTap;
  final Widget child;
  final String title;
  final VoidCallback? onMenuPressed;

  const MobileBody({
    super.key,
    required this.currentIndex,
    required this.onNavTap,
    required this.child,
    required this.title,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: TopBarWidget(
          title: title,
          onMenuPressed: onMenuPressed ?? () {},
        ),
      ),
      body: Container(color: Colors.white, child: child),
    );
  }
}
