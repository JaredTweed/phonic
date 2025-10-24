import 'package:flutter/material.dart';

import '../models/podcast.dart';

class SubscriptionTile extends StatelessWidget {
  const SubscriptionTile({super.key, required this.podcast});

  final Podcast podcast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: theme.colorScheme.surfaceContainerLow,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PodcastArtwork(podcast: podcast),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  podcast.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Hosted by ${podcast.host}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  podcast.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.85,
                    ),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: Text(
                      podcast.category,
                      style: theme.textTheme.labelSmall?.copyWith(
                        letterSpacing: 0.6,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Icon(
            Icons.chevron_right_rounded,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _PodcastArtwork extends StatelessWidget {
  const _PodcastArtwork({required this.podcast});

  final Podcast podcast;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(14);

    if (podcast.imageUrl != null && podcast.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: Image.network(
          podcast.imageUrl!,
          fit: BoxFit.cover,
          height: 56,
          width: 56,
          errorBuilder: (context, __, ___) =>
              _FallbackPodcastArtwork(podcast: podcast),
        ),
      );
    }

    return _FallbackPodcastArtwork(podcast: podcast);
  }
}

class _FallbackPodcastArtwork extends StatelessWidget {
  const _FallbackPodcastArtwork({required this.podcast});

  final Podcast podcast;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      width: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: podcast.brandColor.withValues(alpha: 0.18),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.graphic_eq, color: podcast.brandColor),
    );
  }
}
