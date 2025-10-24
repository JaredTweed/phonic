// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:phonic/main.dart';

void main() {
  testWidgets('Home screen renders core sections', (tester) async {
    await tester.pumpWidget(const PhonicApp());
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
