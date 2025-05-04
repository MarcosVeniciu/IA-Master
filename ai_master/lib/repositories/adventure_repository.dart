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
    final db = await _dbHelper.database;
    await db.insert(
      'Adventure',
      adventure.toMap(),
      conflictAlgorithm:
          ConflictAlgorithm.replace, // Substitui se já existir ID
    );
  }

  /// Atualiza uma [Adventure] existente no banco de dados.
  ///
  /// - [adventure]: A aventura com os dados atualizados.
  /// Retorna uma [Future] que completa quando a operação é concluída.
  Future<void> updateAdventure(Adventure adventure) async {
    final db = await _dbHelper.database;
    await db.update(
      'Adventure',
      adventure.toMap(),
      where: 'id = ?',
      whereArgs: [adventure.id],
    );
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
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Adventure',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1, // Espera-se apenas um resultado
    );

    if (maps.isNotEmpty) {
      return Adventure.fromMap(maps.first);
    } else {
      return null;
    }
  }

  /// Retorna uma lista de todas as [Adventure] salvas no banco de dados.
  ///
  /// As aventuras são ordenadas pela data mais recente (`last_played_date`).
  /// As mensagens ([ChatMessage]) não são carregadas por este método.
  ///
  /// Retorna uma [Future] que completa com a lista de [Adventure].
  Future<List<Adventure>> getAllAdventures() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Adventure',
      orderBy: 'last_played_date DESC', // Ordena pela data mais recente
    );

    return List.generate(maps.length, (i) {
      return Adventure.fromMap(maps[i]);
    });
  }

  /// Deleta uma [Adventure] e todas as suas [ChatMessage] associadas do banco de dados.
  ///
  /// A exclusão das mensagens é feita automaticamente pelo banco de dados
  /// devido à restrição `FOREIGN KEY (adventure_id) REFERENCES Adventure(id) ON DELETE CASCADE`.
  ///
  /// - [id]: O ID da aventura a ser deletada.
  /// Retorna uma [Future] que completa quando a operação é concluída.
  Future<void> deleteAdventure(String id) async {
    final db = await _dbHelper.database;
    await db.delete('Adventure', where: 'id = ?', whereArgs: [id]);
  }

  // --- Operações para ChatMessage ---

  /// Salva uma nova [ChatMessage] no banco de dados.
  ///
  /// - [message]: A mensagem a ser salva.
  /// Retorna uma [Future] que completa quando a operação é concluída.
  Future<void> saveChatMessage(ChatMessage message) async {
    final db = await _dbHelper.database;
    await db.insert(
      'ChatMessage',
      message.toMap(),
      conflictAlgorithm:
          ConflictAlgorithm.replace, // Substitui se já existir ID
    );
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
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ChatMessage',
      where: 'adventure_id = ?',
      whereArgs: [adventureId],
      orderBy: 'timestamp ASC', // Ordena cronologicamente
    );

    return List.generate(maps.length, (i) {
      return ChatMessage.fromMap(maps[i]);
    });
  }

  // --- Operações Combinadas ---

  /// Busca uma [Adventure] completa pelo seu ID, incluindo sua lista de [ChatMessage].
  ///
  /// - [id]: O ID da aventura a ser buscada.
  /// Retorna uma [Future] que completa com a [Adventure] completa (com mensagens)
  /// ou `null` se nenhuma aventura com o ID fornecido for encontrada.
  Future<Adventure?> getFullAdventure(String id) async {
    final adventure = await getAdventure(id);
    if (adventure != null) {
      final messages = await getChatMessagesForAdventure(id);
      // Usa copyWith (gerado pelo freezed) para criar uma nova instância
      // com a lista de mensagens preenchida.
      return adventure.copyWith(messages: messages);
    } else {
      return null;
    }
  }
}
