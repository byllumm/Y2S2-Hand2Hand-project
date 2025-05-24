import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hand2hand/screens/profile_screen.dart';
import 'package:hand2hand/screens/profileEditor_page.dart';
import 'package:hand2hand/screens/my_items_screen.dart';
import 'package:hand2hand/screens/pending_exchanges_screen.dart';
import 'package:hand2hand/supabase_service.dart';
import 'package:mocktail/mocktail.dart';
import 'dart:async';

class MockSupabaseService extends Mock implements SupabaseService {}

void main() {
  late MockSupabaseService mockService;

  setUp(() {
    mockService = MockSupabaseService();
  });

  Future<void> pumpProfileScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ProfileScreen(supabaseService: mockService), // Inject it here!
      ),
    );
  }

  testWidgets('displays loading indicator while fetching', (tester) async {
    final completer = Completer<Map<String, dynamic>?>();

    when(() => mockService.getCurrentUserData()).thenAnswer((_) => completer.future);

    await pumpProfileScreen(tester);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete({'username': 'testuser'});
    await tester.pumpAndSettle();

    expect(find.text('testuser'), findsOneWidget);
  });

  testWidgets('shows error message if user data is null', (tester) async {
    when(() => mockService.getCurrentUserData()).thenAnswer((_) async => null);

    await pumpProfileScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('Failed to load user data'), findsOneWidget);
  });

  testWidgets('shows correct initial in CircleAvatar', (tester) async {
    when(() => mockService.getCurrentUserData()).thenAnswer((_) async => {'username': 'charlie'});

    await pumpProfileScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('C'), findsOneWidget); // Initial from 'charlie'
  });

  testWidgets('shows default initial when username is empty', (tester) async {
    when(() => mockService.getCurrentUserData()).thenAnswer((_) async => {'username': ''});

    await pumpProfileScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('U'), findsOneWidget); // Default fallback
  });

}
