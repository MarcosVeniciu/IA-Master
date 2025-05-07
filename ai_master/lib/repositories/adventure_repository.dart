import 'dart:async';
// import 'dart:convert'; // Removido - não utilizado

import 'package:ai_master/models/adventure.dart';
import 'package:ai_master/models/chat_message.dart';
import 'package:ai_master/services/database_helper.dart';
import 'package:sqflite/sqflite.dart';

/// {@template adventure_repository}
/// Repositório para gerenciar a persistência de dados das entidades
/// [Adventure] e [ChatMessage] usando SQFlite.
///
/// Atua como uma fachada para abstrair as operações de banco de dados
/// das outras camadas da aplicação.
/// {@endtemplate}
class AdventureRepository {
  /// Instância do helper do banco de dados.
  final DatabaseHelper _dbHelper;

  /// {@macro adventure_repository}
  ///
  /// Recebe uma instância de [DatabaseHelper]. Se nenhuma for fornecida,
  /// utiliza a instância singleton padrão.
  AdventureRepository({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  // --- Operações CRUD para Adventure ---

  /// Salva uma nova [Adventure] no banco de dados.
  ///
  /// - [adventure]: A aventura a ser salva.
  /// Retorna uma [Future] que completa quando a operação é concluída.
  Future<void> saveAdventure(Adventure adventure) async {
    print('[REPO] Iniciando saveAdventure para ID: ${adventure.id}');
    try {
      final db = await _dbHelper.database;
      print(
        '[REPO] saveAdventure: Obtido DB. Inserindo/Substituindo Adventure...',
      );
      await db.insert(
        'Adventure',
        adventure.toMap(),
        conflictAlgorithm:
            ConflictAlgorithm.replace, // Substitui se já existir ID
      );
      print(
        '[REPO] saveAdventure concluído com sucesso para ID: ${adventure.id}',
      );
    } catch (e) {
      print('[REPO] ERRO em saveAdventure (ID: ${adventure.id}): $e');
      rethrow;
    }
  }

  /// Atualiza uma [Adventure] existente no banco de dados.
  ///
  /// - [adventure]: A aventura com os dados atualizados.
  /// Retorna uma [Future] que completa quando a operação é concluída.
  Future<void> updateAdventure(Adventure adventure) async {
    print('[REPO] Iniciando updateAdventure para ID: ${adventure.id}');
    try {
      final db = await _dbHelper.database;
      print('[REPO] updateAdventure: Obtido DB. Atualizando Adventure...');
      await db.update(
        'Adventure',
        adventure.toMap(),
        where: 'id = ?',
        whereArgs: [adventure.id],
      );
      print(
        '[REPO] updateAdventure concluído com sucesso para ID: ${adventure.id}',
      );
    } catch (e) {
      print('[REPO] ERRO em updateAdventure (ID: ${adventure.id}): $e');
      rethrow;
    }
  }

  /// Busca uma [Adventure] pelo seu ID.
  ///
  /// Note que este método **não** carrega a lista de [ChatMessage] associada.
  /// Use [getFullAdventure] para carregar a aventura completa.
  ///
  /// - [id]: O ID da aventura a ser buscada.
  /// Retorna uma [Future] que completa com a [Adventure] encontrada ou `null`
  /// se nenhuma aventura com o ID fornecido for encontrada.
  Future<Adventure?> getAdventure(String id) async {
    print('[REPO] Iniciando getAdventure para ID: $id');
    try {
      final db = await _dbHelper.database;
      print('[REPO] getAdventure: Obtido DB. Consultando Adventure...');
      final List<Map<String, dynamic>> maps = await db.query(
        'Adventure',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1, // Espera-se apenas um resultado
      );
      print(
        '[REPO] getAdventure: Consulta concluída. ${maps.length} registro(s) encontrado(s).',
      );

      if (maps.isNotEmpty) {
        final adventure = Adventure.fromMap(maps.first);
        print('[REPO] getAdventure: Aventura encontrada e mapeada (ID: $id).');
        return adventure;
      } else {
        print('[REPO] getAdventure: Nenhuma aventura encontrada com ID: $id.');
        return null;
      }
    } catch (e) {
      print('[REPO] ERRO em getAdventure (ID: $id): $e');
      rethrow;
    }
  }

  /// Retorna uma lista de todas as [Adventure] salvas no banco de dados.
  ///
  /// As aventuras são ordenadas pela data mais recente (`last_played_date`).
  /// As mensagens ([ChatMessage]) não são carregadas por este método.
  ///
  /// Retorna uma [Future] que completa com a lista de [Adventure].
  Future<List<Adventure>> getAllAdventures() async {
    print('[REPO] Iniciando getAllAdventures...');
    try {
      final db = await _dbHelper.database;
      print(
        '[REPO] getAllAdventures: Obtido DB. Consultando todas as Adventures...',
      );
      final List<Map<String, dynamic>> maps = await db.query(
        'Adventure',
        orderBy: 'last_played_date DESC', // Ordena pela data mais recente
      );
      print(
        '[REPO] getAllAdventures: Consulta concluída. ${maps.length} registro(s) encontrado(s).',
      );

      final adventures = List.generate(maps.length, (i) {
        return Adventure.fromMap(maps[i]);
      });
      print(
        '[REPO] getAllAdventures: Mapeamento concluído. Retornando ${adventures.length} aventura(s).',
      );
      return adventures;
    } catch (e) {
      print('[REPO] ERRO em getAllAdventures: $e');
      rethrow;
    }
  }

  /// Deleta uma [Adventure] e todas as suas [ChatMessage] associadas do banco de dados.
  ///
  /// A exclusão das mensagens é feita automaticamente pelo banco de dados
  /// devido à restrição `FOREIGN KEY (adventure_id) REFERENCES Adventure(id) ON DELETE CASCADE`.
  ///
  /// - [id]: O ID da aventura a ser deletada.
  /// Retorna uma [Future] que completa quando a operação é concluída.
  Future<void> deleteAdventure(String id) async {
    print('[REPO] Iniciando deleteAdventure para ID: $id');
    try {
      final db = await _dbHelper.database;
      print('[REPO] deleteAdventure: Obtido DB. Deletando Adventure...');
      await db.delete('Adventure', where: 'id = ?', whereArgs: [id]);
      print('[REPO] deleteAdventure concluído com sucesso para ID: $id.');
    } catch (e) {
      print('[REPO] ERRO em deleteAdventure (ID: $id): $e');
      rethrow;
    }
  }

  // --- Operações para ChatMessage ---

  /// Salva uma nova [ChatMessage] no banco de dados.
  ///
  /// - [message]: A mensagem a ser salva.
  /// Retorna uma [Future] que completa quando a operação é concluída.
  Future<void> saveChatMessage(ChatMessage message) async {
    print(
      '[REPO] Iniciando saveChatMessage para ID: ${message.id} (Adventure ID: ${message.adventureId})',
    );
    try {
      final db = await _dbHelper.database;
      print(
        '[REPO] saveChatMessage: Obtido DB. Inserindo/Substituindo ChatMessage...',
      );
      await db.insert(
        'ChatMessage',
        message.toMap(),
        conflictAlgorithm:
            ConflictAlgorithm.replace, // Substitui se já existir ID
      );
      print(
        '[REPO] saveChatMessage concluído com sucesso para ID: ${message.id}',
      );
    } catch (e) {
      print('[REPO] ERRO em saveChatMessage (ID: ${message.id}): $e');
      rethrow;
    }
  }

  /// Busca todas as [ChatMessage] associadas a uma [Adventure] específica.
  ///
  /// As mensagens são ordenadas pelo timestamp em ordem crescente (mais antigas primeiro).
  ///
  /// - [adventureId]: O ID da aventura cujas mensagens devem ser buscadas.
  /// Retorna uma [Future] que completa com a lista de [ChatMessage].
  Future<List<ChatMessage>> getChatMessagesForAdventure(
    String adventureId,
  ) async {
    print(
      '[REPO] Iniciando getChatMessagesForAdventure para Adventure ID: $adventureId',
    );
    try {
      final db = await _dbHelper.database;
      print('[REPO] getChatMessages: Obtido DB. Consultando ChatMessages...');
      final List<Map<String, dynamic>> maps = await db.query(
        'ChatMessage',
        where: 'adventure_id = ?',
        whereArgs: [adventureId],
        orderBy: 'timestamp ASC', // Ordena cronologicamente
      );
      print(
        '[REPO] getChatMessages: Consulta concluída. ${maps.length} registro(s) encontrado(s).',
      );

      final messages = List.generate(maps.length, (i) {
        return ChatMessage.fromMap(maps[i]);
      });
      print(
        '[REPO] getChatMessages: Mapeamento concluído. Retornando ${messages.length} mensagem(ns).',
      );
      return messages;
    } catch (e) {
      print(
        '[REPO] ERRO em getChatMessagesForAdventure (Adventure ID: $adventureId): $e',
      );
      rethrow;
    }
  }

  // --- Operações Combinadas ---

  /// Busca uma [Adventure] completa pelo seu ID, incluindo sua lista de [ChatMessage].
  ///
  /// - [id]: O ID da aventura a ser buscada.
  /// Retorna uma [Future] que completa com a [Adventure] completa (com mensagens)
  /// ou `null` se nenhuma aventura com o ID fornecido for encontrada.
  Future<Adventure?> getFullAdventure(String id) async {
    print('[REPO] Iniciando getFullAdventure para ID: $id');
    try {
      final adventure = await getAdventure(id); // Já tem logs internos
      if (adventure != null) {
        print(
          '[REPO] getFullAdventure: Aventura base encontrada. Buscando mensagens...',
        );
        final messages = await getChatMessagesForAdventure(
          id,
        ); // Já tem logs internos
        print(
          '[REPO] getFullAdventure: Mensagens encontradas (${messages.length}). Combinando...',
        );
        // Usa copyWith (gerado pelo freezed) para criar uma nova instância
        // com a lista de mensagens preenchida.
        final fullAdventure = adventure.copyWith(messages: messages);
        print('[REPO] getFullAdventure concluído com sucesso para ID: $id.');
        return fullAdventure;
      } else {
        print(
          '[REPO] getFullAdventure: Aventura base não encontrada com ID: $id. Retornando null.',
        );
        return null;
      }
    } catch (e) {
      print('[REPO] ERRO em getFullAdventure (ID: $id): $e');
      rethrow;
    }
  }
}
