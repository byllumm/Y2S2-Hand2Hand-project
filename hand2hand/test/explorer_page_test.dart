import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/material.dart';
import 'package:hand2hand/supabase_service.dart';
import 'dart:async';
import 'package:hand2hand/screens/explorer_page.dart';

class MockSupabaseService extends Mock implements SupabaseService {}

void main() {
  late MockSupabaseService mockService;

  setUp(() {
    mockService = MockSupabaseService();
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      home: Scaffold(
        body: ExploreItems(service: mockService),
      ),
    );
  }

  testWidgets('Displays loading indicator while the stream is loading', (
    WidgetTester tester,
  ) async {
    // Stream that emits nothing immediately (stays in "loading" state)
    when(() => mockService.streamOtherUsersItems())
        .thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(buildTestableWidget());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Displays message when there are no items', (
    WidgetTester tester,
  ) async {
    when(() => mockService.streamOtherUsersItems())
        .thenAnswer((_) => Stream.value([]));

    await tester.pumpWidget(buildTestableWidget());
    await tester.pump(); // Waits for the stream to emit

    expect(find.text('No items to explore yet.'), findsOneWidget);
  });

  testWidgets('Displays items when the stream returns data', (
    WidgetTester tester,
  ) async {
    final mockItems = [
      {'name': 'Maçã', 'category': 'Fruits', 'image': null},
    ];

    when(() => mockService.streamOtherUsersItems())
        .thenAnswer((_) => Stream.value(mockItems));

    await tester.pumpWidget(buildTestableWidget());
    await tester.pump();

    expect(find.text('Maçã'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
  });
}
