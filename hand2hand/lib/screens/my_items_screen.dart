import 'package:flutter/material.dart';
import '../supabase_service.dart';
import '../add_item_dialog.dart';
import 'package:hand2hand/screens/add_item_page.dart';

class MyItemsScreen extends StatefulWidget {
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
    String action,
    String tradePoint,
    String details,
  ) async {
    try {
      await _supabaseService.addItem(
        name,
        quantity,
        expirationDate,
        action,
        tradePoint,
        details,
      );
    } catch (e) {
      print('Error adding item: $e');
    }
  }

  Future<void> _deleteItem(int id) async {
    try {
      await _supabaseService.deleteItem(id);
    } catch (e) {
      print('Error deleting item: $e');
    }
  }

void _showAddItemDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return AddItemDialog(
        onAdd: (name, quantity, expirationDate, action, tradePoint, details) {
          _addItem(name, quantity, expirationDate, action, tradePoint, details);
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
            MaterialPageRoute(
              builder: (context) => AddItemPage(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
