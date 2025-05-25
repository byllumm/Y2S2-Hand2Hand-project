import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'my_items_screen.dart';
import 'profileEditor_page.dart';
import 'package:hand2hand/supabase_service.dart';
import 'pending_exchanges_screen.dart';

class ProfileScreen extends StatefulWidget {
  final SupabaseService supabaseService;

  ProfileScreen({super.key, SupabaseService? supabaseService})
      : supabaseService = supabaseService ?? SupabaseService();

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}


class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>?> _userFuture;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    _userFuture = widget.supabaseService.getCurrentUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Profile',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text("Failed to load user data"));
          }

          final username = snapshot.data!['username'] ?? 'users';
          final nameInitial =
              username.isNotEmpty ? username[0].toUpperCase() : 'U';

          return ListView(
            children: [
              ListTile(
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.deepPurple,
                  child: Text(
                    nameInitial,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                title: Text(
                  username,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text("View my profile"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  EditProfileScreen(),
                    ),
                  ).then((_) {
                    setState(() {
                      _loadUser();
                    });
                  });
                },
              ),
              const Divider(),

              ListTile(
                leading: const Icon(Icons.inventory_2_outlined),
                title: const Text("My Items"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyItemsScreen(service: widget.supabaseService),
                    ),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.shopping_bag_outlined),
                title: const Text("Requested Items"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Link to OrderedItemsScreen
                },
              ),

              ListTile(
                leading: const Icon(Icons.pending_actions_outlined),
                title: const Text("Pending Exchanges"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PendingExchangesScreen()),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
