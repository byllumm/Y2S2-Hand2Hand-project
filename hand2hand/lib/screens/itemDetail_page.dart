import 'package:flutter/material.dart';
import 'package:hand2hand/supabase_service.dart';

class ItemDetailPage extends StatefulWidget {
  final Map<String, dynamic> item;

  const ItemDetailPage({super.key, required this.item});

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  Map<String, dynamic>? donorInfo;

  @override
  void initState() {
    super.initState();
    fetchDonorInfo();
  }

  Future<void> fetchDonorInfo() async {
    final donor = await SupabaseService().getUserById(widget.item['user_id']);
    if (mounted) {
      setState(() {
        donorInfo = donor;
      });
    }
  }

  void _handleRequest() async {
    final available = await SupabaseService().getItemStatus(widget.item['id']);
    if (!mounted) return;

    if (available['available']) {
      final success = await SupabaseService().requestItem(widget.item['id']);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item requested successfully')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item not available')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      appBar: AppBar(title: Text(item['name'] ?? 'Item')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item['image'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(item['image'], height: 200, fit: BoxFit.cover),
              ),
            const SizedBox(height: 16),
            Text("Name: ${item['name']}", style: const TextStyle(fontSize: 18)),
            Text("Quantity: ${item['quantity']}"),
            Text("Type: ${item['action'] == 0 ? 'Offer' : 'Trade'}"),
            Text("Expires: ${item['expirationDate']}"),
            const SizedBox(height: 12),
            Text("Description: ${item['description']}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            if (donorInfo != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Donated by:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("Name: ${donorInfo!['name']}"),
                  Text("Username: @${donorInfo!['username']}"),
                  Text("Location: ${donorInfo!['location']}"),
                ],
              ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _handleRequest,
                child: const Text("Request"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
