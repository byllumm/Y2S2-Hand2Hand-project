import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hand2hand/supabase_service.dart';

class PendingExchangesScreen extends StatelessWidget {
  final supabaseService = SupabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pending Exchanges')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabaseService.streamPendingExchanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final exchanges = snapshot.data!;

          return ListView.builder(
            itemCount: exchanges.length,
            itemBuilder: (context, index) {
              final exchange = exchanges[index];
              final isRequester = exchange['requester_id'] == supabaseService.currentUserId;

              final youConfirmed = isRequester
                  ? (exchange['requester_confirmed'] ?? false) as bool
                  : (exchange['owner_confirmed'] ?? false) as bool;

              final otherConfirmed = isRequester
                  ? (exchange['owner_confirmed'] ?? false) as bool
                  : (exchange['requester_confirmed'] ?? false) as bool;

              return ListTile(
                title: Text("${exchange['item_name']} - ${isRequester ? 'You requested' : 'Requested from you'}"),
                subtitle: Text('Your confirmation: ${youConfirmed ? "✅" : "❌"}\nOther: ${otherConfirmed ? "✅" : "❌"}'),
                trailing: youConfirmed
                    ? const Icon(Icons.check, color: Colors.green)
                    : ElevatedButton(
                        child: const Text("Confirm"),
                        onPressed: () async {
                          await supabaseService.confirmExchange(exchange['id']);
                        },
                      ),
              );
            },
          );
        },
      ),
    );
  }
}
