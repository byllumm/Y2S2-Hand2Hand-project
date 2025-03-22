import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  // Stream items from the Supabase database
  Stream<List<Map<String, dynamic>>> streamItems() {
    return _client
        .from('items')
        .stream(primaryKey: ['id'])
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  Future<void> addItem(
    String name,
    String description,
    DateTime expirationDate,
    int quantity,
    String category,
  ) async {
    final response = await _client.from('items').insert({
      'name': name,
      'description': description,
      'expirationDate': expirationDate.toIso8601String(),
      'quantity': quantity,
      'category': category,
    });

    if (response == null) {
      throw Exception('Error adding item');
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
      return true; // Sign-in successful
    } else {
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
