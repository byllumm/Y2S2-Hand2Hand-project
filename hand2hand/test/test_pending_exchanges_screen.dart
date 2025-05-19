import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hand2hand/supabase_service.dart';
import 'package:hand2hand/screens/pending_exchanges_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockSupabaseService extends Mock implements SupabaseService {}

void main() {
  late MockSupabaseService mockService;

  setUp(() {
    mockService = MockSupabaseService();
  });

  testWidgets('shows loading indicator initially', (tester) async {
    when(() => mockService.streamPendingExchanges()).thenAnswer(
      (_) => Stream<List<Map<String, dynamic>>>.empty(),
    );

    await tester.pumpWidget(MaterialApp(
      home: PendingExchangesScreen(),
    ));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows empty state when no exchanges', (tester) async {
    when(() => mockService.streamPendingExchanges()).thenAnswer(
      (_) => Stream.value([]),
    );

    await tester.pumpWidget(MaterialApp(
      home: PendingExchangesScreen(),
    ));

    await tester.pumpAndSettle();

    expect(find.text('No pending exchanges.'), findsOneWidget);
  });

  testWidgets('displays pending exchange data', (tester) async {
    final exchangeData = [
      {
        'id': 1,
        'requester_id': 123,
        'donor_confirmed': false,
        'requester_confirmed': false,
        'owner': {'name': 'Bob'},
        'item': {'name': 'T-Shirt'},
        'requester': {'name': 'Alice'}
      }
    ];

    when(() => mockService.currentUserId).thenReturn(123);
    when(() => mockService.streamPendingExchanges()).thenAnswer(
      (_) => Stream.value(exchangeData),
    );

    await tester.pumpWidget(MaterialApp(
      home: PendingExchangesScreen(),
    ));

    await tester.pumpAndSettle();

    expect(find.textContaining('T-Shirt - You requested from Bob'), findsOneWidget);
    expect(find.textContaining('Your confirmation: ❌'), findsOneWidget);
    expect(find.textContaining('Other: ❌'), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);
  });

  testWidgets('confirms exchange after dialog', (tester) async {
    final exchangeData = [
      {
        'id': 2,
        'requester_id': 123,
        'donor_confirmed': false,
        'requester_confirmed': false,
        'owner': {'name': 'Charlie'},
        'item': {'name': 'Book'},
        'requester': {'name': 'Alice'}
      }
    ];

    when(() => mockService.currentUserId).thenReturn(123);
    when(() => mockService.streamPendingExchanges()).thenAnswer(
      (_) => Stream.value(exchangeData),
    );
    when(() => mockService.confirmExchange(2)).thenAnswer((_) async {});

    await tester.pumpWidget(MaterialApp(
      home: PendingExchangesScreen(),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Confirm'), findsOneWidget);
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(find.text('Confirm Exchange'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Confirm'));
    await tester.pump();

    verify(() => mockService.confirmExchange(2)).called(1);
    await tester.pumpAndSettle();

    expect(find.text('Exchange confirmed!'), findsOneWidget);
  });

  testWidgets('handles exchange confirmation failure', (tester) async {
    final exchangeData = [
      {
        'id': 3,
        'requester_id': 123,
        'donor_confirmed': false,
        'requester_confirmed': false,
        'owner': {'name': 'David'},
        'item': {'name': 'Shoes'},
        'requester': {'name': 'Alice'}
      }
    ];

    when(() => mockService.currentUserId).thenReturn(123);
    when(() => mockService.streamPendingExchanges()).thenAnswer(
      (_) => Stream.value(exchangeData),
    );
    when(() => mockService.confirmExchange(3))
        .thenThrow(Exception('Network error'));

    await tester.pumpWidget(MaterialApp(
      home: PendingExchangesScreen(),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Confirm'), findsOneWidget);
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(find.text('Confirm Exchange'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Confirm'));
    await tester.pump();

    verify(() => mockService.confirmExchange(3)).called(1);
    await tester.pumpAndSettle();

    expect(find.textContaining('Error: Exception: Network error'), findsOneWidget);
  });
}
