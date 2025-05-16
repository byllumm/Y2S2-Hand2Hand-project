import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hand2hand/chatpreview.dart';
import 'package:hand2hand/navigation_helper.dart';
import 'package:hand2hand/screens/explorer_page.dart';
import 'package:hand2hand/screens/navController.dart';
import 'package:hand2hand/supabase_service.dart';
import 'chatscreen_page.dart';

class ChatListPage extends StatefulWidget {
  final SupabaseService service;

  ChatListPage({Key? key, SupabaseService? service})
      : service = service ?? SupabaseService(),
        super(key: key);

  @override
  _ChatListPageState createState() => _ChatListPageState();
}


class _ChatListPageState extends State<ChatListPage> {
  List<ChatPreview> _chats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    try {
      final currentUserId = widget.service.currentUserId;

      if (currentUserId == null) {
        throw Exception('User not logged in');
      }

      final chats = await widget.service.getUserChats(currentUserId);

      setState(() {
        _chats = chats;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading chats: $e");
      setState(() {
        _isLoading = false;
      });
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
          return ListTile(
            title: Text(chat.username),
            subtitle: Text(chat.lastMessage),
            trailing: Text(
              "${chat.lastMessageTime.hour}:${chat.lastMessageTime.minute.toString().padLeft(2, '0')}",
            ),
            onTap: () {
              navigateWithTransition(context, ChatScreen(itemId: chat.chatId, receiverId: chat.userId,),
              );
            },
          );
        },
      ),
    );
  }
}