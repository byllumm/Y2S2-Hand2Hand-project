class ChatPreview {
  final int itemId;
  final String itemName;
  final int otherUserId;
  final String otherUsername;
  final String? itemImage;
  final String lastMessage;
  final DateTime lastMessageTime;

  ChatPreview({
    required this.itemId,
    required this.itemName,
    required this.otherUserId,
    required this.otherUsername,
    this.itemImage,
    required this.lastMessage,
    required this.lastMessageTime,
  });
}