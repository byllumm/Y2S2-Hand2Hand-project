import 'package:flutter/material.dart';
import 'supabase_service.dart';
import 'add_item_dialog.dart';

class BrowseItemsScreen extends StatefulWidget {
  @override
  _BrowseItemsScreenState createState() => _BrowseItemsScreenState();
}

class _BrowseItemsScreenState extends State<BrowseItemsScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  late Stream<List<Map<String, dynamic>>> itemsStream;

  @override
  void initState() {
    super.initState();
    itemsStream = _supabaseService.streamItems();

  }


 /* @override
  void _fetchNeighborhood() async { //trying to get the neighborhood of the items
    String neighborhood = await _supabaseService.getUserNeighborhood();
    setState(() {
      itemsStream = _supabaseService.streamItems(neighborhood);
    });
  }
*/

  Future<void> _addItem(
    String name,
    String description,
    DateTime expirationDate,
    int quantity,
    String category,
  ) async {
    try {
      await _supabaseService.addItem(
        name,
        description,
        expirationDate,
        quantity,
        category,
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> _deleteItem(int id) async {
    try {
      await _supabaseService.deleteItem(id);
    } catch (e) {
      print(e);
    }
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddItemDialog(
          onAdd: (name, description, expirationDate, quantity, category) {
            _addItem(name, description, expirationDate, quantity, category);
          },
        );
      },
    );
  }

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
              return ListTile(
                title: Text('${item['name']} (Qty: ${item['quantity']})'),
                subtitle: Text(
                  '${item['description']} - Exp: ${item['expirationDate']}',
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteItem(item['id']),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
