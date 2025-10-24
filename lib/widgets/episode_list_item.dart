import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/podcast.dart';

class EpisodeListItem extends StatelessWidget {
  const EpisodeListItem({
    super.key,
    required this.podcast,
    required this.episode,
    this.isFavorite = false,
    this.isQueued = false,
    this.queueLength = 0,
    this.onAddNext,
    this.onAddLast,
    this.onRemoveFromQueue,
    this.onToggleFavorite,
  });

  final Podcast podcast;
  final Episode episode;
  final bool isFavorite;
  final bool isQueued;
  final int queueLength;
  final VoidCallback? onAddNext;
  final VoidCallback? onAddLast;
  final VoidCallback? onRemoveFromQueue;
  final VoidCallback? onToggleFavorite;

  bool get _hasActions =>
      onAddNext != null ||
      onAddLast != null ||
      onRemoveFromQueue != null ||
      onToggleFavorite != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusLabel = _statusLabel;
    final meta = '${podcast.title} • ${episode.duration.inMinutes} min';

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onLongPress: _hasActions ? () => _showOptions(context) : null,
        child: _EpisodeContent(
          podcast: podcast,
          episode: episode,
          statusLabel: statusLabel,
          meta: meta,
          statusIcon: _statusIcon,
          statusColor: _statusColor(theme),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox?;
    final offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final size = renderBox?.size ?? Size.zero;
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Episode actions',
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, _, __) {
        return _EpisodeOptionsDialog(
          isFavorite: isFavorite,
          isQueued: isQueued,
          queueLength: queueLength,
          onAddNext: onAddNext,
          onAddLast: onAddLast,
          onRemoveFromQueue: onRemoveFromQueue,
          onToggleFavorite: onToggleFavorite,
          originalOffset: offset,
          originalSize: size,
          child: _EpisodeContent(
            podcast: podcast,
            episode: episode,
            statusLabel: _statusLabel,
            meta: '${podcast.title} • ${episode.duration.inMinutes} min',
            statusIcon: _statusIcon,
            statusColor: _statusColor(Theme.of(context)),
          ),
        );
      },
    );
  }

  String get _statusLabel {
    if (isFavorite) {
      return 'Favorite';
    }
    if (isQueued) {
      return 'Queued';
    }
    if (episode.isFinished) {
      return 'Played';
    }
    if (episode.isDownloaded) {
      return 'Downloaded';
    }
    return 'Unplayed';
  }

  IconData get _statusIcon {
    if (isFavorite) {
      return Icons.star_rounded;
    }
    if (isQueued) {
      return Icons.queue_music_rounded;
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
    if (isFavorite) {
      return theme.colorScheme.primary;
    }
    if (isQueued) {
      return theme.colorScheme.secondary;
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

class _EpisodeOptionsDialog extends StatelessWidget {
  const _EpisodeOptionsDialog({
    required this.isFavorite,
    required this.isQueued,
    required this.queueLength,
    required this.onAddNext,
    required this.onAddLast,
    required this.onRemoveFromQueue,
    required this.onToggleFavorite,
    required this.originalOffset,
    required this.originalSize,
    required this.child,
  });

  final bool isFavorite;
  final bool isQueued;
  final int queueLength;
  final VoidCallback? onAddNext;
  final VoidCallback? onAddLast;
  final VoidCallback? onRemoveFromQueue;
  final VoidCallback? onToggleFavorite;
  final Offset originalOffset;
  final Size originalSize;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actions = <Widget>[];

    final showAddNext = !isQueued && onAddNext != null;
    final showAddLast = !isQueued && queueLength > 0 && onAddLast != null;
    final showRemove = isQueued && onRemoveFromQueue != null;
    final showFavorite = onToggleFavorite != null;

    if (showAddNext) {
      actions.add(
        _OptionTile(
          label: 'Play next in queue',
          icon: Icons.vertical_align_top_rounded,
          onTap: () {
            Navigator.of(context).pop();
            onAddNext?.call();
          },
        ),
      );
    }

    if (showAddLast) {
      actions.add(
        _OptionTile(
          label: 'Play last in queue',
          icon: Icons.vertical_align_bottom_rounded,
          onTap: () {
            Navigator.of(context).pop();
            onAddLast?.call();
          },
        ),
      );
    }

    if (showRemove) {
      actions.add(
        _OptionTile(
          label: 'Remove from queue',
          icon: Icons.remove_circle_outline,
          onTap: () {
            Navigator.of(context).pop();
            onRemoveFromQueue?.call();
          },
        ),
      );
    }

    if (showFavorite) {
      actions.add(
        _OptionTile(
          label: isFavorite ? 'Remove from favorites' : 'Add to favorites',
          icon: isFavorite ? Icons.star_outline : Icons.star_rounded,
          onTap: () {
            Navigator.of(context).pop();
            onToggleFavorite?.call();
          },
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(color: Colors.black38),
              ),
            ),
          ),
          Positioned(
            left: originalOffset.dx,
            top: originalOffset.dy,
            width: originalSize.width,
            child: Material(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(22),
              child: child,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Material(
                    color: theme.colorScheme.surface,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...actions,
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(label),
    );
  }
}

class _EpisodeContent extends StatelessWidget {
  const _EpisodeContent({
    required this.podcast,
    required this.episode,
    required this.statusLabel,
    required this.meta,
    required this.statusIcon,
    required this.statusColor,
  });

  final Podcast podcast;
  final Episode episode;
  final String statusLabel;
  final String meta;
  final IconData statusIcon;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ArtworkChip(podcast: podcast),
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
        Icon(statusIcon, color: statusColor),
      ],
    );
  }
}

class _ArtworkChip extends StatelessWidget {
  const _ArtworkChip({required this.podcast});

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
              _FallbackArtwork(podcast: podcast),
        ),
      );
    }

    return _FallbackArtwork(podcast: podcast);
  }
}

class _FallbackArtwork extends StatelessWidget {
  const _FallbackArtwork({required this.podcast});

  final Podcast podcast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 56,
      width: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: podcast.brandColor.withValues(alpha: 0.18),
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
    );
  }
}
