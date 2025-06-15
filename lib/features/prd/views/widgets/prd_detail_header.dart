import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:genprd/shared/config/themes/app_theme.dart';
import 'package:intl/intl.dart';

class PrdDetailHeader extends StatelessWidget {
  final String version;
  final String updatedAt;
  final String currentStage;
  final Function(String?) onStageChanged;

  const PrdDetailHeader({
    super.key,
    required this.version,
    required this.updatedAt,
    required this.currentStage,
    required this.onStageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Version $version',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  'Last Updated: ${_formatDateTime(updatedAt)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          _buildStageSelector(context),
        ],
      ),
    );
  }

  Widget _buildStageSelector(BuildContext context) {
    final Color badgeColor = _getStageBadgeColor(currentStage);
    final String displayStage = _getDisplayStage(currentStage);

    return Container(
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: badgeColor.withOpacity(0.3), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentStage,
          isDense: true,
          borderRadius: BorderRadius.circular(8),
          icon: Icon(CupertinoIcons.chevron_down, size: 14, color: badgeColor),
          style: TextStyle(
            color: badgeColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          items: [
            _buildDropdownItem('draft', 'Draft'),
            _buildDropdownItem('inprogress', 'In Progress'),
            _buildDropdownItem('finished', 'Finished'),
            _buildDropdownItem('archived', 'Archived'),
          ],
          onChanged: onStageChanged,
        ),
      ),
    );
  }

  DropdownMenuItem<String> _buildDropdownItem(String value, String label) {
    final Color badgeColor = _getStageBadgeColor(value);

    return DropdownMenuItem(
      value: value,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          label,
          style: TextStyle(color: badgeColor, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  String _getDisplayStage(String stage) {
    switch (stage.toLowerCase()) {
      case 'inprogress':
        return 'In Progress';
      case 'draft':
        return 'Draft';
      case 'finished':
        return 'Finished';
      case 'archived':
        return 'Archived';
      default:
        return stage;
    }
  }

  String _formatDateTime(String dateString) {
    if (dateString.isEmpty) return 'Unknown date';

    try {
      final DateTime date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy HH:mm').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  Color _getStageBadgeColor(String stage) {
    switch (stage.toLowerCase()) {
      case 'draft':
        return AppTheme.badgeColors['Draft'] ?? const Color(0xFFF59E0B);
      case 'inprogress':
        return AppTheme.badgeColors['In Progress'] ?? const Color(0xFF2563EB);
      case 'finished':
        return AppTheme.badgeColors['Finished'] ?? const Color(0xFF10B981);
      case 'archived':
        return AppTheme.badgeColors['Archived'] ?? const Color(0xFF6B7280);
      default:
        return Colors.grey;
    }
  }
}
