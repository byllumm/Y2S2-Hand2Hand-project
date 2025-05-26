import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hand2hand/supabase_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:hand2hand/screens/chatscreen_page.dart';

class NotificationsPage extends StatelessWidget {
  final Function(int) onTabChange;
  final SupabaseService supabaseService;

  const NotificationsPage({
    super.key,
    required this.onTabChange,
    required this.supabaseService,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = supabaseService.currentUserId;

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifications',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 33, 33, 33),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    Text(
                      'Incoming Requests',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: supabaseService.streamIncomingRequests(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }

                        final requests = snapshot.data ?? [];

                        if (requests.isEmpty) {
                          return const Center(
                            child: Text(
                              'No new requests',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }

                        return Column(
                          children:
                              requests.map((request) {
                                final createdAt =
                                    DateTime.tryParse(
                                      request['created_at'] ?? '',
                                    ) ??
                                    DateTime.now();
                                final timeAgo = timeago.format(
                                  createdAt,
                                  allowFromNow: true,
                                );

                                final requesterName =
                                    request['requester']?['name'] ?? 'Someone';
                                final itemName =
                                    request['item']?['name'] ?? 'Unknown';
                                final requestId = request['id'];
                                final ownerId = request['owner_id'];
                                final itemId = request['item_id'];
                                final receiverId = request['requester_id'];

                                final isDonor = currentUserId == ownerId;

                                final status = request['status'];

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const CircleAvatar(
                                            backgroundColor: Color.fromARGB(
                                              106,
                                              253,
                                              243,
                                              211,
                                            ),
                                            child: Icon(
                                              Icons.notifications_none,
                                              color: Color.fromARGB(
                                                255,
                                                255,
                                                213,
                                                63,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              '$requesterName requested your item "$itemName"',
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            timeAgo,
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      if (isDonor)
                                        status == 'accepted'
                                            ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (
                                                              context,
                                                            ) => ChatScreen(
                                                              itemId: itemId,
                                                              receiverId:
                                                                  receiverId,
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                  style: TextButton.styleFrom(
                                                    foregroundColor:
                                                        Colors.blue,
                                                  ),
                                                  child: const Text(
                                                    "Send Message",
                                                  ),
                                                ),
                                              ],
                                            )
                                            : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                TextButton(
                                                  onPressed: () async {
                                                    await supabaseService
                                                        .respondToRequest(
                                                          requestId: requestId,
                                                          accepted: true,
                                                        );
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          "Request Accepted",
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  style: TextButton.styleFrom(
                                                    foregroundColor:
                                                        Colors.green,
                                                  ),
                                                  child: const Text("Accept"),
                                                ),
                                                const SizedBox(width: 8),
                                                TextButton(
                                                  onPressed: () async {
                                                    await supabaseService
                                                        .respondToRequest(
                                                          requestId: requestId,
                                                          accepted: false,
                                                        );
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          "Request Declined",
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  style: TextButton.styleFrom(
                                                    foregroundColor: Colors.red,
                                                  ),
                                                  child: const Text("Decline"),
                                                ),
                                              ],
                                            ),
                                    ],
                                  ),
                                );
                              }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Updates on your requests',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: supabaseService.streamNotifications(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }
                        final notifications = snapshot.data ?? [];
                        if (notifications.isEmpty) {
                          return const Center(
                            child: Text(
                              'No updates yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }
                        return Column(
                          children:
                              notifications.map((notif) {
                                final createdAt =
                                    DateTime.tryParse(
                                      notif['created_at'] ?? '',
                                    ) ??
                                    DateTime.now();
                                final timeAgo = timeago.format(
                                  createdAt,
                                  allowFromNow: true,
                                );

                                Icon leadingIcon;
                                Color cardColor;

                                if (notif['type'] == 'response') {
                                  if (notif['data'] != null &&
                                      notif['data']['accepted'] == false) {
                                    leadingIcon = const Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                      size: 32,
                                    );
                                    cardColor = const Color(0xFFFFEBEE);
                                  } else {
                                    leadingIcon = const Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.green,
                                      size: 32,
                                    );
                                    cardColor = const Color(0xFFE8F5E9);
                                  }
                                } else {
                                  leadingIcon = const Icon(
                                    Icons.notifications,
                                    color: Colors.blue,
                                    size: 32,
                                  );
                                  cardColor = const Color(0xFFE3F2FD);
                                }

                                return Card(
                                  color: cardColor,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  elevation: 2,
                                  child: ListTile(
                                    leading: leadingIcon,
                                    title: Text(
                                      notif['title'] ?? 'Notification',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      notif['body'] ?? '',
                                      style: GoogleFonts.inter(),
                                    ),
                                    trailing: Text(
                                      timeAgo,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    onTap: () {},
                                  ),
                                );
                              }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
