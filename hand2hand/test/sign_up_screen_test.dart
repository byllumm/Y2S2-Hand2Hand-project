import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hand2hand/sign_up_screen.dart';
import 'package:hand2hand/supabase_service.dart';

/// Create a mock of SupabaseService
class MockSupabaseService extends Mock implements SupabaseService {}

void main() {
  group('SignUpScreen Widget Tests', () {
    late MockSupabaseService mockSupabaseService;

    setUp(() {
      mockSupabaseService = MockSupabaseService();
    });

    testWidgets('displays all input fields', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SignUpScreen(supabaseService: mockSupabaseService),
      ));

      // Verify that all TextField widgets are present
      expect(find.byType(TextField), findsNWidgets(5));
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Location'), findsOneWidget);
    });

    testWidgets('shows error snackbar when fields are empty',
            (WidgetTester tester) async {
          await tester.pumpWidget(MaterialApp(
            home: SignUpScreen(supabaseService: mockSupabaseService),
          ));

          // Tap the Sign Up button without entering any text.
          await tester.tap(find.byKey(Key('signUpButton')));
          await tester.pumpAndSettle();

          // Expect a snackbar indicating that all fields are required.
          expect(find.text('Please fill in all fields'), findsOneWidget);
        });

    testWidgets(
        'calls signUp and shows success snackbar when valid data is entered',
            (WidgetTester tester) async {
          // Arrange: make signUp complete successfully.
          when(() => mockSupabaseService.signUp(
            any(), any(), any(), any(), any(),
          )).thenAnswer((_) async {});

          await tester.pumpWidget(MaterialApp(
            home: SignUpScreen(supabaseService: mockSupabaseService),
          ));

          // Enter valid text into each TextField.
          await tester.enterText(
            find.byWidgetPredicate((widget) =>
            widget is TextField &&
                widget.decoration?.labelText == 'Name'),
            'Test Name',
          );
          await tester.enterText(
            find.byWidgetPredicate((widget) =>
            widget is TextField &&
                widget.decoration?.labelText == 'Username'),
            'testuser',
          );
          await tester.enterText(
            find.byWidgetPredicate((widget) =>
            widget is TextField &&
                widget.decoration?.labelText == 'Email'),
            'test@example.com',
          );
          await tester.enterText(
            find.byWidgetPredicate((widget) =>
            widget is TextField &&
                widget.decoration?.labelText == 'Password'),
            'password',
          );
          await tester.enterText(
            find.byWidgetPredicate((widget) =>
            widget is TextField &&
                widget.decoration?.labelText == 'Location'),
            'Test Location',
          );

          // Act: tap the Sign Up button.
          await tester.tap(find.byKey(Key('signUpButton')));
          await tester.pumpAndSettle();

          // Assert: Verify that signUp was called with the correct arguments.
          verify(() => mockSupabaseService.signUp(
            'Test Name',
            'testuser',
            'test@example.com',
            'password',
            'Test Location',
          )).called(1);

          // Also check for the success SnackBar message.
          expect(find.text('Sign up successful!'), findsOneWidget);
        });

    testWidgets(
        'shows error snackbar when signUp throws an exception',
            (WidgetTester tester) async {
          // Arrange: make signUp throw an exception.
          when(() => mockSupabaseService.signUp(
            any(), any(), any(), any(), any(),
          )).thenThrow(Exception('Failed sign up'));

          await tester.pumpWidget(MaterialApp(
            home: SignUpScreen(supabaseService: mockSupabaseService),
          ));

          // Enter valid text into each TextField.
          await tester.enterText(
            find.byWidgetPredicate((widget) =>
            widget is TextField &&
                widget.decoration?.labelText == 'Name'),
            'Test Name',
          );
          await tester.enterText(
            find.byWidgetPredicate((widget) =>
            widget is TextField &&
                widget.decoration?.labelText == 'Username'),
            'testuser',
          );
          await tester.enterText(
            find.byWidgetPredicate((widget) =>
            widget is TextField &&
                widget.decoration?.labelText == 'Email'),
            'test@example.com',
          );
          await tester.enterText(
            find.byWidgetPredicate((widget) =>
            widget is TextField &&
                widget.decoration?.labelText == 'Password'),
            'password',
          );
          await tester.enterText(
            find.byWidgetPredicate((widget) =>
            widget is TextField &&
                widget.decoration?.labelText == 'Location'),
            'Test Location',
          );

          // Act: tap the Sign Up button.
          await tester.tap(find.byKey(Key('signUpButton')));
          await tester.pumpAndSettle();

          // Assert: The error SnackBar should be displayed.
          expect(find.textContaining('Error:'), findsOneWidget);
        });
  });
}

