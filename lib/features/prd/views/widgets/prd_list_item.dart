import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:genprd/shared/config/themes/app_theme.dart';
import 'package:intl/intl.dart';

class PrdListItem extends StatelessWidget {
  final Map<String, dynamic> prd;
  final Function(String) onViewDetails;
  final Function(Map<String, dynamic>) onTogglePin;
  final Function(Map<String, dynamic>) onArchive;
  final Function(Map<String, dynamic>) onDelete;

  const PrdListItem({
    super.key,
    required this.prd,
    required this.onViewDetails,
    required this.onTogglePin,
    required this.onArchive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Get stage for badge display
    final String stage = prd['document_stage'] ?? 'draft';
    final String displayStage = _getDisplayStage(stage);

    // Get the appropriate color for the stage badge
    final Color badgeColor = _getStageBadgeColor(stage);

    // Format date for display
    final String updatedAt = _formatDate(prd['updated_at']);

    // Check if PRD is pinned
    final bool isPinned = prd['is_pinned'] == true;

    return InkWell(
      onTap: () => onViewDetails(prd['id'].toString()),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PRD icon with colored background
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        _getStageIcon(stage),
                        color: badgeColor,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // PRD details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title row (no pin icon here anymore)
                        Text(
                          prd['product_name'] ?? 'Untitled PRD',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          prd['project_overview'] ?? 'No description',
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            // Stage badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: badgeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                displayStage,
                                style: textTheme.bodySmall?.copyWith(
                                  color: badgeColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            // Pinned badge (if pinned)
                            if (isPinned)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      CupertinoIcons.pin_fill,
                                      size: 12,
                                      color: theme.primaryColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Pinned',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: theme.primaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            // Updated at text
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                updatedAt,
                                style: textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 3-dots menu positioned at top right
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: _buildPrdItemMenu(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrdItemMenu(BuildContext context) {
    final bool isPinned = prd['is_pinned'] == true;
    final bool isArchived = prd['document_stage'] == 'archived';

    return PopupMenuButton<String>(
      icon: const Icon(
        CupertinoIcons.ellipsis_vertical,
        size: 20,
        color: Colors.black87,
      ),
      padding: EdgeInsets.zero,
      splashRadius: 24,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder:
          (context) => [
            // View option
            PopupMenuItem<String>(
              value: 'view',
              child: _buildMenuItemRow(CupertinoIcons.doc_text, 'View Details'),
            ),
            // Pin/Unpin option
            PopupMenuItem<String>(
              value: 'pin',
              child: _buildMenuItemRow(
                isPinned ? CupertinoIcons.pin_fill : CupertinoIcons.pin,
                isPinned ? 'Unpin' : 'Pin',
              ),
            ),
            // Archive/Unarchive option
            PopupMenuItem<String>(
              value: 'archive',
              child: _buildMenuItemRow(
                isArchived
                    ? CupertinoIcons.tray_arrow_up
                    : CupertinoIcons.archivebox,
                isArchived ? 'Unarchive' : 'Archive',
              ),
            ),
            // Delete option
            PopupMenuItem<String>(
              value: 'delete',
              child: _buildMenuItemRow(
                CupertinoIcons.trash,
                'Delete',
                isDestructive: true,
              ),
            ),
          ],
      onSelected: (value) {
        switch (value) {
          case 'view':
            onViewDetails(prd['id'].toString());
            break;
          case 'pin':
            onTogglePin(prd);
            break;
          case 'archive':
            onArchive(prd);
            break;
          case 'delete':
            onDelete(prd);
            break;
        }
      },
    );
  }

  Widget _buildMenuItemRow(
    IconData icon,
    String label, {
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red : null;
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: color)),
      ],
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

  IconData _getStageIcon(String stage) {
    switch (stage.toLowerCase()) {
      case 'draft':
        return CupertinoIcons.pencil_outline;
      case 'inprogress':
        return CupertinoIcons.arrow_right_circle;
      case 'finished':
        return CupertinoIcons.checkmark_circle;
      case 'archived':
        return CupertinoIcons.archivebox;
      default:
        return CupertinoIcons.doc_text;
    }
  }

  String _formatDate(dynamic dateString) {
    if (dateString == null) return 'Unknown date';

    try {
      final DateTime date = DateTime.parse(dateString.toString());
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return DateFormat('dd/MM/yyyy').format(date);
      }
    } catch (e) {
      return 'Invalid date';
    }
  }
}
