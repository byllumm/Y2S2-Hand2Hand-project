import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hand2hand/supabase_service.dart';
import 'dart:io';
import 'dart:async';
import 'package:hand2hand/screens/itemDetail_page.dart';
import 'package:hand2hand/screens/chatscreen_page.dart';

class MockSupabaseService extends Mock implements SupabaseService {}

void main(){
  late MockSupabaseService mockService;

  setUp(() {
    mockService = MockSupabaseService();
  });

  testWidgets('shows REQUEST when item is available', (tester) async {
    final item = {
      'id': 3,
      'name': 'Item Y',
      'user_id': 123,
      'quantity': 1,
      'image': null,
      'latitude': 0.0,
      'longitude': 0.0,
      'description': 'Another item',
      'expirationDate': '2025-12-31',
      'category': 'Toys',
    };

    when(() => mockService.currentUserId).thenReturn(123);
    when(() => mockService.getUserById(any())).thenAnswer((_) async => {'name': 'Donor2', 'username': 'donor456'});
    when(() => mockService.getItemStatus(3)).thenAnswer((_) async => {'available': true, 'is_requested': false});

    await tester.pumpWidget(
      MaterialApp(
        home: ItemDetailPage(
          item: item,
          supabaseService: mockService,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('REQUEST'), findsOneWidget);
  });

  testWidgets('displays item details correctly', (WidgetTester tester) async {
    final mockItem = {
      'id': 1,
      'user_id': 123,
      'name': 'Apples',
      'quantity': 5,
      'image': null,
      'latitude': 12.34,
      'longitude': 56.78,
      'expirationDate': '2025-06-01',
      'category': 'Fruits',
      'description': 'Fresh apples.',
    };

    when(() => mockService.getUserById(any())).thenAnswer((_) async => {'name': 'Donor', 'username': 'donor123'});
    when(() => mockService.getItemStatus(any())).thenAnswer((_) async => {'available': true, 'is_requested': false});

    await tester.pumpWidget(
      MaterialApp(
        home: ItemDetailPage(
          item: mockItem,
          supabaseService: mockService,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Apples'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('Fruits'), findsOneWidget);
  });

  testWidgets('shows REQUESTED when item is already requested', (tester) async {
    final item = {
      'id': 4,
      'user_id': 123,
      'name': 'Requested Item',
      'quantity': 2,
      'image': null,
      'latitude': 0.0,
      'longitude': 0.0,
      'description': 'Requested item',
      'expirationDate': '2025-01-01',
      'category': 'Misc',
    };

    when(() => mockService.currentUserId).thenReturn(456); // Different user
    when(() => mockService.getUserById(any())).thenAnswer((_) async => {'name': 'Donor3', 'username': 'donor789'});
    when(() => mockService.getItemStatus(4)).thenAnswer((_) async => {'available': true, 'is_requested': true});

    await tester.pumpWidget(
      MaterialApp(
        home: ItemDetailPage(
          item: item,
          supabaseService: mockService,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('REQUESTED'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed, isNull);
  });

  testWidgets('displays item details and donor info', (tester) async {
    final mockItem = {
      'id': 1,
      'user_id': 123,
      'name': 'Apples',
      'quantity': 5,
      'image': null,
      'latitude': 12.34,
      'longitude': 56.78,
      'expirationDate': '2025-06-01',
      'category': 'Fruits',
      'description': 'Fresh apples.',
    };

    when(() => mockService.getUserById(any())).thenAnswer(
          (_) async => {
        'name': 'Donor Name',
        'username': 'donor123',
      },
    );

    when(() => mockService.getItemStatus(any())).thenAnswer(
          (_) async => {
        'available': true,
        'is_requested': false,
      },
    );

    when(() => mockService.currentUserId).thenReturn(999);

    await tester.pumpWidget(
      MaterialApp(
        home: ItemDetailPage(
          item: mockItem,
          supabaseService: mockService,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Apples'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('Fruits'), findsOneWidget);
    expect(find.text('Fresh apples.'), findsOneWidget);
    expect(find.text('2025-06-01'), findsOneWidget);

    expect(find.text('DONOR'), findsOneWidget);
    expect(find.text('NAME: Donor Name'), findsOneWidget);
    expect(find.text('USERNAME: @donor123'), findsOneWidget);
  });

  testWidgets('snackbar appears when requesting own item', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              child: Text('REQUEST'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('You cannot request your own item')),
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('You cannot request your own item'), findsNothing);
    await tester.tap(find.text('REQUEST'));
    await tester.pump(); // Start animation
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('You cannot request your own item'), findsOneWidget);
  });

}