import 'package:flutter/material.dart';

import '../models/podcast.dart';

final List<Podcast> podcasts = [
  Podcast(
    id: 'sonic-journal',
    title: 'Sonic Journal',
    host: 'Mina Carter',
    description:
        'Slow conversations about sound, creativity, and the art of deep listening.',
    category: 'Culture',
    brandColor: const Color(0xFF6D5DFC),
    episodes: [
      Episode(
        id: 'sj-ep-31',
        title: 'Designing Spaces that Sound Good',
        duration: const Duration(minutes: 32),
        publishedAt: DateTime(2024, 3, 12),
        summary:
            'Acoustic designer Lola Park on the spaces that shape the way we feel.',
        isDownloaded: true,
        isFavorite: true,
        downloadedAt: DateTime(2024, 3, 11, 18),
        listenedAt: DateTime(2024, 3, 12, 9, 30),
      ),
      Episode(
        id: 'sj-ep-30',
        title: 'Soundtracking a Morning Routine',
        duration: const Duration(minutes: 27),
        publishedAt: DateTime(2024, 3, 5),
        summary:
            'A sonic meditation on the rituals that guide our first waking hour.',
        isDownloaded: true,
        isFavorite: true,
        downloadedAt: DateTime(2024, 3, 6, 7),
      ),
      Episode(
        id: 'sj-ep-29',
        title: 'Listening to Urban Quiet',
        duration: const Duration(minutes: 31),
        publishedAt: DateTime(2024, 2, 26),
        summary:
            'Mina wanders through early city mornings searching for small silences.',
        listenedAt: DateTime(2024, 2, 27, 20, 12),
        isFavorite: false,
      ),
    ],
  ),
  Podcast(
    id: 'field-notes',
    title: 'Field Notes',
    host: 'The Field Team',
    description:
        'Tiny stories from the people shaping thoughtful, sustainable tech.',
    category: 'Technology',
    brandColor: const Color(0xFF46C2B2),
    episodes: [
      Episode(
        id: 'fn-ep-19',
        title: 'Design Systems in the Wild',
        duration: const Duration(minutes: 24),
        publishedAt: DateTime(2024, 2, 28),
        summary:
            'How small teams keep their design systems resilient under pressure.',
        listenedAt: DateTime(2024, 3, 2, 17, 10),
        isFavorite: true,
      ),
      Episode(
        id: 'fn-ep-18',
        title: 'A Softer Smart Home',
        duration: const Duration(minutes: 29),
        publishedAt: DateTime(2024, 2, 14),
        summary:
            'Product designer Becca Lee on ambient interactions indoors and out.',
        isDownloaded: true,
        downloadedAt: DateTime(2024, 2, 15, 6, 40),
        isFavorite: true,
      ),
      Episode(
        id: 'fn-ep-17',
        title: 'Resilience in Remote Teams',
        duration: const Duration(minutes: 26),
        publishedAt: DateTime(2024, 1, 31),
        summary:
            'Why care rituals matter just as much as well-defined processes.',
        listenedAt: DateTime(2024, 2, 1, 8, 5),
        isFavorite: false,
      ),
    ],
  ),
  Podcast(
    id: 'quiet-hours',
    title: 'Quiet Hours',
    host: 'Niko Tan',
    description:
        'A curated guide to the music and conversations that help us slow down.',
    category: 'Lifestyle',
    brandColor: const Color(0xFFFF7F50),
    episodes: [
      Episode(
        id: 'qh-ep-41',
        title: 'Making Rest a Daily Practice',
        duration: const Duration(minutes: 20),
        publishedAt: DateTime(2024, 1, 19),
        summary:
            'Nervous system specialist Riley Cobb on micro-rest in busy weeks.',
        isDownloaded: true,
        downloadedAt: DateTime(2024, 1, 20, 9),
        listenedAt: DateTime(2024, 1, 20, 21),
        isFavorite: false,
      ),
      Episode(
        id: 'qh-ep-40',
        title: 'Slow Sounds for Soft Evenings',
        duration: const Duration(minutes: 23),
        publishedAt: DateTime(2024, 1, 5),
        summary: 'A playlist of cozy, late winter recommendations.',
        listenedAt: DateTime(2024, 1, 8, 19, 15),
        isFavorite: true,
      ),
      Episode(
        id: 'qh-ep-39',
        title: 'Field Recording a Snow Day',
        duration: const Duration(minutes: 18),
        publishedAt: DateTime(2023, 12, 28),
        summary:
            'Blankets of hush, sparrows, and the creak of old radiators in the background.',
        isFavorite: false,
      ),
    ],
  ),
];

final categories = [
  'For you',
  'New & notable',
  'Slow Living',
  'Design',
  'Tech',
  'Wellness',
];
