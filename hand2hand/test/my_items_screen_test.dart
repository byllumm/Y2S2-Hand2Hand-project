import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hand2hand/screens/my_items_screen.dart';
import 'package:hand2hand/supabase_service.dart';
import 'dart:async';

class MockSupabaseService extends Mock implements SupabaseService {}

void main() {
  group('MyItemsScreen Widgets Tests', () {
    late MockSupabaseService mockService;

    setUp(() {
      mockService = MockSupabaseService();
    });

    testWidgets('displays loading indicator while waiting for data', (WidgetTester tester) async {

      final controller = StreamController<List<Map<String, dynamic>>>();
      when(() => mockService.streamItems()).thenAnswer((_) => controller.stream);

      await tester.pumpWidget(MaterialApp(
        home: MyItemsScreen(service: mockService),
      ));

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error message if snapshot has error', (WidgetTester tester) async {

      final controller = StreamController<List<Map<String, dynamic>>>();
      when(() => mockService.streamItems()).thenAnswer((_) => controller.stream);

      await tester.pumpWidget(MaterialApp(
        home: MyItemsScreen(service: mockService),
      ));

      controller.addError('Test Error');

      await tester.pump();

      expect(find.textContaining('Error:'), findsOneWidget);
    });

    testWidgets('displays "No items available" if no data', (WidgetTester tester) async {

      final controller = StreamController<List<Map<String, dynamic>>>();
      when(() => mockService.streamItems()).thenAnswer((_) => controller.stream);

      await tester.pumpWidget(MaterialApp(
        home: MyItemsScreen(service: mockService),
      ));

      controller.add([]);
      await tester.pump();

      expect(find.text('No items available'), findsOneWidget);
    });

    testWidgets('displays list of items correctly', (WidgetTester tester) async {
      final items = [
        {
          'id': 1,
          'name': 'Bread',
          'quantity': 2,
          'expirationDate': '2025-05-01',
          'action': 0,
          'tradePoint': 'Park',
          'details': 'Fresh Bread',
        }
      ];

      final controller = StreamController<List<Map<String, dynamic>>>();
      when(() => mockService.streamItems()).thenAnswer((_) => controller.stream);

      await tester.pumpWidget(MaterialApp(
        home: MyItemsScreen(service: mockService),
      ));

      controller.add(items);
      await tester.pump();

      expect(find.text('Bread (Qty: 2)'), findsOneWidget);
      expect(find.text('Exp Date: 2025-05-01'), findsOneWidget);
      expect(find.text('Action: 0'), findsOneWidget);
      expect(find.text('Trade Point: Park'), findsOneWidget);
      expect(find.text('Details: Fresh Bread'), findsOneWidget);
    });


  });
}


