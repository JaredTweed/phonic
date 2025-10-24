import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/podcast.dart';

abstract class PodcastRepository {
  Future<List<Podcast>> fetchFeaturedPodcasts();
  Future<List<Podcast>> search(String query);
}

class ItunesPodcastRepository implements PodcastRepository {
  ItunesPodcastRepository({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;
  static const _searchTerms = ['design', 'technology', 'culture'];
  static const _limitPerTerm = 4;
  static const _episodeLimit = 8;

  @override
  Future<List<Podcast>> fetchFeaturedPodcasts() async {
    return _searchAcrossTerms(_searchTerms, limitPerTerm: _limitPerTerm);
  }

  @override
  Future<List<Podcast>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const [];
    }
    return _searchAcrossTerms([trimmed], limitPerTerm: 12);
  }

  Future<List<Podcast>> _searchAcrossTerms(
    List<String> terms, {
    int limitPerTerm = 8,
  }) async {
    final podcasts = <Podcast>[];
    final seen = <String>{};

    for (final term in terms) {
      final searchUri = Uri.https('itunes.apple.com', '/search', {
        'term': term,
        'media': 'podcast',
        'limit': '$limitPerTerm',
      });

      final searchResponse = await _client.get(searchUri);
      if (searchResponse.statusCode != 200) {
        throw Exception(
          'Failed to search podcasts (${searchResponse.statusCode})',
        );
      }

      final searchJson =
          jsonDecode(searchResponse.body) as Map<String, dynamic>;
      final results = (searchJson['results'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();

      for (final result in results) {
        final id = result['collectionId']?.toString();
        if (id == null || seen.contains(id)) {
          continue;
        }

        final detail = await _lookupPodcast(id);
        if (detail == null) {
          continue;
        }

        podcasts.add(detail);
        seen.add(id);
      }
    }

    return podcasts;
  }

  Future<Podcast?> _lookupPodcast(String id) async {
    final lookupUri = Uri.https('itunes.apple.com', '/lookup', {
      'id': id,
      'entity': 'podcastEpisode',
      'limit': '$_episodeLimit',
    });

    final response = await _client.get(lookupUri);
    if (response.statusCode != 200) {
      return null;
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = (data['results'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    if (results.isEmpty) {
      return null;
    }

    final podcastInfo = results.firstWhere(
      (element) => element['wrapperType'] == 'track',
      orElse: () => results.first,
    );

    final episodeResults = results
        .where((item) => item['wrapperType'] == 'podcastEpisode')
        .map(_mapEpisode)
        .where((episode) => episode != null)
        .cast<Episode>()
        .toList();

    if (episodeResults.isEmpty) {
      return null;
    }

    episodeResults.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    return Podcast(
      id: id,
      title:
          (podcastInfo['collectionName'] as String?)?.trim() ??
          'Untitled podcast',
      host: (podcastInfo['artistName'] as String?)?.trim() ?? 'Unknown host',
      description:
          _cleanText(
            podcastInfo['collectionDescription'] as String? ??
                podcastInfo['description'] as String?,
          ) ??
          'A podcast discovered on iTunes.',
      category:
          (podcastInfo['primaryGenreName'] as String?)?.trim() ?? 'Podcasts',
      brandColor: _brandColorFor(id),
      imageUrl:
          podcastInfo['artworkUrl600'] as String? ??
          podcastInfo['artworkUrl100'] as String?,
      feedUrl: podcastInfo['feedUrl'] as String?,
      episodes: episodeResults,
    );
  }

  Episode? _mapEpisode(Map<String, dynamic> json) {
    final title = (json['trackName'] as String?)?.trim();
    final trackId = json['trackId']?.toString();
    if (title == null || trackId == null) {
      return null;
    }

    final durationMillis = (json['trackTimeMillis'] as num?)?.toInt() ?? 0;
    final releaseDate = json['releaseDate'] as String?;
    final summary =
        _cleanText(
          json['shortDescription'] as String? ??
              json['description'] as String? ??
              json['collectionName'] as String?,
        ) ??
        'Episode description unavailable.';

    return Episode(
      id: trackId,
      title: title,
      duration: Duration(milliseconds: durationMillis),
      publishedAt:
          DateTime.tryParse(releaseDate ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      summary: summary,
      audioUrl: json['episodeUrl'] as String? ?? json['previewUrl'] as String?,
      imageUrl:
          json['artworkUrl600'] as String? ?? json['artworkUrl160'] as String?,
    );
  }

  String? _cleanText(String? input) {
    if (input == null) {
      return null;
    }
    final withoutHtml = input.replaceAll(RegExp(r'<[^>]*>'), '');
    return withoutHtml.replaceAll('&nbsp;', ' ').trim();
  }

  Color _brandColorFor(String seed) {
    final hue = seed.hashCode % 360;
    final hsl = HSLColor.fromAHSL(1, hue.toDouble(), 0.55, 0.45);
    return hsl.toColor();
  }
}
