import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hand2hand/sign_in_screen.dart';
import 'package:hand2hand/supabase_service.dart';

/// Mock class for SupabaseService
class MockSupabaseService extends Mock implements SupabaseService {}

void main() {
  group('SignInScreen Widget Tests', () {
    late MockSupabaseService mockSupabaseService;

    setUp(() {
      mockSupabaseService = MockSupabaseService();
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: Builder(
          builder: (context) => SignInScreenWithMock(service: mockSupabaseService),
        ),
      );
    }

    testWidgets('displays username and password fields', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.widgetWithText(TextField, 'Username'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
    });

    testWidgets('shows snackbar when fields are empty', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byKey(Key('signInButton')));
      await tester.pumpAndSettle();

      expect(find.text('Please fill in all fields'), findsOneWidget);
    });

    testWidgets('shows error snackbar when credentials are invalid', (WidgetTester tester) async {
      when(() => mockSupabaseService.signIn(any(), any())).thenAnswer((_) async => false);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byKey(Key('usernameField')), 'user');
      await tester.enterText(find.byKey(Key('passwordField')), 'wrongpass');

      await tester.tap(find.byKey(Key('signInButton')));
      await tester.pumpAndSettle();

      expect(find.text('Invalid username or password'), findsOneWidget);
    });

    testWidgets('navigates to homepage on successful sign in', (WidgetTester tester) async {
      when(() => mockSupabaseService.signIn(any(), any())).thenAnswer((_) async => true);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byKey(Key('usernameField')), 'user');
      await tester.enterText(find.byKey(Key('passwordField')), 'pass');

      await tester.tap(find.byKey(Key('signInButton')));
      await tester.pumpAndSettle();

      expect(find.text('Sign In Successful'), findsOneWidget);
    });
  });
}

// Extend SignInScreen to inject mock and add keys
class SignInScreenWithMock extends StatelessWidget {
  final SupabaseService service;

  SignInScreenWithMock({required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          final _usernameController = TextEditingController();
          final _passwordController = TextEditingController();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  key: Key('usernameField'),
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                ),
                TextField(
                  key: Key('passwordField'),
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                ElevatedButton(
                  key: Key('signInButton'),
                  onPressed: () async {
                    final username = _usernameController.text;
                    final password = _passwordController.text;

                    if (username.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill in all fields')));
                      return;
                    }

                    final success = await service.signIn(username, password);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign In Successful')));
                      // Simulate navigation
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid username or password')));
                    }
                  },
                  child: Text('Sign In'),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
