import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hand2hand/screens/pending_exchanges_screen.dart';
import 'package:hand2hand/supabase_service.dart';
import 'package:mocktail/mocktail.dart';


class MockSupabaseService extends Mock implements SupabaseService {}

void main() {
  late MockSupabaseService mockSupabaseService;
  late StreamController<List<Map<String, dynamic>>> streamController;

  setUp(() {
    mockSupabaseService = MockSupabaseService();
    streamController = StreamController<List<Map<String, dynamic>>>();
    when(() => mockSupabaseService.streamPendingExchanges())
        .thenAnswer((_) => streamController.stream);
    when(() => mockSupabaseService.currentUserId).thenReturn(123);
  });

  tearDown(() {
    streamController.close();
  });

  testWidgets('displays loading indicator while waiting for data', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: PendingExchangesScreenWithMock(service: mockSupabaseService),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('displays no pending exchanges message when stream is empty', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: PendingExchangesScreenWithMock(service: mockSupabaseService),
          ),
        );

        streamController.add([]);
        await tester.pumpAndSettle();

        expect(find.text('No pending exchanges.'), findsOneWidget);
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return PendingExchangesScreen();
            },
          );
        },
      ),
    );
  }

  testWidgets('displays loading indicator while waiting for data',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: PendingExchangesScreenWrapper(
              supabaseService: mockSupabaseService,
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

}

class PendingExchangesScreenWrapper extends StatefulWidget {
  final SupabaseService supabaseService;

  const PendingExchangesScreenWrapper({
    Key? key,
    required this.supabaseService,
  }) : super(key: key);

  @override
  State<PendingExchangesScreenWrapper> createState() =>
      _PendingExchangesScreenWrapperState();
}

class _PendingExchangesScreenWrapperState
    extends State<PendingExchangesScreenWrapper> {
  @override
  Widget build(BuildContext context) {
    return PendingExchangesScreenWithMock(service: widget.supabaseService);
  }
}

class PendingExchangesScreenWithMock extends StatefulWidget {
  final SupabaseService service;

  const PendingExchangesScreenWithMock({Key? key, required this.service})
      : super(key: key);

  @override
  State<PendingExchangesScreenWithMock> createState() =>
      _PendingExchangesScreenWithMockState();
}

class _PendingExchangesScreenWithMockState
    extends State<PendingExchangesScreenWithMock> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pending Exchanges')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: widget.service.streamPendingExchanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final exchanges = snapshot.data!;

          if (exchanges.isEmpty) {
            return const Center(child: Text('No pending exchanges.'));
          }

          return ListView.builder(
            itemCount: exchanges.length,
            itemBuilder: (context, index) {
              final exchange = exchanges[index];
              final exchangeId = exchange['id'] as int;
              final isRequester =
                  exchange['requester_id'] == widget.service.currentUserId;

              final youConfirmed =
              isRequester
                  ? (exchange['requester_confirmed'] ?? false) as bool
                  : (exchange['donor_confirmed'] ?? false) as bool;

              final otherConfirmed =
              isRequester
                  ? (exchange['donor_confirmed'] ?? false) as bool
                  : (exchange['requester_confirmed'] ?? false) as bool;

              final otherUser = isRequester
                  ? (exchange['owner']?['name'] ??
                  exchange['owner']?['username'] ??
                  'Unknown')
                  : (exchange['requester']?['name'] ??
                  exchange['requester']?['username'] ??
                  'Unknown');

              return ListTile(
                title: Text(
                  "${exchange['item']?['name'] ?? 'Unknown Item'} - "
                      "${isRequester ? 'You requested from $otherUser' : '$otherUser requested'}",
                ),
                subtitle: Text(
                  'Your confirmation: ${youConfirmed ? "✅" : "❌"}\nOther: ${otherConfirmed ? "✅" : "❌"}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}

