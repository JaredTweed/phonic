import 'package:flutter/material.dart';

import '../models/podcast.dart';
import '../widgets/episode_list_item.dart';

class SubscriptionDetailScreen extends StatelessWidget {
  const SubscriptionDetailScreen({super.key, required this.podcast});

  final Podcast podcast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final episodes = podcast.episodes;

    return Scaffold(
      appBar: AppBar(title: Text(podcast.title)),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CoverArt(imageUrl: podcast.imageUrl, color: podcast.brandColor),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      podcast.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hosted by ${podcast.host}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: theme.colorScheme.surfaceContainerHighest,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Text(podcast.category),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            podcast.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Episodes',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (episodes.isEmpty)
            Text(
              'No episodes available.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            ...episodes.map(
              (episode) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: EpisodeListItem(podcast: podcast, episode: episode),
              ),
            ),
        ],
      ),
    );
  }
}

class _CoverArt extends StatelessWidget {
  const _CoverArt({required this.imageUrl, required this.color});

  final String? imageUrl;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(24);

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: radius,
        child: Image.network(
          imageUrl!,
          height: 140,
          width: 140,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _FallbackCover(color: color),
        ),
      );
    }

    return _FallbackCover(color: color);
  }
}

class _FallbackCover extends StatelessWidget {
  const _FallbackCover({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: color.withValues(alpha: 0.2),
      ),
      child: Icon(Icons.podcasts, color: color, size: 52),
    );
  }
}
