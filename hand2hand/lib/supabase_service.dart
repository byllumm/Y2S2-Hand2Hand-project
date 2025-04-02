import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class SupabaseService {
  // Singleton implementation
  SupabaseService._privateConstructor();
  static final SupabaseService _instance =
      SupabaseService._privateConstructor();
  factory SupabaseService() => _instance;

  final _client = Supabase.instance.client;
  String? _loggedInUsername; // Store the logged-in username

  // Stream items from the Supabase database
  Stream<List<Map<String, dynamic>>> streamItems() {
    return _client
        .from('items')
        .stream(primaryKey: ['id'])
        .map((data) => List<Map<String, dynamic>>.from(data));
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
    if (_loggedInUsername == null) {
      throw Exception('User is not logged in');
    }

    // Get the user ID based on the logged-in username
    final userResponse =
        await _client
            .from('User')
            .select('id')
            .eq('username', _loggedInUsername!)
            .maybeSingle();

    if (userResponse == null || userResponse['id'] == null) {
      throw Exception('Error retrieving user ID');
    }

    final userId = userResponse['id'];

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
            'user_id': userId, // Add the user ID
          }).select();

      print('Insert Response: $response'); // Log the response for debugging

      if (response == null || response.isEmpty) {
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
    final response = await _client.from('items').delete().eq('id', id);
    if (response == null) {
      throw Exception('Error deleting item');
    }
  }

  // Sign in a user
  Future<bool> signIn(String username, String password) async {
    final response =
        await _client
            .from('User')
            .select('*')
            .eq('username', username)
            .eq('password', password)
            .maybeSingle();

    if (response != null) {
      _loggedInUsername = username; // Store the username after successful login
      print('Login successful. Logged in username: $_loggedInUsername');
      return true; // Sign-in successful
    } else {
      print('Login failed. Invalid username or password.');
      return false; // Invalid credentials
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
}
