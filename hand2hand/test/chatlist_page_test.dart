import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/material.dart';
import 'package:hand2hand/screens/chatlist_page.dart';
import 'package:hand2hand/supabase_service.dart';
import 'package:hand2hand/chatpreview.dart';
import 'dart:async';

class MockSupabaseService extends Mock implements SupabaseService {}

void main() {
  late MockSupabaseService mockService;

  setUp(() {
    mockService = MockSupabaseService();
  });

  testWidgets('displays chat data after loading', (tester) async {
    final now = DateTime.now().toUtc();
    final fakeChat = ChatPreview(
      itemId: 10,
      itemName: 'Apples',
      otherUserId: 42,
      otherUsername: 'Alice',
      itemImage: null,
      lastMessage: 'Hello!',
      lastMessageTime: DateTime(now.year, now.month, now.day, 14, 30),
    );

    when(() => mockService.currentUserId).thenReturn(123);
    when(() => mockService.getUserChats(123)).thenAnswer((_) async => [fakeChat]);

    await tester.pumpWidget(MaterialApp(home: ChatListPage(service: mockService)));

    await tester.pumpAndSettle();

    expect(find.text('Apples'), findsOneWidget);
    expect(find.text('@Alice'), findsOneWidget);
    expect(find.text('Hello!'), findsOneWidget);
    expect(find.text('14:30'), findsOneWidget);
  });

  testWidgets('shows loading indicator initially', (tester) async {
    when(() => mockService.currentUserId).thenReturn(123);
    when(() => mockService.getUserChats(123)).thenAnswer((_) => Future.delayed(Duration(seconds: 1), () => []));

    await tester.pumpWidget(MaterialApp(home: ChatListPage(service: mockService)));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets('handles error gracefully when chat loading fails', (tester) async {
    when(() => mockService.currentUserId).thenReturn(123);
    when(() => mockService.getUserChats(123)).thenThrow(Exception('Failed to load'));

    await tester.pumpWidget(MaterialApp(home: ChatListPage(service: mockService)));

    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('shows empty state when no chats are returned', (tester) async {
    when(() => mockService.currentUserId).thenReturn(123);
    when(() => mockService.getUserChats(123)).thenAnswer((_) async => []);

    await tester.pumpWidget(MaterialApp(home: ChatListPage(service: mockService)));

    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('displays time with leading zero in minutes', (tester) async {
    final now = DateTime.now().toUtc();
    final fakeChat = ChatPreview(
      itemId: 10,
      itemName: 'Apples',
      otherUserId: 42,
      otherUsername: 'Alice',
      itemImage: null,
      lastMessage: 'Hello!',
      lastMessageTime: DateTime(now.year, now.month, now.day, 14, 5),
    );

    when(() => mockService.currentUserId).thenReturn(123);
    when(() => mockService.getUserChats(123)).thenAnswer((_) async => [fakeChat]);

    await tester.pumpWidget(MaterialApp(home: ChatListPage(service: mockService)));

    await tester.pumpAndSettle();

    expect(find.text('14:05'), findsOneWidget);
  });

  testWidgets('handles null currentUserId gracefully', (tester) async {
    when(() => mockService.currentUserId).thenReturn(null);

    await tester.pumpWidget(MaterialApp(home: ChatListPage(service: mockService)));

    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('displays multiple chat previews correctly', (tester) async {
    final List<ChatPreview> chats = [
      ChatPreview(
        itemId: 1,
        itemName: 'Apples',
        otherUserId: 101,
        otherUsername: 'Alice',
        itemImage: null, // or provide a fake URL if needed
        lastMessage: 'Hi',
        lastMessageTime: DateTime(2025, 5, 15, 9, 0),
      ),
      ChatPreview(
        itemId: 2,
        itemName: 'Oranges',
        otherUserId: 102,
        otherUsername: 'Bob',
        itemImage: null,
        lastMessage: 'Yo',
        lastMessageTime: DateTime(2025, 5, 15, 10, 0),
      ),
    ];

    when(() => mockService.currentUserId).thenReturn(123);
    when(() => mockService.getUserChats(123)).thenAnswer((_) async => chats);

    await tester.pumpWidget(MaterialApp(home: ChatListPage(service: mockService)));

    await tester.pumpAndSettle();

    expect(find.text('Apples'), findsOneWidget);
    expect(find.text('Oranges'), findsOneWidget);
    expect(find.text('@Alice'), findsOneWidget);
    expect(find.text('@Bob'), findsOneWidget);
    expect(find.text('Hi'), findsOneWidget);
    expect(find.text('Yo'), findsOneWidget);
  });

}
