import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hand2hand/chatpreview.dart';
import 'package:hand2hand/navigation_helper.dart';
import 'package:hand2hand/screens/explorer_page.dart';
import 'package:hand2hand/screens/itemDetail_page.dart';
import 'package:hand2hand/screens/navController.dart';
import 'package:hand2hand/supabase_service.dart';
import 'package:intl/intl.dart';
import 'chatscreen_page.dart';

class ChatListPage extends StatefulWidget {
  final SupabaseService? service;

  const ChatListPage({Key? key, this.service}) : super(key: key);

  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  late final SupabaseService _service;

  List<ChatPreview> _chats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? SupabaseService();
    _loadChats();
  }

  Future<void> _loadChats() async {
    try {
      final currentUserId = _service.currentUserId!;
      if (currentUserId == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final List<ChatPreview> chats = await _service.getUserChats(currentUserId);
      setState(() {
        _chats = chats;
        _isLoading = false;
      });
    }
    catch (e) {
      print("Error loading chats: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if(msgDay == today) {
      return DateFormat.Hm().format(dateTime);
    }

    else if(msgDay.isAfter(today.subtract(const Duration(days: 7)))) {
      return DateFormat.E().format(dateTime);
    }

    else {
      return DateFormat('dd/MM').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color.fromARGB(255, 222, 79, 79)),
          onPressed: () {
            navigateWithTransition(context, HomePage());
          },
        ),
        title: Text(
          'Messages',
          style: GoogleFonts.outfit(
            fontSize: 26,
            color: Color.fromARGB(255, 222, 79, 79),
          ),
        ),
        backgroundColor: Color.fromARGB(223, 255, 213, 63),
        elevation: 0,
      ),

      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _chats.length,
        itemBuilder: (context, index) {
          final chat = _chats[index];
          final formattedTime = _formatTime(chat.lastMessageTime);

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: (chat.itemImage != null && chat.itemImage!.isNotEmpty)
                  ? Image.network(
                chat.itemImage!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey,
                    width: 50,
                    height: 50,
                    child: Icon(Icons.image, color: Colors.white),
                  );
                },
              )
                  : Container(
                color: Colors.grey,
                width: 50,
                height: 50,
                child: Icon(Icons.image, color: Colors.white),
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    chat.itemName,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 15),
                Text(
                  '@${chat.otherUsername}',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            subtitle: Text(
              chat.lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
            trailing: Text(
              formattedTime,
              style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
            ),
            onTap: () {
              navigateWithTransition(
                context,
                ChatScreen(itemId: chat.itemId, receiverId: chat.otherUserId),
              );
            },
          );
        },
      ),
    );
  }
}