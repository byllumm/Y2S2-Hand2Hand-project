import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../supabase_service.dart';
import 'package:hand2hand/screens/add_item_page.dart';

class MyItemsScreen extends StatefulWidget {
  final SupabaseService service;

  const MyItemsScreen({super.key, required this.service});

  @override
  _MyItemsScreenState createState() => _MyItemsScreenState();
}

class _MyItemsScreenState extends State<MyItemsScreen> {
  late Stream<List<Map<String, dynamic>>> itemsStream;

  @override
  void initState() {
    super.initState();
    itemsStream = widget.service.streamItems();
  }

  Future<void> _deleteItem(int id) async {
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Confirm Deletion',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
              content: Text(
                'Are you sure you want to delete this item?',
                style: GoogleFonts.outfit(),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.outfit(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    'Confirm',
                    style: GoogleFonts.outfit(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;

    if (shouldDelete) {
      try {
        await widget.service.deleteItem(id);
        setState(() {
          itemsStream = widget.service.streamItems();
        });
      } catch (e) {
        print('Error deleting item: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Items',
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 222, 79, 79),
          ),
        ),
        backgroundColor: const Color.fromARGB(223, 255, 213, 63),
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 222, 79, 79)),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: itemsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: GoogleFonts.outfit(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No items available',
                style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final items = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  title: Text(
                    '${item['name']} (Qty: ${item['quantity']})',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'Exp Date: ${item['expirationDate']}',
                    style: GoogleFonts.outfit(fontSize: 14),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteItem(item['id']),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
