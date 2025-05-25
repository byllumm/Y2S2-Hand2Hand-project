import 'package:flutter_test/flutter_test.dart';
import 'package:hand2hand/message.dart';

void main() {
  group('Message', () {
    final message = Message(
      id: 1,
      senderId: 101,
      receiverId: 202,
      itemId: 303,
      content: 'Hello!',
      createdAt: DateTime.parse('2023-10-01T12:34:56.000Z'),
    );

    test('toMap returns correct map', () {
      final map = message.toMap();

      expect(map['sender_id'], 101);
      expect(map['receiver_id'], 202);
      expect(map['item_id'], 303);
      expect(map['content'], 'Hello!');
      expect(map['created_at'], '2023-10-01T12:34:56.000Z');
      expect(map.containsKey('id'), isFalse); // id is excluded
    });

    test('fromMap returns correct Message object', () {
      final map = {
        'id': 1,
        'sender_id': 101,
        'receiver_id': 202,
        'item_id': 303,
        'content': 'Hello!',
        'created_at': '2023-10-01T12:34:56.000Z',
      };

      final msg = Message.fromMap(map);

      expect(msg.id, 1);
      expect(msg.senderId, 101);
      expect(msg.receiverId, 202);
      expect(msg.itemId, 303);
      expect(msg.content, 'Hello!');
      expect(msg.createdAt, DateTime.parse('2023-10-01T12:34:56.000Z'));
    });

    test('toMap and fromMap produce identical object', () {
      final map = message.toMap();
      final recreated = Message.fromMap({'id': message.id, ...map});

      expect(recreated.id, message.id);
      expect(recreated.senderId, message.senderId);
      expect(recreated.receiverId, message.receiverId);
      expect(recreated.itemId, message.itemId);
      expect(recreated.content, message.content);
      expect(recreated.createdAt.toIso8601String(), message.createdAt.toIso8601String());
    });
  });
}
