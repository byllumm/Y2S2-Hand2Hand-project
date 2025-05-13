class ChatPreview {
  final int chatId;
  final int userId;
  final String username;
  final String lastMessage;
  final DateTime lastMessageTime;

  ChatPreview({
    required this.chatId,
    required this.userId,
    required this.username,
    required this.lastMessage,
    required this.lastMessageTime,
  });
}