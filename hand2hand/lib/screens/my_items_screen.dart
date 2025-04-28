import 'package:flutter/material.dart';
import '../supabase_service.dart';
import '../add_item_dialog.dart';
import 'package:hand2hand/screens/add_item_page.dart';
import 'dart:io';

class MyItemsScreen extends StatefulWidget {
  const MyItemsScreen({super.key});

  @override
  _MyItemsScreenState createState() => _MyItemsScreenState();
}

class _MyItemsScreenState extends State<MyItemsScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  late Stream<List<Map<String, dynamic>>> itemsStream;

  @override
  void initState() {
    super.initState();
    itemsStream = _supabaseService.streamItems();
  }

  Future<void> _addItem(
    String name,
    int quantity,
    DateTime expirationDate,
    int action, // 0 for offer, 1 for trade
    double latitude,
    double longitude,
    String description,
    File imageFile,
  ) async {
    try {
      await _supabaseService.addItem(
        name, // Name
        quantity, // Quantity
        expirationDate, // Expiration Date
        action, // Action: 0 for offer, 1 for trade
        latitude, // Latitude
        longitude, // Longitude
        description, // Description
        imageFile, // Image File
      );
    } catch (e) {
      print('Error adding item: $e');
    }
  }

  Future<void> _deleteItem(int id) async {
    // Show a confirmation dialog before deleting the item
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirm Deletion'),
              content: Text('Are you sure you want to delete this item?'),
              actions: <Widget>[
                TextButton(
                  onPressed:
                      () => Navigator.of(context).pop(false), // Do not delete
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed:
                      () => Navigator.of(
                        context,
                      ).pop(true), // Proceed with deletion
                  child: Text('Confirm'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (shouldDelete) {
      try {
        await _supabaseService.deleteItem(id);
        setState(() {
          itemsStream = _supabaseService.streamItems();
        });
      } catch (e) {
        print('Error deleting item: $e');
      }
    }
  }

  // Removed unused _showAddItemDialog method as it is not referenced.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Browse Items')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: itemsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No items available'));
          }

          final items = snapshot.data!;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text('${item['name']} (Qty: ${item['quantity']})'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Exp Date: ${item['expirationDate']}'),
                      Text('Action: ${item['action']}'),
                      Text('Trade Point: ${item['tradePoint']}'),
                      Text('Details: ${item['details']}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteItem(item['id']),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddItemPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
