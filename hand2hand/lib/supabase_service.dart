import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:hand2hand/message.dart';

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
        .eq('user_id', _userId!)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  Stream<List<Map<String, dynamic>>> streamOtherUsersItems() {
    if (_userId == null) {
      throw Exception('User is not logged in');
    }

    return _client
        .from('items')
        .stream(primaryKey: ['id'])
        .neq('user_id', _userId!)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  Future<Map<String, dynamic>> getItemStatus(int itemId) async {
  final response = await _client
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

  // Request an item (mark it as requested)
  Future<bool> requestItem(int itemId) async {
  try {
    final currentUserId = _userId;
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    final response = await _client
        .from('items')
        .update({
          'is_requested': true,
          'requested_by': currentUserId, // Track who requested it
          'requested_at': DateTime.now().toIso8601String(),
        })
        .eq('id', itemId)
        .select();

    return response.isNotEmpty;
  } catch (e) {
    print('Error requesting item: $e');
    return false;
  }
}

  Future<Map<String, dynamic>?> getUserById(int userId) async {
  final response = await _client
      .from('User')
      .select('id, name, username, location')
      .eq('id', userId)
      .maybeSingle();

  return response;
}


  Future<void> addItem(
    String name,
    int quantity,
    DateTime expDate,
    int action, // 0 for offer, 1 for trade
    double latitude,
    double longitude,
    String description,
    File imageFile,
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
            'action': action, // 0 for offer, 1 for trade
            'latitude': latitude,
            'longitude': longitude,
            'description': description,
            'image': imageUrl, // Save the image URL
            'user_id': _userId, // Add the user ID
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
    final response = await _client
        .from('items')
        .update({'is_deleted': true})  // Mark the item as deleted
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
        .eq('receiver_id', receiverId)
        .order('created_at', ascending: true);
    return (response as List).map((e) => Message.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<void> sendMessage(Message message) async {
    final response = await _client.from('messages').insert(message.toMap());

    if(response == null || response.isEmpty) {
      throw Exception('Failed to insert message or response was empty.');
    }
  }

  void subscribeToMessages({required int itemId, required Function(Message) onNewMessage, }) {
    if(_userId == null) return;

    _messageChannel = _client.channel('messages_channel');
    
    _messageChannel!.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'messages',
      callback: (payload) {
        final data = payload.newRecord;
        if(data == null) return;

        final message = Message.fromMap(data);

        if(message.itemId == itemId && (message.senderId == _userId || message.receiverId == _userId)) {
          onNewMessage(message);
        }
      },
    ).subscribe();
  }

  void unsubscribeFromMessages() {
    if(_messageChannel != null) {
      _client.removeChannel(_messageChannel!);
      _messageChannel = null;
    }
  }

  String? get currentUsername => _loggedInUsername;
  int? get currentUserId => _userId;
}
