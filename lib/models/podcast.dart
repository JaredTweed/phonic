import 'package:flutter/material.dart';

/// Podcast domain model containing metadata and a collection of episodes.
class Podcast {
  Podcast({
    required this.id,
    required this.title,
    required this.host,
    required this.description,
    required this.category,
    required this.brandColor,
    required this.episodes,
  });

  final String id;
  final String title;
  final String host;
  final String description;
  final String category;
  final Color brandColor;
  final List<Episode> episodes;

  Episode get latestEpisode => episodes.first;
}

/// Lightweight episode model used to populate preview cards within the UI.
class Episode {
  Episode({
    required this.id,
    required this.title,
    required this.duration,
    required this.publishedAt,
    required this.summary,
    this.isDownloaded = false,
    this.isFavorite = false,
    this.downloadedAt,
    this.listenedAt,
  });

  final String id;
  final String title;
  final Duration duration;
  final DateTime publishedAt;
  final String summary;
  final bool isDownloaded;
  final bool isFavorite;
  final DateTime? downloadedAt;
  final DateTime? listenedAt;

  bool get isFinished => listenedAt != null;
}
