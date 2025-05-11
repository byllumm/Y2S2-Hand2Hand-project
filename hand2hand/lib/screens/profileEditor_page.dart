import 'package:flutter/material.dart';
import 'package:hand2hand/supabase_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final SupabaseService _supabaseService = SupabaseService();

  TextEditingController? _nameController;
  TextEditingController? _usernameController;
  TextEditingController? _emailController;
  TextEditingController? _locationController;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await _supabaseService.getCurrentUserData();
    if (mounted && userData != null) {
      setState(() {
        _nameController = TextEditingController(text: userData['name'] ?? '');
        _usernameController = TextEditingController(text: userData['username'] ?? '');
        _emailController = TextEditingController(text: userData['email'] ?? '');
        _locationController = TextEditingController(text: userData['location'] ?? '');
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final messenger = ScaffoldMessenger.of(context); // Save context reference early
    final navigator = Navigator.of(context);

    try {
      final userId = _supabaseService.currentUserId;
      if (userId == null) throw Exception("User not logged in");

      await _supabaseService.updateUserProfile(
        userId: userId,
        name: _nameController!.text.trim(),
        username: _usernameController!.text.trim(),
        email: _emailController!.text.trim(),
        location: _locationController!.text.trim(),
      );

      messenger.showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );

      navigator.pop(); // Safely using saved navigator
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_nameController == null ||
        _usernameController == null ||
        _emailController == null ||
        _locationController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value == null || value.isEmpty ? 'Enter a name' : null,
              ),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) => value == null || value.isEmpty ? 'Enter a username' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value == null || value.isEmpty ? 'Enter an email' : null,
              ),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _saveProfile,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
