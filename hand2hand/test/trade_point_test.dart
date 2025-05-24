import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hand2hand/screens/trade_point.dart';
import 'package:flutter_map/flutter_map.dart';

void main() {
  group('TradePoint Widget Tests', () {
    const double latitude = 41.14961;
    const double longitude = -8.61099;

    testWidgets('displays title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TradePoint(
            latitude: latitude,
            longitude: longitude,
            imageUrl: null, // <-- No image, avoids network call
          ),
        ),
      );

      expect(find.text('Trade Point Map'), findsOneWidget);
    });

    testWidgets('shows map widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TradePoint(
            latitude: latitude,
            longitude: longitude,
            imageUrl: null, // <-- No image, avoids network call
          ),
        ),
      );

      expect(find.byType(FlutterMap), findsOneWidget);
    });

    testWidgets('back button test', (WidgetTester tester) async {
      final navKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navKey,
          home: TradePoint(
            latitude: latitude,
            longitude: longitude,
            imageUrl: null, // <-- No image, avoids network call
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byType(TradePoint), findsNothing);
    });
  });
}
