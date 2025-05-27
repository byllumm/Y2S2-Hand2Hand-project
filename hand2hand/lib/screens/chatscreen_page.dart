import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hand2hand/message.dart';
import 'package:hand2hand/navigation_helper.dart';
import 'package:hand2hand/screens/chatlist_page.dart';
import 'package:hand2hand/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final int itemId;
  final int receiverId;
  final SupabaseService supabaseService;
  final String? initialMessage;

  ChatScreen({
    Key? key,
    required this.itemId,
    required this.receiverId,
    this.initialMessage,
    SupabaseService? supabaseService, // nullable param
  }) : supabaseService = supabaseService ?? SupabaseService(),
       super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _messages = <Message>[];
  bool _isLoading = false;
  String _receiverUsername = '';
  Color _sendButtonColor = const Color.fromARGB(255, 222, 79, 79);
  late SupabaseService _service;

  @override
  void initState() {
    super.initState();
    _service = widget.supabaseService;

    _loadMessages();
    _loadReceiverUsername();

    _service.subscribeToMessages(
      itemId: widget.itemId,
      onNewMessage: (Message newMessage) {
        setState(() {
          _messages.add(newMessage);
        });
      },
    );
    if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      Future.microtask(() => _sendAutoMessage(widget.initialMessage!));
    }
  }

  Future<void> _sendAutoMessage(String content) async {
    try {
      final currentUserId = _service.currentUserId!;
      final message = Message(
        senderId: currentUserId,
        receiverId: widget.receiverId,
        itemId: widget.itemId,
        content: content,
        createdAt: DateTime.now().toUtc(),
      );
      await _service.sendMessage(message);
    } catch (e) {
      print('Error sending auto message: $e');
    }
  }

  @override
  void dispose() {
    _service.unsubscribeFromMessages();
    super.dispose();
  }

  void _sendButtonTap() {
    setState(() {
      _sendButtonColor = const Color.fromARGB(255, 188, 36, 36);
    });
    _sendMessage();
  }

  void _sendButtonRelease() {
    setState(() {
      _sendButtonColor = const Color.fromARGB(255, 222, 79, 79);
    });
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    try {
      final currentUserId = _service.currentUserId!;
      final message = Message(
        senderId: currentUserId,
        receiverId: widget.receiverId,
        itemId: widget.itemId,
        content: _controller.text,
        createdAt: DateTime.now().toUtc(),
      );

      await _service.sendMessage(message);

      setState(() {
        _controller.clear();
      });
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Future<void> _loadMessages() async {
    try {
      setState(() => _isLoading = true);
      final messages = await _service.getMessages(
        widget.itemId,
        widget.receiverId,
      );

      setState(() {
        _messages.addAll(messages);
      });
    } catch (e) {
      print('Error loading messages: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadReceiverUsername() async {
    final user = await _service.getUserById(widget.receiverId);
    setState(() {
      _receiverUsername = user?['username'] ?? 'unknown';
    });
  }

  Widget _buildMessageBubble(Message message) {
    final isMe = message.senderId == _service.currentUserId;
    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor =
        isMe ? const Color.fromARGB(223, 255, 233, 153) : Colors.grey[300];
    final formattedTime = _formattingTime(message.createdAt);

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: GoogleFonts.outfit(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              formattedTime,
              style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  String _formattingTime(DateTime time) {
    final now = DateTime.now().toUtc();
    final msgTime = time.toUtc();
    final difference = now.difference(msgTime);

    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(msgTime.year, msgTime.month, msgTime.day);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24 && msgDay == today) {
      return DateFormat.Hm().format(msgTime.toLocal());
    } else if (difference.inDays < 7) {
      return DateFormat.E().format(msgTime.toLocal());
    } else {
      return DateFormat('dd/MM').format(msgTime.toLocal());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color.fromARGB(255, 222, 79, 79),
          ),
          onPressed: () {
            navigateWithTransition(context, ChatListPage());
          },
        ),
        title: Text(
          '@${_receiverUsername}',
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
              child:
                  _isLoading
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
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 15,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Color.fromARGB(223, 255, 213, 63),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendButtonTap,
                    onTapUp: (_) => _sendButtonRelease(),
                    onTapCancel: _sendButtonRelease,
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _sendButtonColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Icon(Icons.send, color: Colors.white, size: 24),
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
