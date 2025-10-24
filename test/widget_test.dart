// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:phonic/main.dart';
import 'package:phonic/models/podcast.dart';
import 'package:phonic/services/podcast_repository.dart';

void main() {
  testWidgets('Home screen renders core sections', (tester) async {
    await tester.pumpWidget(PhonicApp(repository: FakePodcastRepository()));
    await tester.pumpAndSettle();

    expect(find.text('New'), findsOneWidget);
    expect(find.text('Queue'), findsOneWidget);
    expect(find.text('Random order'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.text('Subscriptions'));
    await tester.pumpAndSettle();
    expect(find.text('Add subscription'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Auto-download over Wi-Fi'), findsOneWidget);
  });
}

class FakePodcastRepository implements PodcastRepository {
  @override
  Future<List<Podcast>> fetchFeaturedPodcasts() async {
    final episodes = [
      Episode(
        id: 'ep1',
        title: 'Sample Episode',
        duration: const Duration(minutes: 32),
        publishedAt: DateTime.now(),
        summary: 'A sample episode for testing.',
      ),
      Episode(
        id: 'ep2',
        title: 'Another Episode',
        duration: const Duration(minutes: 27),
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
        summary: 'Another sample episode.',
      ),
    ];

    return [
      Podcast(
        id: 'pod1',
        title: 'Test Podcast',
        host: 'Test Host',
        description: 'A test podcast used in widget tests.',
        category: 'Testing',
        brandColor: Colors.blue,
        episodes: episodes,
        imageUrl: null,
      ),
    ];
  }
}
