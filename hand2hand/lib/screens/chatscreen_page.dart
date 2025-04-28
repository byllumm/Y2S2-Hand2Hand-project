import 'package:flutter/material.dart';
import 'package:hand2hand/message.dart';
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

  @override
  void initState() {
    super.initState();
    _loadMessages();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return ListTile(
                        title: Text(message.content),
                        subtitle: Text(_usernamesCache[message.senderId] ?? '...'),
                        trailing: Text('${message.createdAt.hour}:${message.createdAt.minute}'),
                      );
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
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send),
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