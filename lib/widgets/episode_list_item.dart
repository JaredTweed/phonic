import 'package:flutter/material.dart';

import '../models/podcast.dart';

class EpisodeListItem extends StatelessWidget {
  const EpisodeListItem({
    super.key,
    required this.podcast,
    required this.episode,
  });

  final Podcast podcast;
  final Episode episode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusLabel = _statusLabel;
    final meta = '${podcast.title} • ${episode.duration.inMinutes} min';

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
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: podcast.brandColor.withValues(alpha: 0.16),
            ),
            alignment: Alignment.center,
            child: Text(
              podcast.title.isNotEmpty
                  ? podcast.title.substring(0, 1).toUpperCase()
                  : '?',
              style: theme.textTheme.titleMedium?.copyWith(
                color: podcast.brandColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  episode.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  meta,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (episode.summary.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    episode.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.85,
                      ),
                      height: 1.35,
                    ),
                  ),
                ],
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
                      statusLabel,
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
          Icon(_statusIcon, color: _statusColor(theme)),
        ],
      ),
    );
  }

  String get _statusLabel {
    if (episode.isFavorite) {
      return 'Favorite';
    }
    if (episode.isFinished) {
      return 'Played';
    }
    if (episode.isDownloaded) {
      return 'Downloaded';
    }
    return 'Queued';
  }

  IconData get _statusIcon {
    if (episode.isFavorite) {
      return Icons.star_rounded;
    }
    if (episode.isFinished) {
      return Icons.check_circle;
    }
    if (episode.isDownloaded) {
      return Icons.download_done_rounded;
    }
    return Icons.play_arrow_rounded;
  }

  Color _statusColor(ThemeData theme) {
    if (episode.isFavorite) {
      return theme.colorScheme.primary;
    }
    if (episode.isFinished) {
      return theme.colorScheme.primary;
    }
    if (episode.isDownloaded) {
      return theme.colorScheme.secondary;
    }
    return theme.colorScheme.onSurfaceVariant;
  }
}
