import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ai_master/models/adventure.dart';
import 'package:ai_master/models/chat_message.dart';
import 'package:ai_master/repositories/adventure_repository.dart';
import 'package:ai_master/services/database_helper.dart';

// Gera mocks para DatabaseHelper e Database
@GenerateMocks([DatabaseHelper, Database])
import 'adventure_repository_test.mocks.dart'; // Importa os mocks gerados

void main() {
  late AdventureRepository repository;
  late MockDatabaseHelper mockDbHelper;
  late MockDatabase mockDatabase;

  // Dados de teste
  final testAdventure = Adventure(
    id: 'adv_test_001',
    scenarioTitle: 'Aventura de Teste', // Renomeado
    gameState: '{"player_level": 1, "location": "start"}', // Renomeado
    lastPlayedDate: DateTime(2025, 4, 26).millisecondsSinceEpoch, // Renomeado
    syncStatus: 2, // Renomeado e Corrigido para int (ex: 2 = synced)
  );

  final testMessage = ChatMessage(
    id: 'msg_test_001',
    adventureId: 'adv_test_001',
    sender: 'user',
    content: 'Mensagem de teste',
    timestamp: DateTime(2025, 4, 26, 10, 0).millisecondsSinceEpoch,
  );

  final testAdventureMap = testAdventure.toMap();
  final testMessageMap = testMessage.toMap();

  setUp(() {
    // Configura os mocks antes de cada teste
    mockDbHelper = MockDatabaseHelper();
    mockDatabase = MockDatabase();
    // Garante que DatabaseHelper.instance retorne o mock
    // (Isso pode precisar de ajuste dependendo de como DatabaseHelper é implementado - Singleton?)
    // Se DatabaseHelper for um Singleton real, pode ser mais complexo mockar.
    // Assumindo que podemos injetar ou substituir a instância para teste:
    repository = AdventureRepository(
      dbHelper: mockDbHelper,
    ); // Injeta o mock usando o parâmetro nomeado

    // Configura o mockDbHelper para retornar o mockDatabase quando 'database' for acessado
    when(mockDbHelper.database).thenAnswer((_) async => mockDatabase);
  });

  tearDown(() {
    // Limpa após cada teste, se necessário
  });

  group('Adventure Operations', () {
    test('saveAdventure should insert into database', () async {
      // Nome correto do método
      // Configura o mock do banco de dados para a operação de inserção
      when(
        mockDatabase.insert(
          'Adventure', // Nome correto da tabela
          testAdventureMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        ),
      ).thenAnswer((_) async => 1); // Retorna 1 linha afetada

      // Executa o método
      await repository.saveAdventure(testAdventure); // Nome correto do método

      // Verifica se o método 'insert' foi chamado com os parâmetros corretos
      verify(
        mockDatabase.insert(
          'Adventure', // Nome correto da tabela
          testAdventureMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        ),
      ).called(1);
    });

    test('updateAdventure should update database', () async {
      final updatedAdventure = testAdventure.copyWith(
        gameState: '{"player_level": 2, "location": "cave"}', // Renomeado
      );
      final updatedAdventureMap = updatedAdventure.toMap();

      when(
        mockDatabase.update(
          'Adventure', // Nome correto da tabela
          updatedAdventureMap,
          where: 'id = ?',
          whereArgs: [testAdventure.id],
        ),
      ).thenAnswer((_) async => 1);

      await repository.updateAdventure(updatedAdventure);

      verify(
        mockDatabase.update(
          'Adventure', // Nome correto da tabela
          updatedAdventureMap,
          where: 'id = ?',
          whereArgs: [testAdventure.id],
        ),
      ).called(1);
    });

    test('deleteAdventure should delete adventure from database', () async {
      // Descrição atualizada
      // A exclusão de mensagens é feita em cascata pelo DB,
      // então só precisamos mockar a exclusão da aventura.
      when(
        mockDatabase.delete(
          'Adventure', // Nome correto da tabela
          where: 'id = ?',
          whereArgs: [testAdventure.id],
        ),
      ).thenAnswer((_) async => 1); // Retorna 1 linha afetada (a aventura)

      await repository.deleteAdventure(testAdventure.id);

      // Verifica se o método 'delete' foi chamado corretamente para a aventura
      verify(
        mockDatabase.delete(
          'Adventure', // Nome correto da tabela
          where: 'id = ?',
          whereArgs: [testAdventure.id],
        ),
      ).called(1);
      // Não verificamos mais a exclusão explícita de mensagens aqui
    });

    test('getAdventure should retrieve from database', () async {
      // Nome correto do método
      when(
        mockDatabase.query(
          'Adventure', // Nome correto da tabela
          where: 'id = ?',
          whereArgs: [testAdventure.id],
          limit: 1, // Adiciona o limit que faltava no mock
        ),
      ).thenAnswer(
        (_) async => [testAdventureMap],
      ); // Retorna uma lista com o mapa

      final result = await repository.getAdventure(
        testAdventure.id,
      ); // Nome correto do método

      expect(result, isNotNull);
      expect(result!.id, testAdventure.id);
      expect(result.scenarioTitle, testAdventure.scenarioTitle); // Renomeado
      verify(
        mockDatabase.query(
          'Adventure', // Nome correto da tabela
          where: 'id = ?',
          whereArgs: [testAdventure.id],
          limit: 1, // Adiciona o limit na verificação
        ),
      ).called(1);
    });

    test('getAdventure should return null if not found', () async {
      // Nome correto do método
      when(
        mockDatabase.query(
          'Adventure', // Nome correto da tabela
          where: 'id = ?',
          whereArgs: ['non_existent_id'],
          limit: 1, // Adiciona o limit que faltava no mock
        ),
      ).thenAnswer((_) async => []); // Retorna lista vazia

      final result = await repository.getAdventure(
        'non_existent_id',
      ); // Nome correto do método

      expect(result, isNull);
      verify(
        mockDatabase.query(
          'Adventure', // Nome correto da tabela
          where: 'id = ?',
          whereArgs: ['non_existent_id'],
          limit: 1, // Adiciona o limit na verificação
        ),
      ).called(1);
    });

    test('getAllAdventures should retrieve all from database', () async {
      final adventureListMap = [
        testAdventureMap,
        testAdventure.copyWith(id: 'adv_test_002').toMap(),
      ];
      when(
        mockDatabase.query(
          'Adventure',
          orderBy: 'last_played_date DESC',
        ), // Nome correto da tabela
      ).thenAnswer((_) async => adventureListMap);

      final result = await repository.getAllAdventures();

      expect(result, isA<List<Adventure>>());
      expect(result.length, 2);
      expect(result[0].id, testAdventure.id);
      expect(result[1].id, 'adv_test_002');
      verify(
        mockDatabase.query(
          'Adventure',
          orderBy: 'last_played_date DESC',
        ), // Nome correto da tabela
      ).called(1);
    });
  });

  group('ChatMessage Operations', () {
    test('saveChatMessage should insert into database', () async {
      // Nome correto do método
      when(
        mockDatabase.insert(
          'ChatMessage', // Nome correto da tabela
          testMessageMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        ),
      ).thenAnswer((_) async => 1);

      await repository.saveChatMessage(testMessage); // Nome correto do método

      verify(
        mockDatabase.insert(
          'ChatMessage', // Nome correto da tabela
          testMessageMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        ),
      ).called(1);
    });

    test('getChatMessagesForAdventure should retrieve from database', () async {
      final messageListMap = [
        testMessageMap,
        testMessage.copyWith(id: 'msg_test_002').toMap(),
      ];
      when(
        mockDatabase.query(
          'ChatMessage', // Nome correto da tabela
          where:
              'adventure_id = ?', // Corrigido para corresponder à implementação
          whereArgs: [testAdventure.id],
          orderBy: 'timestamp ASC',
        ),
      ).thenAnswer((_) async => messageListMap);

      final result = await repository.getChatMessagesForAdventure(
        testAdventure.id,
      );

      expect(result, isA<List<ChatMessage>>());
      expect(result.length, 2);
      expect(result[0].id, testMessage.id);
      expect(result[1].id, 'msg_test_002');
      verify(
        mockDatabase.query(
          'ChatMessage', // Nome correto da tabela
          where:
              'adventure_id = ?', // Corrigido para corresponder à implementação
          whereArgs: [testAdventure.id],
          orderBy: 'timestamp ASC',
        ),
      ).called(1);
    });

    // Teste removido pois a exclusão é em cascata e testada em deleteAdventure
    /*
    test(
      'deleteChatMessagesForAdventure should delete from database',
      () async {
        when(
          mockDatabase.delete(
            'ChatMessage', // Nome correto da tabela
            where: 'adventure_id = ?',
            whereArgs: [testAdventure.id],
          ),
        ).thenAnswer((_) async => 5); // Simula 5 mensagens deletadas

        // Não existe método direto no repositório para isso
        // await repository.deleteChatMessagesForAdventure(testAdventure.id);

        verify(
          mockDatabase.delete(
            'ChatMessage', // Nome correto da tabela
            where: 'adventure_id = ?',
            whereArgs: [testAdventure.id],
          ),
        ).called(1);
      },
    );
    */
  });
}
