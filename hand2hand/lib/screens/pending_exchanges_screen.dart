import 'package:flutter/material.dart';
import 'package:hand2hand/supabase_service.dart';

class PendingExchangesScreen extends StatefulWidget {
  @override
  State<PendingExchangesScreen> createState() => _PendingExchangesScreenState();
}

class _PendingExchangesScreenState extends State<PendingExchangesScreen> {
  final supabaseService = SupabaseService();

  final Set<int> _processingExchanges = {};

  final Set<int> _confirmedExchanges = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pending Exchanges')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabaseService.streamPendingExchanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final exchanges = snapshot.data!;

          if (exchanges.isEmpty) {
            return const Center(child: Text('No pending exchanges.'));
          }

          return ListView.builder(
            itemCount: exchanges.length,
            itemBuilder: (context, index) {
              final exchange = exchanges[index];
              final exchangeId = exchange['id'] as int;
              final isRequester =
                  exchange['requester_id'] == supabaseService.currentUserId;

              final youConfirmed =
                  isRequester
                      ? (exchange['requester_confirmed'] ?? false) as bool
                      : (exchange['donor_confirmed'] ?? false) as bool;

              final otherConfirmed =
                  isRequester
                      ? (exchange['donor_confirmed'] ?? false) as bool
                      : (exchange['requester_confirmed'] ?? false) as bool;

              final otherUser =
                  isRequester
                      ? (exchange['owner']?['name'] ??
                          exchange['owner']?['username'] ??
                          'Unknown')
                      : (exchange['requester']?['name'] ??
                          exchange['requester']?['username'] ??
                          'Unknown');

              return ListTile(
                title: Text(
                  "${exchange['item']?['name'] ?? 'Unknown Item'} - "
                  "${isRequester ? 'You requested from $otherUser' : '$otherUser requested'}",
                ),
                subtitle: Text(
                  'Your confirmation: ${youConfirmed || _confirmedExchanges.contains(exchangeId) ? "✅" : "❌"}\nOther: ${otherConfirmed ? "✅" : "❌"}',
                ),
                trailing:
                    youConfirmed || _confirmedExchanges.contains(exchangeId)
                        ? const Icon(Icons.check, color: Colors.green)
                        : ElevatedButton(
                          child:
                              _processingExchanges.contains(exchangeId)
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text("Confirm"),
                          onPressed:
                              _processingExchanges.contains(exchangeId)
                                  ? null
                                  : () async {
                                    final confirmed =
                                        await showDialog<bool>(
                                          context: context,
                                          builder:
                                              (context) => AlertDialog(
                                                title: const Text(
                                                  'Confirm Exchange',
                                                ),
                                                content: const Text(
                                                  'Are you sure you want to confirm this exchange? This action cannot be undone.',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    child: const Text('Cancel'),
                                                    onPressed:
                                                        () => Navigator.of(
                                                          context,
                                                        ).pop(false),
                                                  ),
                                                  ElevatedButton(
                                                    child: const Text(
                                                      'Confirm',
                                                    ),
                                                    onPressed:
                                                        () => Navigator.of(
                                                          context,
                                                        ).pop(true),
                                                  ),
                                                ],
                                              ),
                                        ) ??
                                        false;

                                    if (!confirmed) return;

                                    setState(() {
                                      _processingExchanges.add(exchangeId);
                                    });

                                    try {
                                      await supabaseService.confirmExchange(
                                        exchangeId,
                                      );

                                      setState(() {
                                        _confirmedExchanges.add(exchangeId);
                                      });

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Exchange confirmed!'),
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Error: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    } finally {
                                      setState(() {
                                        _processingExchanges.remove(exchangeId);
                                      });
                                    }
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
