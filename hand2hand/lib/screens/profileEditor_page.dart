import 'package:flutter/material.dart';
import 'package:hand2hand/supabase_service.dart';

class EditProfileScreen extends StatefulWidget {
  final SupabaseService supabaseService;
  final bool popOnSave;
  EditProfileScreen({
    super.key,
    SupabaseService? service,
    this.popOnSave = true,
  }) : supabaseService = service ?? SupabaseService();

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

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
    final userData = await widget.supabaseService.getCurrentUserData();
    if (mounted && userData != null) {
      setState(() {
        _nameController = TextEditingController(text: userData['name'] ?? '');
        _usernameController = TextEditingController(
          text: userData['username'] ?? '',
        );
        _emailController = TextEditingController(text: userData['email'] ?? '');
        _locationController = TextEditingController(
          text: userData['location'] ?? '',
        );
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final userId = widget.supabaseService.currentUserId;
      if (userId == null) throw Exception("User not logged in");

      await widget.supabaseService.updateUserProfile(
        userId: userId,
        name: _nameController!.text.trim(),
        username: _usernameController!.text.trim(),
        email: _emailController!.text.trim(),
        location: _locationController!.text.trim(),
      );

      messenger.showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );

      if (widget.popOnSave) {
        navigator.pop();
      }
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Color.fromARGB(255, 222, 79, 79),
          ),
        ),
        backgroundColor: Color.fromARGB(223, 255, 213, 63),
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 222, 79, 79)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Small section title
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0, top: 8.0),
                child: Text(
                  'YOUR PROFILE',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black54,
                    letterSpacing: 1,
                  ),
                ),
              ),
              _ProfileEditRow(
                label: 'Name',
                controller: _nameController!,
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Enter a name' : null,
              ),
              _ProfileEditRow(
                label: 'Username',
                controller: _usernameController!,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter a username'
                            : null,
              ),
              _ProfileEditRow(
                label: 'Email',
                controller: _emailController!,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter an email'
                            : null,
              ),
              _ProfileEditRow(
                label: 'Location',
                controller: _locationController!,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(223, 255, 213, 63),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child:
                      _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Save',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    await widget.supabaseService.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed('/welcome');
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Color.fromARGB(255, 222, 79, 79),
                    side: const BorderSide(
                      color: Color.fromARGB(255, 222, 79, 79),
                      width: 3,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color.fromARGB(255, 222, 79, 79),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom widget for each profile field row with pencil icon and no underline
class _ProfileEditRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const _ProfileEditRow({
    required this.label,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              validator: validator,
              style: const TextStyle(fontSize: 16, color: Colors.black),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 15,
                ),
                border: InputBorder.none, // Remove underline
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 2),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.edit, color: Colors.grey, size: 20),
        ],
      ),
    );
  }
}
