import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hand2hand/screens/profileEditor_page.dart';
import 'package:hand2hand/supabase_service.dart';
import 'package:mocktail/mocktail.dart';
import 'dart:async';

class MockSupabaseService extends Mock implements SupabaseService {}

void main() {
  late MockSupabaseService mockService;

  setUp(() {
    mockService = MockSupabaseService();

    when(() => mockService.getCurrentUserData()).thenAnswer((_) async => {
      'name': 'Jane Doe',
      'username': 'janedoe',
      'email': 'jane@example.com',
      'location': 'Porto',
    });

    when(() => mockService.currentUserId).thenReturn(123);

    when(() => mockService.updateUserProfile(
      userId: any(named: 'userId'),
      name: any(named: 'name'),
      username: any(named: 'username'),
      email: any(named: 'email'),
      location: any(named: 'location'),
    )).thenAnswer((_) async => {});
  });

  testWidgets('shows loading initially', (tester) async {
    final completer = Completer<Map<String, dynamic>>();
    when(() => mockService.getCurrentUserData()).thenAnswer((_) => completer.future);

    await tester.pumpWidget(MaterialApp(
      home: EditProfileScreen(service: mockService),
    ));

    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete({
      'name': 'Jane Doe',
      'username': 'janedoe',
      'email': 'jane@example.com',
      'location': 'Porto',
    });

    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Jane Doe'), findsOneWidget);
  });

  testWidgets('shows validation errors if required fields are empty', (tester) async {
    await tester.pumpWidget(MaterialApp(home: EditProfileScreen(service: mockService)));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), '');
    await tester.enterText(find.byType(TextFormField).at(1), '');
    await tester.enterText(find.byType(TextFormField).at(2), '');

    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(find.text('Enter a name'), findsOneWidget);
    expect(find.text('Enter a username'), findsOneWidget);
    expect(find.text('Enter an email'), findsOneWidget);
  });

  testWidgets('saves profile and shows success message', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => ScaffoldMessenger(child: child!),
        home: EditProfileScreen(service: mockService, popOnSave: false),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Jane Updated');
    await tester.enterText(find.byType(TextFormField).at(1), 'janeupdated');
    await tester.enterText(find.byType(TextFormField).at(2), 'janeupdated@example.com');
    await tester.enterText(find.byType(TextFormField).at(3), 'Lisboa');

    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));


    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Profile updated successfully'), findsOneWidget);
  });

  testWidgets('loads user data into form fields', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: EditProfileScreen(service: mockService),
    ));

    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextFormField, 'Jane Doe'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'janedoe'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'jane@example.com'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Porto'), findsOneWidget);
  });

  testWidgets('shows error message when profile update fails', (tester) async {
    when(() => mockService.updateUserProfile(
      userId: any(named: 'userId'),
      name: any(named: 'name'),
      username: any(named: 'username'),
      email: any(named: 'email'),
      location: any(named: 'location'),
    )).thenThrow(Exception('Update failed'));

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => ScaffoldMessenger(child: child!),
        home: EditProfileScreen(service: mockService, popOnSave: false),
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Jane Error');
    await tester.enterText(find.byType(TextFormField).at(1), 'janeerror');
    await tester.enterText(find.byType(TextFormField).at(2), 'janeerror@example.com');
    await tester.enterText(find.byType(TextFormField).at(3), 'Faro');

    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Error updating profile'), findsOneWidget);
  });

  testWidgets('disables save button and shows loader while saving', (tester) async {
    final completer = Completer<void>();
    when(() => mockService.updateUserProfile(
      userId: any(named: 'userId'),
      name: any(named: 'name'),
      username: any(named: 'username'),
      email: any(named: 'email'),
      location: any(named: 'location'),
    )).thenAnswer((_) => completer.future);

    await tester.pumpWidget(MaterialApp(
      home: EditProfileScreen(service: mockService, popOnSave: false),
    ));

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Jane');
    await tester.enterText(find.byType(TextFormField).at(1), 'janeuser');
    await tester.enterText(find.byType(TextFormField).at(2), 'jane@email.com');
    await tester.enterText(find.byType(TextFormField).at(3), 'Coimbra');

    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed, isNull);

    completer.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('allows saving profile without location', (tester) async {
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => ScaffoldMessenger(child: child!),
      home: EditProfileScreen(service: mockService, popOnSave: false),
    ));

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Name');
    await tester.enterText(find.byType(TextFormField).at(1), 'username');
    await tester.enterText(find.byType(TextFormField).at(2), 'email@example.com');
    await tester.enterText(find.byType(TextFormField).at(3), ''); // empty location

    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Profile updated successfully'), findsOneWidget);
  });

}
