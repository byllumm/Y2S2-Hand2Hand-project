import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hand2hand/screens/my_items_screen.dart';
import 'package:hand2hand/supabase_service.dart';
import 'package:hand2hand/screens/add_item_page.dart';
import 'dart:async';
import 'package:hand2hand/screens/chatscreen_page.dart';
import 'package:hand2hand/message.dart';


class MockSupabaseService extends Mock implements SupabaseService {}
class FakeMessage extends Fake implements Message {}

void main() {
  group('ChatScreen Widgets Tests', ()
  {
    late MockSupabaseService mockService;

    setUp(() {
      registerFallbackValue(FakeMessage());
      mockService = MockSupabaseService();
      when(() => mockService.getMessages(any(), any()))
          .thenAnswer((_) async => []);
      when(() => mockService.getUserById(any()))
          .thenAnswer((_) async => {'username': 'test'});
      when(() =>
          mockService.subscribeToMessages(
            itemId: any(named: 'itemId'),
            onNewMessage: any(named: 'onNewMessage'),
          )).thenReturn(null);
      when(() => mockService.currentUserId).thenReturn(1);
    });

    testWidgets('Displays messages fetched from service', (tester) async {
      final message = Message(
        senderId: 1,
        receiverId: 2,
        itemId: 1,
        content: 'Hello!',
        createdAt: DateTime.now(),
      );

      when(() => mockService.getMessages(any(), any()))
          .thenAnswer((_) async => [message]);
      when(() => mockService.getUserById(any()))
          .thenAnswer((_) async => {'username': 'test'});
      when(() =>
          mockService.subscribeToMessages(
            itemId: any(named: 'itemId'),
            onNewMessage: any(named: 'onNewMessage'),
          )).thenReturn(null);
      when(() => mockService.currentUserId).thenReturn(1);

      await tester.pumpWidget(MaterialApp(
        home: ChatScreen(
          itemId: 1,
          receiverId: 2,
          supabaseService: mockService,
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Hello!'), findsOneWidget);
    });

    testWidgets('Sends message on tap', (tester) async {
      when(() => mockService.getMessages(any(), any()))
          .thenAnswer((_) async => []);
      when(() => mockService.getUserById(any()))
          .thenAnswer((_) async => {'username': 'test'});
      when(() => mockService.sendMessage(any())).thenAnswer((_) async {});
      when(() => mockService.subscribeToMessages(
        itemId: any(named: 'itemId'),
        onNewMessage: any(named: 'onNewMessage'),
      )).thenReturn(null);
      when(() => mockService.currentUserId).thenReturn(1);

      await tester.pumpWidget(MaterialApp(
        home: ChatScreen(
          itemId: 1,
          receiverId: 2,
          supabaseService: mockService,
        ),
      ));

      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Hi there');
      await tester.pump();

      await tester.tap(find.widgetWithIcon(GestureDetector, Icons.send));
      await tester.pump();

      verify(() => mockService.sendMessage(any())).called(1);
      expect(find.text('Hi there'), findsOneWidget); // now added to the list
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Does not send empty message', (tester) async {
      when(() => mockService.getMessages(any(), any()))
          .thenAnswer((_) async => []);
      when(() => mockService.getUserById(any()))
          .thenAnswer((_) async => {'username': 'test'});
      when(() => mockService.sendMessage(any())).thenAnswer((_) async {});
      when(() => mockService.subscribeToMessages(
        itemId: any(named: 'itemId'),
        onNewMessage: any(named: 'onNewMessage'),
      )).thenReturn(null);
      when(() => mockService.currentUserId).thenReturn(1);

      await tester.pumpWidget(MaterialApp(
        home: ChatScreen(
          itemId: 1,
          receiverId: 2,
          supabaseService: mockService,
        ),
      ));

      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      await tester.tap(find.widgetWithIcon(GestureDetector, Icons.send));
      await tester.pump();

      verifyNever(() => mockService.sendMessage(any()));
    });

    testWidgets('Has input field and send button', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ChatScreen(
          itemId: 1,
          receiverId: 2,
          supabaseService: mockService,
        ),
      ));

      expect(find.byType(TextField), findsOneWidget);
      expect(find.widgetWithIcon(GestureDetector, Icons.send), findsOneWidget);
    });

    /*testWidgets('Clears input field after sending message', (tester) async {
      when(() => mockService.sendMessage(any())).thenAnswer((_) async {});

      await tester.pumpWidget(MaterialApp(
        home: ChatScreen(
          itemId: 1,
          receiverId: 2,
          supabaseService: mockService,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Test clear');
      await tester.tap(find.widgetWithIcon(GestureDetector, Icons.send));
      await tester.pumpAndSettle();


      expect(find.text('Test clear'), findsNothing);
    });

     */


  });
}