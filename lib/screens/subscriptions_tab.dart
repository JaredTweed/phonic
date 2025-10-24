import 'package:flutter/material.dart';

import '../models/podcast.dart';
import '../services/podcast_repository.dart';

class SubscriptionsTab extends StatelessWidget {
  const SubscriptionsTab({
    super.key,
    required this.podcasts,
    required this.repository,
    required this.onAdd,
    required this.onSelect,
  });

  final List<Podcast> podcasts;
  final PodcastRepository repository;
  final ValueChanged<Podcast> onAdd;
  final ValueChanged<Podcast> onSelect;

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
            'Tap a show to dive in or add a new feed via search.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => _showAddSubscriptionSheet(context),
              icon: const Icon(Icons.search_rounded),
              label: const Text('Add via search'),
            ),
          ),
          const SizedBox(height: 20),
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
                : GridView.builder(
                    itemCount: podcasts.length,
                    padding: const EdgeInsets.only(bottom: 20),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _gridCountForWidth(
                        MediaQuery.of(context).size.width,
                      ),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      final podcast = podcasts[index];
                      return _SubscriptionGridItem(
                        podcast: podcast,
                        onTap: () => onSelect(podcast),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  int _gridCountForWidth(double width) {
    if (width >= 960) return 4;
    if (width >= 720) return 3;
    return 2;
  }

  Future<void> _showAddSubscriptionSheet(BuildContext context) async {
    final addedPodcast = await showModalBottomSheet<Podcast>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => _AddSubscriptionSheet(
        repository: repository,
        existingIds: podcasts.map((podcast) => podcast.id).toSet(),
      ),
    );

    if (addedPodcast != null) {
      onAdd(addedPodcast);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Subscribed to ${addedPodcast.title}')),
        );
      }
    }
  }
}

class _SubscriptionGridItem extends StatelessWidget {
  const _SubscriptionGridItem({required this.podcast, required this.onTap});

  final Podcast podcast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: podcast.title,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: _SubscriptionImage(
            imageUrl: podcast.imageUrl,
            color: podcast.brandColor,
          ),
        ),
      ),
    );
  }
}

class _SubscriptionImage extends StatelessWidget {
  const _SubscriptionImage({required this.imageUrl, required this.color});

  final String? imageUrl;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _FallbackGridImage(color: color),
      );
    }
    return _FallbackGridImage(color: color);
  }
}

class _FallbackGridImage extends StatelessWidget {
  const _FallbackGridImage({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color.withValues(alpha: 0.1),
      alignment: Alignment.center,
      child: Icon(Icons.podcasts, color: color, size: 36),
    );
  }
}

class _AddSubscriptionSheet extends StatefulWidget {
  const _AddSubscriptionSheet({
    required this.repository,
    required this.existingIds,
  });

  final PodcastRepository repository;
  final Set<String> existingIds;

  @override
  State<_AddSubscriptionSheet> createState() => _AddSubscriptionSheetState();
}

class _AddSubscriptionSheetState extends State<_AddSubscriptionSheet> {
  final TextEditingController _controller = TextEditingController();
  List<Podcast>? _results;
  bool _isSearching = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + viewInsets),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _performSearch(),
            decoration: const InputDecoration(
              hintText: 'Search podcasts',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: _isSearching ? null : _performSearch,
              child: const Text('Search'),
            ),
          ),
          const SizedBox(height: 16),
          if (_isSearching) ...[
            const SizedBox(height: 12),
            const CircularProgressIndicator(),
          ] else if (_error != null) ...[
            Text(
              _error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ] else if (_results == null) ...[
            Text(
              'Find new shows to follow by searching their title, host, or topic.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ] else if (_results!.isEmpty) ...[
            Text(
              'No shows matched that search.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ] else ...[
            SizedBox(
              height: 320,
              child: ListView.separated(
                itemCount: _results!.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final podcast = _results![index];
                  final alreadyAdded = widget.existingIds.contains(podcast.id);
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: podcast.brandColor.withValues(
                        alpha: 0.15,
                      ),
                      backgroundImage: podcast.imageUrl != null
                          ? NetworkImage(podcast.imageUrl!)
                          : null,
                      child: podcast.imageUrl == null
                          ? Icon(Icons.podcasts, color: podcast.brandColor)
                          : null,
                    ),
                    title: Text(podcast.title),
                    subtitle: Text(
                      podcast.host,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: alreadyAdded
                        ? Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.primary,
                          )
                        : IconButton(
                            icon: const Icon(Icons.add_rounded),
                            onPressed: () => Navigator.of(context).pop(podcast),
                          ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _performSearch() async {
    final query = _controller.text.trim();
    if (query.isEmpty) {
      return;
    }

    setState(() {
      _isSearching = true;
      _error = null;
    });

    try {
      final results = await widget.repository.search(query);
      if (!mounted) return;
      setState(() {
        _results = results;
      });
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _error = err.toString();
        _results = [];
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }
}
