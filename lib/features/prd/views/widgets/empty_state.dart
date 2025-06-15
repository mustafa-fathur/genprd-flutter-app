import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:genprd/shared/config/routes/app_router.dart';

class EmptyState extends StatelessWidget {
  final bool isNoData;

  const EmptyState({super.key, required this.isNoData});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isNoData ? CupertinoIcons.doc_text : CupertinoIcons.search,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            isNoData ? 'No PRDs found' : 'No matching PRDs',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Text(
            isNoData
                ? 'Create your first PRD to get started'
                : 'Try adjusting your search or filter',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          if (isNoData) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => AppRouter.navigateToCreatePrd(context),
              icon: const Icon(CupertinoIcons.add, size: 16),
              label: const Text('Create PRD'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
