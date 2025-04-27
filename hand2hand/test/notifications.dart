import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hand2hand/screens/notifications_page.dart';
import 'package:hand2hand/supabase_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class MockSupabaseService extends Mock implements SupabaseService {}

void main() {
  late MockSupabaseService mockService;

  setUp(() {
    mockService = MockSupabaseService();
  });

  group('NotificationsPage Tests', () {
    testWidgets('display loading indicator while waiting for data', (
      WidgetTester tester,
    ) async {
      final controller = StreamController<List<Map<String, dynamic>>>();
      when(
        () => mockService.streamIncomingRequests(),
      ).thenAnswer((_) => controller.stream);

      await tester.pumpWidget(
        MaterialApp(
          home: NotificationsPage(
            onTabChange: (_) {},
            supabaseService: mockService, 
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('display error message when stream emits error', (
      WidgetTester tester,
    ) async {
      final controller = StreamController<List<Map<String, dynamic>>>();
      when(
        () => mockService.streamIncomingRequests(),
      ).thenAnswer((_) => controller.stream);

      await tester.pumpWidget(
        MaterialApp(
          home: NotificationsPage(
            onTabChange: (_) {},
            supabaseService: mockService,
          ),
        ),
      );

      controller.addError('Test Error');

      await tester.pump();

      expect(find.textContaining('Error:'), findsOneWidget);
    });

    testWidgets('displays "No new requests." when no requests are available', (
      WidgetTester tester,
    ) async {
      final controller = StreamController<List<Map<String, dynamic>>>();
      when(
        () => mockService.streamIncomingRequests(),
      ).thenAnswer((_) => controller.stream);

      await tester.pumpWidget(
        MaterialApp(
          home: NotificationsPage(
            onTabChange: (_) {},
            supabaseService: mockService,
          ),
        ),
      );

      controller.add([]);

      await tester.pump();

      expect(find.text('No new requests.'), findsOneWidget);
    });

    testWidgets('displays notification data correctly', (
      WidgetTester tester,
    ) async {
      final notification = [
        {
          'requester_name': 'Marta',
          'item_name': 'Eggs',
          'created_at': DateTime.now().toIso8601String(),
        },
      ];

      final controller = StreamController<List<Map<String, dynamic>>>();
      when(
        () => mockService.streamIncomingRequests(),
      ).thenAnswer((_) => controller.stream);

      await tester.pumpWidget(
        MaterialApp(
          home: NotificationsPage(
            onTabChange: (_) {},
            supabaseService: mockService,
          ),
        ),
      );

      controller.add(notification);

      await tester.pump();

      expect(find.text('Marta requested your item "Eggs"'), findsOneWidget);
    });

    testWidgets('displays time ago format correctly', (
      WidgetTester tester,
    ) async {
      final notification = [
        {
          'requester_name': 'Marta',
          'item_name': 'Eggs',
          'created_at':
              DateTime.now().subtract(Duration(minutes: 5)).toIso8601String(),
        },
      ];

      final controller = StreamController<List<Map<String, dynamic>>>();
      when(
        () => mockService.streamIncomingRequests(),
      ).thenAnswer((_) => controller.stream);

      await tester.pumpWidget(
        MaterialApp(
          home: NotificationsPage(
            onTabChange: (_) {},
            supabaseService: mockService,
          ),
        ),
      );

      controller.add(notification);

      await tester.pump();

      final timeAgoText = timeago.format(
        DateTime.now().subtract(Duration(minutes: 5)),
      );

      expect(find.textContaining(timeAgoText), findsOneWidget);
    });
  });
}
