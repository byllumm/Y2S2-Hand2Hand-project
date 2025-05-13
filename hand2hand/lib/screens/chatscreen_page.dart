import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hand2hand/message.dart';
import 'package:hand2hand/navigation_helper.dart';
import 'package:hand2hand/screens/chatlist_page.dart';
import 'package:hand2hand/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreen extends StatefulWidget {
  final int itemId;
  final int receiverId;

  const ChatScreen({Key? key, required this.itemId, required this.receiverId})
      : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _messages = <Message>[];
  Map<int, String> _usernamesCache = {};
  bool _isLoading = false;
  RealtimeChannel? _messageChannel;
  String _receiverUsername = '';

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _loadReceiverUsername();

    SupabaseService().subscribeToMessages (itemId: widget.itemId, onNewMessage: (Message newMessage) async {
      if (!_usernamesCache.containsKey(newMessage.senderId)) {
        final user = await SupabaseService().getUserById(newMessage.senderId);
        _usernamesCache[newMessage.senderId] = user?['username'] ?? 'Unknown';
      }

      setState(() {
        _messages.add(newMessage);
      });
    },
    );
  }

  @override
  void dispose() {
    SupabaseService().unsubscribeFromMessages();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if(_controller.text.isEmpty) return;

    try {
      final currentUserId = SupabaseService().currentUserId!;
      final message = Message(
        senderId: currentUserId,
        receiverId: widget.receiverId,
        itemId: widget.itemId,
        content: _controller.text,
        createdAt: DateTime.now(),
      );

      await SupabaseService().sendMessage(message);

      setState(() {
        _messages.add(message);
        _controller.clear();
      });
    }

    catch(e) {
      print('Error sending message: $e');
    }
  }

  Future<void> _loadMessages() async {
    try {
      setState(() => _isLoading = true);
      final messages = await SupabaseService().getMessages(widget.itemId, widget.receiverId);

      for(var message in messages) {
        if(!_usernamesCache.containsKey(message.senderId)){
          final user = await SupabaseService().getUserById(message.senderId);

          if(user != null) {
            _usernamesCache[message.senderId] = user['username'];
          }

          else {
            _usernamesCache[message.senderId] = 'Unknown';
          }
        }
      }

      setState(() {
        _messages.addAll(messages);
      });
    }

    catch (e) {
      print('Error loading messages: $e');
    }

    finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadReceiverUsername() async {
    final user = await SupabaseService().getUserById(widget.receiverId);
    setState(() {
      _receiverUsername = user?['username'] ?? 'unknown';
    });
  }

  Widget _buildMessageBubble(Message message) {
    final isMe = message.senderId == SupabaseService().currentUserId;
    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = isMe ? Color.fromARGB(223, 255, 233, 153): Colors.grey[300];

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Text(
          message.content,
          style: GoogleFonts.outfit(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton (
          icon: Icon(Icons.arrow_back_ios, color: Color.fromARGB(255, 222, 79, 79)),
          onPressed: () {
            navigateWithTransition(context, ChatListPage());
          },
        ),
        title: Text(
          _receiverUsername,
          style: GoogleFonts.outfit(
            fontSize: 26,
            color: Color.fromARGB(255, 222, 79, 79),
          ),
        ),
        backgroundColor: Color.fromARGB(223, 255, 213, 63),
        elevation: 0,
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                reverse: false,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _buildMessageBubble(message);
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Color.fromARGB(223, 255, 213, 63), width: 2),
                          )
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 222, 79, 79),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child : Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}