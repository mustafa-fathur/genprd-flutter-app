import 'package:flutter/material.dart';

class ContentCard extends StatelessWidget {
  final String content;
  final EdgeInsetsGeometry? padding;
  final double? elevation;

  const ContentCard({
    super.key,
    required this.content,
    this.padding,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: elevation ?? 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: Text(
          content,
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
        ),
      ),
    );
  }
}
