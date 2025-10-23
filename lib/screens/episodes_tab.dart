import 'package:flutter/material.dart';

import '../models/podcast.dart';
import '../widgets/episode_list_item.dart';

enum EpisodeFilter { downloads, newest, discovery }

class EpisodesTab extends StatefulWidget {
  const EpisodesTab({super.key, required this.podcasts});

  final List<Podcast> podcasts;

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
          SegmentedButton<EpisodeFilter>(
            segments: const [
              ButtonSegment(
                value: EpisodeFilter.downloads,
                label: Text('Downloads'),
              ),
              ButtonSegment(value: EpisodeFilter.newest, label: Text('New')),
              ButtonSegment(
                value: EpisodeFilter.discovery,
                label: Text('Random order'),
              ),
            ],
            selected: {_filter},
            showSelectedIcon: false,
            onSelectionChanged: (selection) {
              setState(() {
                _filter = selection.first;
              });
            },
          ),
          const SizedBox(height: 12),
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

  List<_EpisodeEntry> _entriesForFilter(EpisodeFilter filter) {
    switch (filter) {
      case EpisodeFilter.downloads:
        final downloads = _allEntries
            .where((entry) => entry.episode.isDownloaded)
            .toList();
        downloads.sort(
          (a, b) =>
              _dateForEpisode(b.episode).compareTo(_dateForEpisode(a.episode)),
        );
        return downloads;
      case EpisodeFilter.newest:
        final newest = [..._allEntries];
        newest.sort(
          (a, b) => b.episode.publishedAt.compareTo(a.episode.publishedAt),
        );
        return newest;
      case EpisodeFilter.discovery:
        return _buildDiscoveryOrder();
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
      case EpisodeFilter.downloads:
        return 'Offline episodes ready for any commute.';
      case EpisodeFilter.newest:
        return 'Fresh releases across every show you follow.';
      case EpisodeFilter.discovery:
        return 'A balanced mix that surfaces unheard episodes first.';
    }
  }

  DateTime _dateForEpisode(Episode episode) {
    return episode.downloadedAt ?? episode.publishedAt;
  }
}

class _EpisodeEntry {
  _EpisodeEntry({required this.podcast, required this.episode});

  final Podcast podcast;
  final Episode episode;
}
