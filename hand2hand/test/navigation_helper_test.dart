import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hand2hand/screens/my_items_screen.dart';
import 'package:hand2hand/sign_in_screen.dart';
import 'package:hand2hand/sign_up_screen.dart';
import 'package:hand2hand/navigation_helper.dart';
import 'package:hand2hand/supabase_service.dart';
import 'package:mocktail/mocktail.dart';

class MockSupabaseService extends Mock implements SupabaseService {}

void main() {
  setUpAll(() {
    registerFallbackValue(MockSupabaseService());
  });

  group('Navigation Helpers', () {

    testWidgets('navigateToBrowseItemsScreen navigates to MyItemsScreen', (WidgetTester tester) async {
      final mockService = MockSupabaseService();
      when(() => mockService.streamItems()).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => navigateToBrowseItemsScreen(context, mockService),
            child: const Text('Navigate'),
          ),
        ),
      ));

      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      expect(find.byType(MyItemsScreen), findsOneWidget);
    });

    testWidgets('navigateWithTransition navigates to custom page with transition', (WidgetTester tester) async {
      final testKey = Key('TestPage');

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => navigateWithTransition(context, const TestPage()),
            child: const Text('Navigate'),
          ),
        ),
      ));

      await tester.tap(find.text('Navigate'));
      await tester.pump(); // start animation
      await tester.pump(const Duration(milliseconds: 500)); // simulate animation progress
      await tester.pumpAndSettle(); // finish animations

      expect(find.byKey(testKey), findsOneWidget);
    });
  });
}

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('TestPage'),
      body: const Center(child: Text('Test Page')),
    );
  }
}
