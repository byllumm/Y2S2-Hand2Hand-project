import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/material.dart';
import 'package:hand2hand/screens/chatlist_page.dart';
import 'package:hand2hand/supabase_service.dart';
import 'package:hand2hand/chatpreview.dart';
import 'dart:async';
import 'package:hand2hand/screens/navController.dart';

class MockSupabaseService extends Mock implements SupabaseService {}

void main() {
  late MockSupabaseService mockService;

  setUp(() {
    mockService = MockSupabaseService();
  });

  testWidgets('displays chat data after loading', (tester) async {
    final fakeChat = ChatPreview(
      chatId: 1,
      userId: 42,
      username: 'Alice',
      lastMessage: 'Hello!',
      lastMessageTime: DateTime(2025, 5, 15, 14, 30),
    );

      when(() => mockService.currentUserId).thenReturn(123);


      when(() => mockService.getUserChats(123)).thenAnswer((_) async => [fakeChat]);

    await tester.pumpWidget(MaterialApp(home: ChatListPage(service: mockService)));

    await tester.pumpAndSettle();

    expect(find.text('Alice'), findsOneWidget);
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
    final fakeChat = ChatPreview(
      chatId: 1,
      userId: 42,
      username: 'Alice',
      lastMessage: 'Hello!',
      lastMessageTime: DateTime(2025, 5, 15, 14, 5),
    );

    when(() => mockService.currentUserId).thenReturn(123);
    when(() => mockService.getUserChats(123)).thenAnswer((_) async => [fakeChat]);

    await tester.pumpWidget(MaterialApp(home: ChatListPage(service: mockService)));

    await tester.pumpAndSettle();

    expect(find.text('14:05'), findsOneWidget);
  });

}
