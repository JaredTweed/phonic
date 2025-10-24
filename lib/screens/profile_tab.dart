import 'package:flutter/material.dart';

import '../models/podcast.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.podcasts,
    required this.queueOrder,
  });

  final List<Podcast> podcasts;
  final List<String> queueOrder;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  static const int _minAutoDownloadEpisodes = 1;
  static const int _defaultAutoDownloadEpisodes = 3;
  static const double _averageMbPerMinute = 1.6;

  int _autoDownloadEpisodes = _defaultAutoDownloadEpisodes;
  bool _autoDownloadFullQueue = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = _buildStats();
    final queueEpisodes = _queueEpisodes;
    final queueMinutes = queueEpisodes.fold<int>(
      0,
      (sum, episode) => sum + episode.duration.inMinutes,
    );
    final queueSubtitle = queueEpisodes.isEmpty
        ? 'Queue is empty — add shows to keep downloads flowing.'
        : '${queueEpisodes.length} episodes • $queueMinutes min total';

    final maxSelectableEpisodes = queueEpisodes.isEmpty
        ? _minAutoDownloadEpisodes
        : queueEpisodes.length;
    final sliderValue = queueEpisodes.isEmpty
        ? _minAutoDownloadEpisodes.toDouble()
        : _autoDownloadEpisodes
              .clamp(_minAutoDownloadEpisodes, maxSelectableEpisodes)
              .toDouble();

    final selectedEpisodes = _autoDownloadFullQueue || queueEpisodes.isEmpty
        ? queueEpisodes
        : queueEpisodes.take(sliderValue.round()).toList();
    final selectedMinutes = selectedEpisodes.fold<int>(
      0,
      (sum, episode) => sum + episode.duration.inMinutes,
    );
    final downloadEstimate = _downloadEstimateLabel(
      minutes: selectedMinutes.toDouble(),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Fine-tune downloads and see how you listen.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: theme.colorScheme.surfaceContainerLow,
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.35,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Auto-download over Wi-Fi',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Keep a fresh queue ready without touching mobile data.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile.adaptive(
                        value: _autoDownloadFullQueue,
                        contentPadding: EdgeInsets.zero,
                        onChanged: queueEpisodes.isEmpty
                            ? null
                            : (value) {
                                setState(() {
                                  _autoDownloadFullQueue = value;
                                });
                              },
                        title: const Text('Auto-download entire queue'),
                        subtitle: Text(queueSubtitle),
                      ),
                      const SizedBox(height: 12),
                      Opacity(
                        opacity: _autoDownloadFullQueue || queueEpisodes.isEmpty
                            ? 0.4
                            : 1,
                        child: IgnorePointer(
                          ignoring:
                              _autoDownloadFullQueue || queueEpisodes.isEmpty,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Auto-download next ${sliderValue.round()} episodes',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Slider(
                                min: _minAutoDownloadEpisodes.toDouble(),
                                max: maxSelectableEpisodes
                                    .clamp(_minAutoDownloadEpisodes, 50)
                                    .toDouble(),
                                value: sliderValue,
                                divisions: _sliderDivisions(
                                  maxSelectableEpisodes.clamp(
                                    _minAutoDownloadEpisodes,
                                    50,
                                  ),
                                )?.toInt(),
                                label:
                                    '${sliderValue.round().clamp(1, maxSelectableEpisodes)} episodes',
                                onChanged: (value) {
                                  setState(() {
                                    _autoDownloadEpisodes = value.round();
                                  });
                                },
                              ),
                              Text(
                                'Approx. $downloadEstimate over Wi-Fi.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_autoDownloadFullQueue) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Approx. $downloadEstimate for the entire queue.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: stats.map((stat) {
                    return _AnalyticsStatCard(
                      label: stat.label,
                      value: stat.value,
                      caption: stat.caption,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),
                _ListeningHighlights(podcasts: widget.podcasts),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<_AnalyticsStat> _buildStats() {
    final allEpisodes = widget.podcasts
        .expand(
          (podcast) => podcast.episodes.map(
            (episode) =>
                _SubscriptionEpisode(podcast: podcast, episode: episode),
          ),
        )
        .toList();

    final listened = allEpisodes
        .where((entry) => entry.episode.listenedAt != null)
        .toList();

    final totalMinutes = listened.fold<int>(
      0,
      (sum, entry) => sum + entry.episode.duration.inMinutes,
    );

    final offlineCount = allEpisodes
        .where((entry) => entry.episode.isDownloaded)
        .length;

    final completionRate = allEpisodes.isEmpty
        ? 0
        : (listened.length / allEpisodes.length);

    final activeDays = listened
        .map(
          (entry) => DateTime(
            entry.episode.listenedAt!.year,
            entry.episode.listenedAt!.month,
            entry.episode.listenedAt!.day,
          ),
        )
        .toSet()
        .length;

    return [
      _AnalyticsStat(
        label: 'Listening time',
        value: '$totalMinutes min',
        caption: 'Across every session',
      ),
      _AnalyticsStat(
        label: 'Episodes completed',
        value: listened.length.toString(),
        caption: 'Finished from start to end',
      ),
      _AnalyticsStat(
        label: 'Offline queue',
        value: offlineCount.toString(),
        caption: 'Ready without a connection',
      ),
      _AnalyticsStat(
        label: 'Completion rate',
        value: '${(completionRate * 100).round()}%',
        caption: 'Of your current library',
      ),
      _AnalyticsStat(
        label: 'Active days',
        value: activeDays.toString(),
        caption: 'Days you pressed play',
      ),
    ];
  }

  List<Episode> get _queueEpisodes {
    if (widget.queueOrder.isNotEmpty) {
      final map = <String, Episode>{};
      for (final podcast in widget.podcasts) {
        for (final episode in podcast.episodes) {
          map[episode.id] = episode;
        }
      }
      final ordered = widget.queueOrder
          .map((id) => map[id])
          .whereType<Episode>()
          .toList();
      if (ordered.isNotEmpty) {
        return ordered;
      }
    }

    final fallback = widget.podcasts
        .expand((podcast) => podcast.episodes)
        .where((episode) => !episode.isFinished)
        .toList();
    fallback.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return fallback;
  }

  int? _sliderDivisions(int maxSelectable) {
    final range = maxSelectable - _minAutoDownloadEpisodes;
    if (range <= 0) {
      return null;
    }
    return range;
  }

  String _downloadEstimateLabel({required double minutes}) {
    if (minutes <= 0) {
      return '0 MB';
    }
    final megabytes = minutes * _averageMbPerMinute;
    return _formatDataSize(megabytes);
  }

  String _formatDataSize(double megabytes) {
    if (megabytes >= 1024) {
      final gigabytes = megabytes / 1024;
      return '${gigabytes.toStringAsFixed(gigabytes >= 10 ? 1 : 2)} GB';
    }
    return '${megabytes.toStringAsFixed(megabytes >= 10 ? 1 : 2)} MB';
  }
}

class _ListeningHighlights extends StatelessWidget {
  const _ListeningHighlights({required this.podcasts});

  final List<Podcast> podcasts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final listenedMinutesByPodcast = <Podcast, int>{};
    final minutesByCategory = <String, int>{};

    for (final podcast in podcasts) {
      for (final episode in podcast.episodes) {
        if (episode.listenedAt != null) {
          listenedMinutesByPodcast.update(
            podcast,
            (value) => value + episode.duration.inMinutes,
            ifAbsent: () => episode.duration.inMinutes,
          );
          minutesByCategory.update(
            podcast.category,
            (value) => value + episode.duration.inMinutes,
            ifAbsent: () => episode.duration.inMinutes,
          );
        }
      }
    }

    final topShow = listenedMinutesByPodcast.entries.isEmpty
        ? null
        : listenedMinutesByPodcast.entries.reduce(
            (a, b) => a.value >= b.value ? a : b,
          );

    final topCategory = minutesByCategory.entries.isEmpty
        ? null
        : minutesByCategory.entries.reduce(
            (a, b) => a.value >= b.value ? a : b,
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Highlights',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _HighlightTile(
          title: 'Most played show',
          value: topShow?.key.title ?? 'Not enough plays yet',
          subtitle: topShow != null
              ? 'You’ve listened for ${topShow.value} minutes.'
              : 'Press play to start building a listening history.',
        ),
        const SizedBox(height: 12),
        _HighlightTile(
          title: 'Leading category',
          value: topCategory?.key ?? 'To be determined',
          subtitle: topCategory != null
              ? 'Clocked ${topCategory.value} minutes of focused listening.'
              : 'Explore more shows to unlock insights.',
        ),
      ],
    );
  }
}

class _HighlightTile extends StatelessWidget {
  const _HighlightTile({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: theme.colorScheme.surfaceContainerLow,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsStatCard extends StatelessWidget {
  const _AnalyticsStatCard({
    required this.label,
    required this.value,
    required this.caption,
  });

  final String label;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxWidth = MediaQuery.of(context).size.width;
    final targetWidth = maxWidth < 520 ? maxWidth - 40 : 220.0;
    final constrainedWidth = targetWidth.clamp(180.0, 260.0);

    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 180, maxWidth: constrainedWidth),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: theme.colorScheme.surfaceContainerLow,
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              caption,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.85,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsStat {
  const _AnalyticsStat({
    required this.label,
    required this.value,
    required this.caption,
  });

  final String label;
  final String value;
  final String caption;
}

class _SubscriptionEpisode {
  _SubscriptionEpisode({required this.podcast, required this.episode});

  final Podcast podcast;
  final Episode episode;
}
