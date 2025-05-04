import 'package:test/test.dart';
import 'package:ai_master/models/chat_message.dart';

void main() {
  group('ChatMessage Class Tests', () {
    final testId = 'msg_001';
    final testAdventureId = 'adv_001';
    final testSender = 'user';
    final testContent = 'Explorar a caverna';
    final testTimestamp = DateTime(2025, 4, 26, 15, 30).millisecondsSinceEpoch;

    test('Should create valid ChatMessage from JSON', () {
      final jsonMap = {
        'id': testId,
        'adventureId': testAdventureId,
        'sender': testSender,
        'content': testContent,
        'timestamp': testTimestamp,
      };

      final message = ChatMessage.fromJson(jsonMap);

      expect(message.id, testId);
      expect(message.adventureId, testAdventureId);
      expect(message.sender, testSender);
      expect(message.content, testContent);
      expect(message.timestamp, testTimestamp);
    });

    test('Should convert to JSON correctly', () {
      final message = ChatMessage(
        id: testId,
        adventureId: testAdventureId,
        sender: testSender,
        content: testContent,
        timestamp: testTimestamp,
      );

      final jsonMap = message.toJson();

      expect(jsonMap['id'], testId);
      expect(jsonMap['adventureId'], testAdventureId);
      expect(jsonMap['sender'], testSender);
      expect(jsonMap['content'], testContent);
      expect(jsonMap['timestamp'], testTimestamp);
    });

    test('Should handle database mapping correctly', () {
      final dbMap = {
        'id': testId,
        'adventureId': testAdventureId,
        'sender': testSender,
        'content': testContent,
        'timestamp': testTimestamp,
        'syncStatus':
            0, // Adiciona o campo syncStatus esperado do fromMap/toMap
      };

      final messageFromMap = ChatMessage.fromMap(dbMap);
      final messageToMap = messageFromMap.toMap();

      expect(messageToMap, equals(dbMap));
    });
  });
}
