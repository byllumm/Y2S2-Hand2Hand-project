import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hand2hand/add_item_dialog.dart';

class MockAddItemCallback extends Mock {
  void call(
      String name,
      int quantity,
      DateTime expirationDate,
      String action,
      String tradePoint,
      String details,
      );
}

void main() {
  group('AddItemDialog Tests', () {
    late MockAddItemCallback mockAddItemCallback;

    setUp(() {
      mockAddItemCallback = MockAddItemCallback();
    });

    testWidgets('displays form fields correctly', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AddItemDialog(onAdd: mockAddItemCallback),
        ),
      ));

      expect(find.text('Add Item'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(5)); 
      expect(find.byType(ElevatedButton), findsNWidgets(2));
    });

    testWidgets('validates form input correctly', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AddItemDialog(onAdd: mockAddItemCallback),
        ),
      ));

      await tester.tap(find.text('Add'));
      await tester.pump();

      expect(find.text('Please enter a name'), findsOneWidget);
      expect(find.text('Please enter a quantity'), findsOneWidget);
      expect(find.text('Please enter an action'), findsOneWidget);
      expect(find.text('Please enter a trade point'), findsOneWidget);
    });

    /*testWidgets('submits form when valid input is entered', (WidgetTester tester) async {
      // Setup valid input values
      final name = 'Item 1';
      final quantity = 2;
      final action = 'Give';
      final tradePoint = 'Location A';
      final details = 'A very useful item';
      final expirationDate = DateTime(2025, 12, 31);

      void mockAddItemCallback(
          String name,
          int quantity,
          DateTime expirationDate,
          String action,
          String tradePoint,
          String details) {
        // You can implement any verification or data capture for your test here
      }

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AddItemDialog(onAdd: mockAddItemCallback),
        ),
      ));

      // Fill the form with valid data
      await tester.enterText(find.byType(TextFormField).at(0), name);
      await tester.enterText(find.byType(TextFormField).at(2), quantity.toString());
      await tester.enterText(find.byType(TextFormField).at(3), action);
      await tester.enterText(find.byType(TextFormField).at(4), tradePoint);
      await tester.enterText(find.byType(TextFormField).at(1), details);

      final date = DateTime(2025, 12, 31);
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add'));
      await tester.pump();
      // Expect the onAdd callback to be called with the correct values
      verify(() => mockAddItemCallback(name, quantity, expirationDate, action, tradePoint, details)).called(1);
    });

    testWidgets('picks a date for expiration date', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AddItemDialog(onAdd: mockAddItemCallback),
        ),
      ));

      // Tap the 'Pick Expiration Date' button
      await tester.tap(find.text('Pick Expiration Date'));
      await tester.pumpAndSettle();

      // Pick a valid date from the date picker (mock this if necessary)
      final date = DateTime(2025, 12, 31);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify the date selected (you may need to adjust depending on how you simulate the date picker)
      expect(find.text('Expiration Date: ${date.toLocal()}'), findsOneWidget);
    });*/
  });
}
