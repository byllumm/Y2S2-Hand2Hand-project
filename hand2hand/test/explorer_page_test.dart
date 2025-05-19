import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/material.dart';
import 'package:hand2hand/supabase_service.dart';
import 'dart:async';
import 'package:hand2hand/screens/explorer_page.dart';

class MockSupabaseService extends Mock implements SupabaseService {}

List<Map<String, dynamic>> filterItems(
  List<Map<String, dynamic>> items,
  String? selectedCategory,
  String searchQuery,
) {
  return items.where((item) {
    final category = item['category'] ?? '';
    final name = (item['name'] ?? '').toString().toLowerCase();
    final matchesCategory =
        selectedCategory == null || selectedCategory == category;
    final matchesSearch =
        searchQuery.isEmpty || name.contains(searchQuery.toLowerCase());
    return matchesCategory && matchesSearch;
  }).toList();
}

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

  group('filterItems', () {
    final mockData = [
      {'name': 'Maçã', 'category': 'Fruits'},
      {'name': 'Cenoura', 'category': 'Vegetables'},
      {'name': 'Leite', 'category': 'Dairy'},
    ];

    test('returns all items when no filters are applied', () {
      final result = filterItems(mockData, null, '');
      expect(result.length, 3);
    });

    test('filters by category', () {
      final result = filterItems(mockData, 'Fruits', '');
      expect(result.length, 1);
      expect(result[0]['name'], 'Maçã');
    });

    test('filters by search query', () {
      final result = filterItems(mockData, null, 'cenoura');
      expect(result.length, 1);
      expect(result[0]['name'], 'Cenoura');
    });

    test('filters by category and search query', () {
      final result = filterItems(mockData, 'Dairy', 'leite');
      expect(result.length, 1);
      expect(result[0]['name'], 'Leite');
    });

    test('returns empty when no match is found', () {
      final result = filterItems(mockData, 'Meat', 'banana');
      expect(result, isEmpty);
    });
  });
}
