import 'package:flutter/material.dart';

import '../models/podcast.dart';
import '../widgets/subscription_tile.dart';

class SubscriptionsTab extends StatelessWidget {
  const SubscriptionsTab({super.key, required this.podcasts});

  final List<Podcast> podcasts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subscriptions',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Manage the shows that shape your queue.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => _showAddSubscriptionSheet(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add subscription'),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: podcasts.isEmpty
                ? Center(
                    child: Text(
                      'You’re not following any shows yet.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: podcasts.length,
                    itemBuilder: (context, index) {
                      final podcast = podcasts[index];
                      return SubscriptionTile(podcast: podcast);
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddSubscriptionSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add a subscription',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Search and curation are coming soon. For now, you can drop an RSS link to connect new shows.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Got it'),
              ),
            ],
          ),
        );
      },
    );
  }
}
