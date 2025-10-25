import 'package:flutter/material.dart';

import '../models/podcast.dart';
import '../services/podcast_repository.dart';
import 'episodes_tab.dart';
import 'profile_tab.dart';
import 'subscription_detail_screen.dart';
import 'subscriptions_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.repository});

  final PodcastRepository repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  _HomeStatus _status = _HomeStatus.loading;
  List<Podcast> _podcasts = const [];
  String? _errorMessage;
  final List<String> _queueOrder = [];
  final Set<String> _favoriteEpisodeIds = {};

  @override
  void initState() {
    super.initState();
    _loadPodcasts();
  }

  Future<void> _loadPodcasts() async {
    setState(() {
      _status = _HomeStatus.loading;
      _errorMessage = null;
    });

    try {
      final podcasts = await widget.repository.fetchFeaturedPodcasts();
      if (!mounted) return;
      setState(() {
        _podcasts = podcasts;
        _status = podcasts.isEmpty ? _HomeStatus.empty : _HomeStatus.ready;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _status = _HomeStatus.error;
        _errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _buildBody(),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        height: 56,
        selectedIndex: _selectedIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.queue_music_outlined),
            selectedIcon: Icon(Icons.queue_music_rounded),
            label: 'Episodes',
          ),
          NavigationDestination(
            icon: Icon(Icons.rss_feed_outlined),
            selectedIcon: Icon(Icons.rss_feed_rounded),
            label: 'Subscriptions',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onDestinationSelected:
            _status == _HomeStatus.ready || _status == _HomeStatus.empty
            ? (index) {
                setState(() {
                  _selectedIndex = index;
                });
              }
            : null,
      ),
    );
  }

  Widget _buildBody() {
    switch (_status) {
      case _HomeStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case _HomeStatus.error:
        return _ErrorView(
          message:
              _errorMessage ?? 'We couldn’t refresh your podcasts just now.',
          onRetry: _loadPodcasts,
        );
      case _HomeStatus.empty:
        return _EmptyView(onRefresh: _loadPodcasts);
      case _HomeStatus.ready:
        return _buildTabs();
    }
  }

  Widget _buildTabs() {
    final tabs = [
      EpisodesTab(
        key: const PageStorageKey('episodes-tab'),
        podcasts: _podcasts,
        queueOrder: _queueOrder,
        favoriteEpisodeIds: _favoriteEpisodeIds,
        isFavorite: _isFavorite,
        isQueued: _isQueued,
        queueLength: _queueOrder.length,
        addNext: _addEpisodeNext,
        addLast: _addEpisodeLast,
        removeFromQueue: _removeFromQueue,
        toggleFavorite: _toggleFavorite,
      ),
      SubscriptionsTab(
        key: const PageStorageKey('subscriptions-tab'),
        podcasts: _podcasts,
        repository: widget.repository,
        queueEpisodeIds: _queueOrder.toSet(),
        favoriteEpisodeIds: _favoriteEpisodeIds,
        onAdd: _addSubscription,
        onSelect: _openSubscription,
        onRemove: _removeSubscription,
      ),
      ProfileTab(
        key: const PageStorageKey('profile-tab'),
        podcasts: _podcasts,
        queueOrder: _queueOrder,
      ),
    ];

    return IndexedStack(index: _selectedIndex, children: tabs);
  }

  bool _isFavorite(Episode episode) => _favoriteEpisodeIds.contains(episode.id);

  bool _isQueued(Episode episode) => _queueOrder.contains(episode.id);

  void _addEpisodeNext(Episode episode) {
    setState(() {
      _queueOrder.remove(episode.id);
      _queueOrder.insert(0, episode.id);
    });
  }

  void _addEpisodeLast(Episode episode) {
    setState(() {
      _queueOrder.remove(episode.id);
      _queueOrder.add(episode.id);
    });
  }

  void _removeFromQueue(Episode episode) {
    setState(() {
      _queueOrder.remove(episode.id);
    });
  }

  void _toggleFavorite(Episode episode) {
    setState(() {
      if (!_favoriteEpisodeIds.add(episode.id)) {
        _favoriteEpisodeIds.remove(episode.id);
      }
    });
  }

  void _addSubscription(Podcast podcast) {
    if (_podcasts.any((existing) => existing.id == podcast.id)) {
      return;
    }
    setState(() {
      _podcasts = [..._podcasts, podcast];
      if (_status == _HomeStatus.empty && _podcasts.isNotEmpty) {
        _status = _HomeStatus.ready;
      }
    });
  }

  void _removeSubscription(Podcast podcast) {
    setState(() {
      _podcasts = _podcasts.where((p) => p.id != podcast.id).toList();
      final episodeIds = podcast.episodes.map((e) => e.id).toSet();
      _queueOrder.removeWhere(episodeIds.contains);
      _favoriteEpisodeIds.removeWhere(episodeIds.contains);
      if (_podcasts.isEmpty) {
        _status = _HomeStatus.empty;
      }
    });
  }

  void _openSubscription(Podcast podcast) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SubscriptionDetailScreen(
          podcast: podcast,
          isFavorite: _isFavorite,
          isQueued: _isQueued,
          queueLength: _queueOrder.length,
          addNext: _addEpisodeNext,
          addLast: _addEpisodeLast,
          removeFromQueue: _removeFromQueue,
          toggleFavorite: _toggleFavorite,
        ),
      ),
    );
  }
}

enum _HomeStatus { loading, ready, error, empty }

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Connection issue',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No podcasts found',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try again in a moment. We’ll refresh your queue once new shows are available.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}
