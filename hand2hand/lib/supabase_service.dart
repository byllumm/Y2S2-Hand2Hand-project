import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:hand2hand/message.dart';
import 'package:hand2hand/chatpreview.dart';

class SupabaseService {
  // Singleton implementation
  SupabaseService._privateConstructor();
  static final SupabaseService _instance =
  SupabaseService._privateConstructor();
  factory SupabaseService() => _instance;

  final _client = Supabase.instance.client;
  String? _loggedInUsername; // Store the logged-in username
  int? _userId; // Cache the logged-in user's ID
  RealtimeChannel? _messageChannel;

  // Stream items from the Supabase database for the logged-in user
  Stream<List<Map<String, dynamic>>> streamItems() {
    if (_userId == null) {
      throw Exception('User is not logged in or user ID not available');
    }

    return _client
        .from('items')
        .stream(primaryKey: ['id'])
        .map(
          (items) =>
          items
              .where(
                (item) =>
            item['user_id'] == _userId &&
                item['is_deleted'] == false,
          )
              .toList(),
    );
  }

  Stream<List<Map<String, dynamic>>> streamOtherUsersItems() {
    if (_userId == null) {
      throw Exception('User is not logged in');
    }

    final query = _client
        .from('items')
        .select()
        .neq('user_id', _userId!)
        .eq('is_deleted', false)
        .eq('is_requested', false);

    return query.asStream().map(
          (data) => List<Map<String, dynamic>>.from(data),
    );
  }

  Future<Map<String, dynamic>> getItemStatus(int itemId) async {
    final response =
    await _client
        .from('items')
        .select('is_requested, is_deleted, user_id')
        .eq('id', itemId)
        .maybeSingle();

    if (response != null) {
      return {
        'available': !response['is_requested'] && !response['is_deleted'],
        'is_requested': response['is_requested'],
        'is_deleted': response['is_deleted'],
        'user_id': response['user_id'],
      };
    }
    return {'available': false};
  }

  Future<bool> requestItem(int itemId) async {
    try {
      if (_userId == null) throw Exception('User is not logged in');

      // Check if item is still available
      final item = await getItemStatus(itemId);
      if (!item['available']) {
        print('Item is not available.');
        return false;
      }

      // Check if the user already requested this item
      final existing =
      await _client
          .from('requests')
          .select()
          .eq('item_id', itemId)
          .eq('requester_id', _userId!)
          .maybeSingle();

      if (existing != null) {
        print('User already requested this item.');
        return false;
      }

      // Insert new request
      final response = await _client.from('requests').insert({
        'item_id': itemId,
        'requester_id': _userId,
        'owner_id': item['user_id'],
        'status': 'pending',
      });

      return true;
    } catch (e) {
      print('Error requesting item: $e');
      return false;
    }
  }

  Future<void> respondToRequest({
    required int requestId,
    required bool accepted,
  }) async {
    if (_userId == null) throw Exception('User not logged in');

    final responseText = accepted ? "accepted" : "declined";

    // 1. Update the request's status
    await _client
        .from('requests')
        .update({'status': responseText})
        .eq('id', requestId);

    // 2. Fetch request details
    final request =
    await _client
        .from('requests')
        .select('requester_id, item_id')
        .eq('id', requestId)
        .maybeSingle();

    if (request == null) return;

    final requesterId = request['requester_id'];
    final itemId = request['item_id'];

    if (accepted) {
      await _client
          .from('items')
          .update({'is_requested': true})
          .eq('id', itemId);
    }

    // 3. Get item name for message
    final item = await getItemById(itemId);
    final itemName = item?['name'] ?? 'your item';

    // 4. (Optional) Fetch current user details for better messaging
    final currentUser = await getCurrentUserData();
    final currentUserName = currentUser?['name'] ?? 'Someone';

    // 5. Insert a notification
    await _client.from('notifications').insert({
      'recipient_id': requesterId,
      'title': 'Request $responseText',
      'body':
      '$currentUserName has $responseText your request for "$itemName".',
      'type': 'response',
      'data': {
        'request_id': requestId,
        'item_id': itemId,
        'accepted': accepted,
      },
      'read': false,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Stream<List<Map<String, dynamic>>> streamNotifications() {
    if (_userId == null) {
      throw Exception('User not logged in');
    }

    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId!)
        .order('created_at', ascending: false)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final response =
    await _client
        .from('User')
        .select('id, name, username,email, location')
        .eq('id', userId)
        .maybeSingle();

    return response;
  }

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    if (_userId == null) return null;

    final user = await getUserById(_userId!);
    return user;
  }

  Future<void> updateUserProfile({
    required int userId,
    required String name,
    required String username,
    required String email,
    required String location,
  }) async {
    await _client
        .from('User')
        .update({
      'name': name,
      'username': username,
      'email': email,
      'location': location,
    })
        .eq('id', userId);
  }

  Future<Map<String, dynamic>?> getItemById(int itemId) async {
    final response =
    await _client
        .from('items')
        .select('id, name')
        .eq('id', itemId)
        .maybeSingle();
    return response;
  }

  Stream<List<Map<String, dynamic>>> streamIncomingRequests() async* {
    if (_userId == null) {
      throw Exception('User not logged in');
    }

    while (true) {
      final response = await _client
          .from('requests')
          .select(
        'id, created_at, status, item_id, requester_id, owner_id, requester:User(name), item:item_id(name)',
      )
          .eq('owner_id', _userId!)
          .eq('status', 'pending')
          .order('created_at');

      yield List<Map<String, dynamic>>.from(response);
      await Future.delayed(Duration(seconds: 2));
    }
  }

  Stream<List<Map<String, dynamic>>> streamPendingExchanges() async* {
    if (_userId == null) throw Exception('User not logged in');

    while (true) {
      try {
        final response = await _client
            .from('requests')
            .select(
              'id, created_at, status, item_id, requester_id, owner_id, requester_confirmed, donor_confirmed',
            )
            .eq('status', 'pending')
            .or('requester_id.eq.$_userId,owner_id.eq.$_userId');

        final List<Map<String, dynamic>> enhancedRequests = [];

        for (final request in response) {
          final itemData = await getItemById(request['item_id']);

          final requesterData = await getUserById(request['requester_id']);

          final ownerData = await getUserById(request['owner_id']);

          final enhancedRequest = Map<String, dynamic>.from(request);
          enhancedRequest['item'] = itemData;
          enhancedRequest['requester'] = requesterData;
          enhancedRequest['owner'] = ownerData;

          enhancedRequests.add(enhancedRequest);
        }

        yield enhancedRequests;
        await Future.delayed(const Duration(seconds: 2));
      } catch (e) {
        print('Error in streamPendingExchanges: $e');
        await Future.delayed(const Duration(seconds: 5));
      }
    }
  }

  Future<void> confirmExchange(int requestId) async {
    final requestResponse =
        await _client.from('requests').select().eq('id', requestId).single();

    final request = requestResponse;
    final isRequester = request['requester_id'] == _userId;
    final updateField = isRequester ? 'requester_confirmed' : 'donor_confirmed';

    final response = await _client
        .from('requests')
        .update({updateField: true})
        .eq('id', requestId);

    if (response != null) {
      print('Exchange confirmed successfully.');
    } else {
      print('Error confirming exchange.');
    }
  }

  Future<void> addItem(
      String name,
      int quantity,
      DateTime expDate,
      double latitude, // Updated to accept latitude
      double longitude, // Updated to accept longitude
      String description,
      File imageFile,
      String? category,
      ) async {
    if (_loggedInUsername == null || _userId == null) {
      throw Exception('User is not logged in');
    }

    // Upload the image to Supabase Storage
    final imagePath =
        'item-images/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
    final storageResponse = await _client.storage
        .from('item-images')
        .upload(imagePath, imageFile);

    if (storageResponse.isEmpty) {
      throw Exception(
        'Error uploading image: Upload failed or returned empty response.',
      );
    }

    final imageUrl = _client.storage
        .from('item-images')
        .getPublicUrl(imagePath);

    try {
      // Insert the item into the database
      final response =
      await _client.from('items').insert({
        'name': name,
        'quantity': quantity,
        'expirationDate': expDate.toIso8601String(),
        'latitude': latitude, // Save latitude
        'longitude': longitude, // Save longitude
        'description': description,
        'image': imageUrl, // Save the image URL
        'user_id': _userId, // Add the user ID
        'category': category, // Default category
      }).select();

      print('Insert Response: $response'); // Log the response for debugging

      if (response.isEmpty) {
        throw Exception('Error adding item: Empty response from Supabase');
      }
    } catch (e) {
      print('Error inserting item: $e'); // Log the error
      throw Exception(
        'Error adding item: $e',
      ); // Re-throw the error with details
    }
  }

  // Delete an item from the Supabase database
  Future<void> deleteItem(int id) async {
    final response =
        await _client
            .from('items')
            .update({'is_deleted': true})
            .eq('id', id)
            .select();

    if (response.isEmpty) {
      throw Exception('Error deleting item');
    }
  }

  // Sign in a user
  Future<bool> signIn(String username, String password) async {
    final response =
        await _client
            .from('User')
            .select('id')
            .eq('username', username)
            .eq('password', password)
            .maybeSingle();

    if (response != null && response['id'] != null) {
      _loggedInUsername = username;
      _userId = response['id'];
      print(
        'Login successful. Username: $_loggedInUsername, User ID: $_userId',
      );
      return true;
    } else {
      print('Login failed. Invalid username or password.');
      return false;
    }
  }

  // Sign up a new user
  Future<void> signUp(
    String name,
    String username,
    String email,
    String password,
    String location,
  ) async {
    final response = await _client.from('User').insert({
      'username': username,
      'name': name,
      'email': email,
      'password': password,
      'location': location,
    });
  }

  void signOut() {
    _loggedInUsername = null;
    _userId = null;
    print('User signed out');
  }

  Future<List<Message>> getMessages(int itemId, int receiverId) async {
    final response = await _client
        .from('messages')
        .select()
        .eq('item_id', itemId)
        .or(
          'and(sender_id.eq.$_userId,receiver_id.eq.$receiverId),' +
              'and(sender_id.eq.$receiverId,receiver_id.eq.$_userId)',
        )
        .order('created_at', ascending: true);

    final messages = response.map((e) => Message.fromMap(e)).toList();
    return messages;
  }

  Future<void> sendMessage(Message message) async {
    final messageMap = message.toMap();
    final response = await _client.from('messages').insert(messageMap);
  }

  void subscribeToMessages({
    required int itemId,
    required Function(Message) onNewMessage,
  }) {
    if (_userId == null) return;

    _messageChannel = _client.channel('messages_channel');

    _messageChannel!
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            final data = payload.newRecord;
            if (data == null) return;

            final message = Message.fromMap(data);

            if (message.itemId == itemId &&
                (message.senderId == _userId ||
                    message.receiverId == _userId)) {
              onNewMessage(message);
            }
          },
        )
        .subscribe();
  }

  void unsubscribeFromMessages() {
    if (_messageChannel != null) {
      _client.removeChannel(_messageChannel!);
      _messageChannel = null;
    }
  }

  Future<List<ChatPreview>> getUserChats(int currentUserId) async {
    try {
      final response = await _client
          .from('messages')
          .select('''
          id, sender_id, receiver_id, item_id, content, created_at,
          sender:sender_id(username),
          receiver:receiver_id(username),
          items:item_id(name, image)
        ''')
          .or('sender_id.eq.$currentUserId,receiver_id.eq.$currentUserId')
          .order('created_at', ascending: false);

      Map<String, ChatPreview> chatMap = {};

      for (var item in response) {
        final int senderId = item['sender_id'];
        final int receiverId = item['receiver_id'];

        final bool isCurrentUserSender = senderId == currentUserId;
        final int otherUserId = isCurrentUserSender ? receiverId : senderId;

        final otherUsername = isCurrentUserSender
            ? (item['receiver']?['username'] ?? 'Unknown')
            : (item['sender']?['username'] ?? 'Unknown');

        final itemData = item['items'];
        final String chatKey = '${item['item_id']}_$otherUserId';

        if (!chatMap.containsKey(chatKey)) {
          chatMap[chatKey] = ChatPreview(
            itemId: item['item_id'],
            itemName: itemData?['name'] ?? 'Unnamed Item',
            otherUserId: otherUserId,
            otherUsername: otherUsername,
            itemImage: itemData?['image'],
            lastMessage: item['content'] ?? '',
            lastMessageTime: DateTime.parse(item['created_at']),
          );
        }
      }

      return chatMap.values.toList();
    } catch (e) {
      print('Error getting user chats: $e');
      return [];
    }
  }

  String? get currentUsername => _loggedInUsername;
  int? get currentUserId => _userId;
}
