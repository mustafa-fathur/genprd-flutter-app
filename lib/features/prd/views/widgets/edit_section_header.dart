import 'package:flutter/material.dart';

class EditSectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onAddPressed;
  final String? addButtonLabel;
  final bool showDivider;

  const EditSectionHeader({
    super.key,
    required this.title,
    this.onAddPressed,
    this.addButtonLabel,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ),
              if (onAddPressed != null)
                TextButton.icon(
                  onPressed: onAddPressed,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(addButtonLabel ?? 'Add'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
        ),
        if (showDivider) Divider(color: Colors.grey.shade200, thickness: 1),
      ],
    );
  }
}
