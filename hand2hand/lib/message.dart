class Message {
  final int? id;
  final int senderId;
  final int receiverId;
  final int itemId;
  final String content;
  final DateTime createdAt;

  Message({
    this.id,
    required this.senderId,
    required this.receiverId,
    required this.itemId,
    required this.content,
    required this.createdAt,
});

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'item_id': itemId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Message.fromMap(Map<String, dynamic> data) {
    return Message(
      id: data['id'],
      senderId: data['sender-id'],
      receiverId: data['receiver-id'],
      itemId: data['item_id'],
      content: data['content'],
      createdAt: DateTime.parse(data['created_at']),
    );
  }
}