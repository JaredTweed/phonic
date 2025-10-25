import 'package:flutter/material.dart';

import '../models/podcast.dart';
import '../widgets/episode_list_item.dart';

enum EpisodeFilter { newest, queue, discovery, history, favorites }

class EpisodesTab extends StatefulWidget {
  const EpisodesTab({
    super.key,
    required this.podcasts,
    required this.queueOrder,
    required this.favoriteEpisodeIds,
    required this.isFavorite,
    required this.isQueued,
    required this.queueLength,
    required this.addNext,
    required this.addLast,
    required this.removeFromQueue,
    required this.toggleFavorite,
  });

  final List<Podcast> podcasts;
  final List<String> queueOrder;
  final Set<String> favoriteEpisodeIds;
  final bool Function(Episode episode) isFavorite;
  final bool Function(Episode episode) isQueued;
  final int queueLength;
  final void Function(Episode episode) addNext;
  final void Function(Episode episode) addLast;
  final void Function(Episode episode) removeFromQueue;
  final void Function(Episode episode) toggleFavorite;

  @override
  State<EpisodesTab> createState() => _EpisodesTabState();
}

class _EpisodesTabState extends State<EpisodesTab> {
  EpisodeFilter _filter = EpisodeFilter.newest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = _entriesForFilter(_filter);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Episodes',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 20),
          _FilterPicker(
            selected: _filter,
            onSelected: (filter) {
              setState(() {
                _filter = filter;
              });
            },
          ),
          const SizedBox(height: 16),
          Text(
            _descriptionFor(_filter),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: Text(
                      'Nothing to play just yet.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: entries.length,
                    padding: const EdgeInsets.only(bottom: 16),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return EpisodeListItem(
                        podcast: entry.podcast,
                        episode: entry.episode,
                        isFavorite: widget.isFavorite(entry.episode),
                        isQueued: widget.isQueued(entry.episode),
                        queueLength: widget.queueLength,
                        onAddNext: () => widget.addNext(entry.episode),
                        onAddLast: () => widget.addLast(entry.episode),
                        onRemoveFromQueue: () =>
                            widget.removeFromQueue(entry.episode),
                        onToggleFavorite: () =>
                            widget.toggleFavorite(entry.episode),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                  ),
          ),
        ],
      ),
    );
  }

  List<_EpisodeEntry> get _allEntries => widget.podcasts
      .expand(
        (podcast) => podcast.episodes.map(
          (episode) => _EpisodeEntry(podcast: podcast, episode: episode),
        ),
      )
      .toList();

  Map<String, _EpisodeEntry> get _entryById => {
    for (final entry in _allEntries) entry.episode.id: entry,
  };

  List<_EpisodeEntry> _entriesForFilter(EpisodeFilter filter) {
    switch (filter) {
      case EpisodeFilter.newest:
        final newest = [..._allEntries];
        newest.sort(
          (a, b) => b.episode.publishedAt.compareTo(a.episode.publishedAt),
        );
        return newest;
      case EpisodeFilter.queue:
        final queueEntries = widget.queueOrder
            .map((id) => _entryById[id])
            .whereType<_EpisodeEntry>()
            .toList();
        if (queueEntries.isNotEmpty) {
          return queueEntries;
        }
        return _buildDiscoveryOrder()
            .where((entry) => !entry.episode.isFinished)
            .toList();
      case EpisodeFilter.discovery:
        return _buildDiscoveryOrder();
      case EpisodeFilter.history:
        final history = _allEntries
            .where((entry) => entry.episode.listenedAt != null)
            .toList();
        history.sort(
          (a, b) => b.episode.listenedAt!.compareTo(a.episode.listenedAt!),
        );
        return history;
      case EpisodeFilter.favorites:
        final favorites = widget.favoriteEpisodeIds
            .map((id) => _entryById[id])
            .whereType<_EpisodeEntry>()
            .toList();
        favorites.sort((a, b) {
          final aRef = a.episode.listenedAt ?? a.episode.publishedAt;
          final bRef = b.episode.listenedAt ?? b.episode.publishedAt;
          return bRef.compareTo(aRef);
        });
        return favorites;
    }
  }

  List<_EpisodeEntry> _buildDiscoveryOrder() {
    final queueMap = <Podcast, List<Episode>>{};
    for (final podcast in widget.podcasts) {
      final sortedEpisodes = [...podcast.episodes];
      sortedEpisodes.sort((a, b) {
        final listenedCompare = (a.isFinished ? 1 : 0) - (b.isFinished ? 1 : 0);
        if (listenedCompare != 0) {
          return listenedCompare;
        }
        final aLast = a.listenedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bLast = b.listenedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final lastCompare = aLast.compareTo(bLast);
        if (lastCompare != 0) {
          return lastCompare;
        }
        return b.publishedAt.compareTo(a.publishedAt);
      });
      if (sortedEpisodes.isNotEmpty) {
        queueMap[podcast] = sortedEpisodes;
      }
    }

    final activePodcasts = queueMap.keys.toList()
      ..sort(
        (a, b) => queueMap[b]!.first.publishedAt.compareTo(
          queueMap[a]!.first.publishedAt,
        ),
      );

    final result = <_EpisodeEntry>[];
    var index = 0;
    while (activePodcasts.isNotEmpty) {
      if (index >= activePodcasts.length) {
        index = 0;
      }
      final podcast = activePodcasts[index];
      final queue = queueMap[podcast]!;
      final episode = queue.removeAt(0);
      result.add(_EpisodeEntry(podcast: podcast, episode: episode));
      if (queue.isEmpty) {
        activePodcasts.removeAt(index);
      } else {
        index += 1;
      }
    }
    return result;
  }

  String _descriptionFor(EpisodeFilter filter) {
    switch (filter) {
      case EpisodeFilter.newest:
        return 'Fresh releases across every show you follow.';
      case EpisodeFilter.queue:
        return 'Next up, balanced across every show.';
      case EpisodeFilter.discovery:
        return 'A balanced mix that surfaces unheard episodes first.';
      case EpisodeFilter.history:
        return 'Recently played episodes in the order you heard them.';
      case EpisodeFilter.favorites:
        return 'Episodes you’ve marked for another listen.';
    }
  }
}

class _EpisodeEntry {
  _EpisodeEntry({required this.podcast, required this.episode});

  final Podcast podcast;
  final Episode episode;
}

class _FilterPicker extends StatelessWidget {
  const _FilterPicker({required this.selected, required this.onSelected});

  final EpisodeFilter selected;
  final ValueChanged<EpisodeFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filters = EpisodeFilter.values;
    final labels = <EpisodeFilter, String>{
      EpisodeFilter.newest: 'New',
      EpisodeFilter.queue: 'Queue',
      EpisodeFilter.discovery: 'Random order',
      EpisodeFilter.history: 'History',
      EpisodeFilter.favorites: 'Favorites',
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = filter == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(labels[filter]!),
              selected: isSelected,
              showCheckmark: false,
              onSelected: (_) => onSelected(filter),
              selectedColor: theme.colorScheme.primary.withValues(alpha: 0.12),
              backgroundColor: theme.colorScheme.surfaceContainerLow,
              labelStyle: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : null,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
