import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    final meta = '${podcast.title} • ${episode.duration.inMinutes} min';
    final dateLabel = DateFormat('MMM d, yyyy').format(episode.publishedAt);
    final statusIcons = _buildStatusIcons(theme);

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onLongPress: _hasActions ? () => _showOptions(context) : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: theme.colorScheme.surfaceContainerLow,
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          child: _EpisodeContent(
            podcast: podcast,
            episode: episode,
            meta: meta,
            dateLabel: dateLabel,
            statusIcons: statusIcons,
          ),
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
            meta: '${podcast.title} • ${episode.duration.inMinutes} min',
            dateLabel: DateFormat('MMM d, yyyy').format(episode.publishedAt),
            statusIcons: _buildStatusIcons(Theme.of(context)),
          ),
        );
      },
    );
  }

  List<_StatusIcon> _buildStatusIcons(ThemeData theme) {
    final icons = <_StatusIcon>[];
    if (isQueued) {
      icons.add(
        _StatusIcon(
          icon: Icons.queue_music_rounded,
          color: theme.colorScheme.secondary,
        ),
      );
    }
    if (isFavorite) {
      icons.add(
        _StatusIcon(icon: Icons.star_rounded, color: theme.colorScheme.primary),
      );
    }
    if (episode.isDownloaded) {
      icons.add(
        _StatusIcon(
          icon: Icons.download_done_rounded,
          color: theme.colorScheme.tertiary,
        ),
      );
    }
    return icons;
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
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: theme.colorScheme.surfaceContainerHighest,
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.35,
                    ),
                  ),
                ),
                child: child,
              ),
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
    required this.meta,
    required this.dateLabel,
    required this.statusIcons,
  });

  final Podcast podcast;
  final Episode episode;
  final String meta;
  final String dateLabel;
  final List<_StatusIcon> statusIcons;

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
              const SizedBox(height: 4),
              Text(
                dateLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.8,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        if (statusIcons.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: statusIcons
                .map(
                  (data) => Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Icon(data.icon, color: data.color, size: 20),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _StatusIcon {
  const _StatusIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;
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
