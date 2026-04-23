import 'package:flutter_test/flutter_test.dart';
import 'package:telepatient_app/models/chat_message_model.dart';

void main() {
  group('ChatMessageModel.fromJson', () {
    test('parses a standard message', () {
      final json = {
        'id': 1,
        'senderId': 10,
        'senderName': 'Dr. Smith',
        'message': 'Hello, how are you?',
        'sentAt': '2025-01-15T10:00:00',
      };

      final msg = ChatMessageModel.fromJson(json);

      expect(msg.id, 1);
      expect(msg.senderId, 10);
      expect(msg.senderName, 'Dr. Smith');
      expect(msg.message, 'Hello, how are you?');
      expect(msg.sentAt, '2025-01-15T10:00:00');
    });

    test('handles missing sentAt gracefully', () {
      final json = {
        'id': 2,
        'senderId': 5,
        'senderName': 'Jane',
        'message': 'Test',
      };

      final msg = ChatMessageModel.fromJson(json);
      expect(msg.sentAt, isNull);
    });
  });

  group('ChatSyncResponse.fromJson', () {
    test('parses active session with messages', () {
      final json = {
        'terminated': false,
        'messages': [
          {
            'id': 1,
            'senderId': 10,
            'senderName': 'Dr. Smith',
            'message': 'Hello',
            'sentAt': '2025-01-15T10:00:00',
          },
          {
            'id': 2,
            'senderId': 1,
            'senderName': 'Jane Doe',
            'message': 'Hi doctor',
            'sentAt': '2025-01-15T10:01:00',
          },
        ],
      };

      final sync = ChatSyncResponse.fromJson(json);

      expect(sync.isTerminated, false);
      expect(sync.messages.length, 2);
      expect(sync.messages[0].senderName, 'Dr. Smith');
      expect(sync.messages[1].message, 'Hi doctor');
    });

    test('parses terminated session with empty messages', () {
      final json = {
        'terminated': true,
        'messages': [],
      };

      final sync = ChatSyncResponse.fromJson(json);

      expect(sync.isTerminated, true);
      expect(sync.messages, isEmpty);
    });

    test('handles isTerminated field name variant', () {
      final json = {
        'isTerminated': true,
        'messages': [],
      };

      final sync = ChatSyncResponse.fromJson(json);
      expect(sync.isTerminated, true);
    });
  });
}
