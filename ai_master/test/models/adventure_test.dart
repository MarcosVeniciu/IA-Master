import 'dart:convert'; // Importar para jsonEncode
import 'package:test/test.dart';
import 'package:ai_master/models/adventure.dart';
// Importar ChatMessage se necessário para testes futuros de 'messages'
// import 'package:ai_master/models/chat_message.dart';

void main() {
  group('Adventure Class Tests (Freezed)', () {
    // Dados de exemplo para os testes
    final testId = 'adv_002';
    final testScenarioTitle = 'Cavernas de Cristal';
    final double testProgressIndicator =
        0.5; // Removido '?' - inicializado com não nulo
    // gameState agora é uma string JSON
    final testGameStateMap = {
      'level': 2,
      'xp': 150,
      'items': ['crystal_shard'],
    };
    final testGameStateJson = jsonEncode(testGameStateMap);
    // lastPlayedDate agora é um int (timestamp)
    final testLastPlayedDateTime = DateTime(2025, 4, 26);
    final testLastPlayedTimestamp =
        testLastPlayedDateTime.millisecondsSinceEpoch;

    // Cria uma instância de Adventure para os testes
    final adventure = Adventure(
      id: testId,
      scenarioTitle: testScenarioTitle, // Renomeado
      progressIndicator: testProgressIndicator, // Renomeado
      gameState: testGameStateJson, // Renomeado
      lastPlayedDate: testLastPlayedTimestamp, // Renomeado
      // syncStatus usa o valor padrão (0)
      // messages usa o valor padrão ([])
    );

    test(
      'Constructor should create an Adventure object with correct values',
      () {
        expect(adventure.id, equals(testId));
        expect(adventure.scenarioTitle, equals(testScenarioTitle)); // Renomeado
        expect(
          adventure.progressIndicator,
          equals(testProgressIndicator),
        ); // Renomeado
        expect(adventure.gameState, equals(testGameStateJson)); // Renomeado
        expect(
          adventure.lastPlayedDate,
          equals(testLastPlayedTimestamp),
        ); // Renomeado
        // Verifica os valores padrão
        expect(adventure.syncStatus, equals(0)); // Renomeado
        expect(
          adventure.messages,
          isEmpty,
        ); // messages é uma lista vazia por padrão
      },
    );

    test('fromJson/toJson should work correctly', () {
      // Cria um mapa JSON simulando o que viria de uma API ou DB
      final jsonMap = {
        'id': testId,
        'scenario_title': testScenarioTitle, // Mantém snake_case no JSON
        'progress_indicator':
            testProgressIndicator, // Mantém snake_case no JSON
        'game_state': testGameStateJson, // Mantém snake_case no JSON
        'last_played_date':
            testLastPlayedTimestamp, // Mantém snake_case no JSON
        'sync_status': 1, // Mantém snake_case no JSON
        // 'messages' não é incluído no JSON por padrão
      };

      // Testa fromJson
      final adventureFromJson = Adventure.fromJson(jsonMap);
      expect(adventureFromJson.id, equals(testId));
      expect(
        adventureFromJson.scenarioTitle,
        equals(testScenarioTitle),
      ); // Renomeado
      expect(
        adventureFromJson.progressIndicator, // Renomeado
        equals(testProgressIndicator),
      );
      expect(
        adventureFromJson.gameState,
        equals(testGameStateJson),
      ); // Renomeado
      expect(
        adventureFromJson.lastPlayedDate, // Renomeado
        equals(testLastPlayedTimestamp),
      );
      expect(adventureFromJson.syncStatus, equals(1)); // Renomeado
      expect(
        adventureFromJson.messages,
        isEmpty,
      ); // messages ainda deve ser vazio

      // Testa toJson
      final adventureToJsonMap = adventureFromJson.toJson();
      expect(adventureToJsonMap, equals(jsonMap));
    });

    test('fromMap/toMap should work correctly for SQFlite', () {
      // Cria um mapa simulando o que viria do SQFlite
      final dbMap = {
        'id': testId,
        'scenario_title': testScenarioTitle, // Mantém snake_case no DB map
        'progress_indicator':
            testProgressIndicator, // Mantém snake_case no DB map
        'game_state': testGameStateJson, // Mantém snake_case no DB map
        'last_played_date':
            testLastPlayedTimestamp, // Mantém snake_case no DB map
        'sync_status': 2, // Mantém snake_case no DB map
      };

      // Testa fromMap
      final adventureFromMap = Adventure.fromMap(dbMap);
      expect(adventureFromMap.id, equals(testId));
      expect(
        adventureFromMap.scenarioTitle,
        equals(testScenarioTitle),
      ); // Renomeado
      expect(
        adventureFromMap.progressIndicator, // Renomeado
        equals(testProgressIndicator),
      );
      expect(
        adventureFromMap.gameState,
        equals(testGameStateJson),
      ); // Renomeado
      expect(
        adventureFromMap.lastPlayedDate, // Renomeado
        equals(testLastPlayedTimestamp),
      );
      expect(adventureFromMap.syncStatus, equals(2)); // Renomeado
      expect(adventureFromMap.messages, isEmpty);

      // Testa toMap (que internamente chama toJson)
      final adventureToMapResult = adventureFromMap.toMap();
      expect(adventureToMapResult, equals(dbMap));
    });

    // Os testes para loadState e saveState foram removidos pois os métodos não existem mais.
  });
}
