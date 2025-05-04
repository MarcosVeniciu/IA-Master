import 'dart:async';
// Removido: import 'dart:io'; (não utilizado)

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// {@template database_helper}
/// Uma classe Singleton responsável por gerenciar o ciclo de vida do banco de dados SQFlite.
///
/// Garante que apenas uma instância do banco de dados seja aberta durante a
/// execução do aplicativo e fornece métodos para inicializar e acessar o banco.
/// {@endtemplate}
class DatabaseHelper {
  /// A instância única (Singleton) da classe [DatabaseHelper].
  static final DatabaseHelper instance = DatabaseHelper._init();

  /// A instância privada do banco de dados SQFlite.
  /// Pode ser nula até que o banco de dados seja inicializado.
  static Database? _database;

  /// O nome do arquivo do banco de dados.
  static const String _dbName = 'ai_master_database.db';

  /// A versão atual do schema do banco de dados.
  /// Incrementar este número acionará o método `_onUpgrade` ou `_onDowngrade`.
  static const int _dbVersion =
      2; // Incrementado para refletir mudança no schema

  /// Construtor privado usado internamente para criar a instância Singleton.
  DatabaseHelper._init();

  /// Retorna a instância do banco de dados SQFlite.
  ///
  /// Se o banco de dados ainda não foi inicializado, este getter chama [_initDb]
  /// para criá-lo e abri-lo. Caso contrário, retorna a instância existente.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  /// Inicializa o banco de dados SQFlite.
  ///
  /// Determina o caminho do banco de dados no sistema de arquivos do dispositivo
  /// e abre a conexão. Se o banco de dados não existir, ele será criado
  /// chamando o método [_onCreate].
  ///
  /// Retorna uma [Future] que completa com a instância do [Database].
  Future<Database> _initDb() async {
    try {
      final String documentsDirectory = await getDatabasesPath();
      final String path = join(documentsDirectory, _dbName);

      return await openDatabase(
        path,
        version: _dbVersion,
        onCreate: _onCreate,
        // onUpgrade: _onUpgrade, // Descomentar e implementar se houver futuras migrações
        // onDowngrade: onDatabaseDowngradeDelete, // Estratégia para downgrade
      );
    } catch (e) {
      // Removido stackTrace não utilizado
      // TODO: Implementar um mecanismo de log mais robusto
      // print('Erro ao inicializar o banco de dados: $e'); // Removido - usar logger
      // Relançar a exceção para que o chamador saiba da falha
      rethrow;
    }
  }

  /// Chamado quando o banco de dados é criado pela primeira vez.
  ///
  /// Executa as instruções SQL para criar as tabelas `Adventure` e `ChatMessage`,
  /// bem como seus índices correspondentes, conforme definido no schema.
  ///
  /// - [db]: A instância do banco de dados sendo criada.
  /// - [version]: A versão do banco de dados que está sendo criada.
  Future<void> _onCreate(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE Adventure (
            id TEXT PRIMARY KEY NOT NULL,       -- UUID da aventura
            scenario_title TEXT NOT NULL,       -- Título do cenário base
            progress_indicator REAL,            -- Progresso numérico (0.0 a 1.0)
            game_state TEXT NOT NULL,           -- Estado do jogo serializado em JSON
            last_played_date INTEGER NOT NULL,  -- Timestamp da última interação (millisecondsSinceEpoch)
            sync_status INTEGER NOT NULL DEFAULT 0 -- Status de sincronização (0=local, 1=syncing, 2=synced, -1=error)
        );
      ''');

      await db.execute('''
        CREATE INDEX idx_adventure_last_played ON Adventure(last_played_date DESC);
      ''');

      await db.execute('''
        CREATE TABLE ChatMessage (
            id TEXT PRIMARY KEY NOT NULL,           -- UUID da mensagem
            adventure_id TEXT NOT NULL,             -- FK para Adventure.id
            sender TEXT NOT NULL,                   -- 'player', 'ai', 'system'
            content TEXT NOT NULL,                  -- Conteúdo da mensagem
            timestamp INTEGER NOT NULL,             -- Timestamp da mensagem (millisecondsSinceEpoch)
            sync_status INTEGER NOT NULL DEFAULT 0, -- Status de sincronização (0=local)
            FOREIGN KEY (adventure_id) REFERENCES Adventure(id) ON DELETE CASCADE -- Garante integridade referencial
        );
      ''');

      await db.execute('''
        CREATE INDEX idx_chatmessage_adventure_timestamp ON ChatMessage(adventure_id, timestamp ASC);
      ''');
    } catch (e) {
      // Removido stackTrace não utilizado
      // TODO: Implementar um mecanismo de log mais robusto
      // print('Erro ao criar tabelas do banco de dados: $e'); // Removido - usar logger
      // Relançar a exceção para que o chamador (openDatabase) saiba da falha
      rethrow;
    }
  }

  // --- Métodos de Migração (Exemplo - Implementar se necessário) ---

  // /// Chamado quando a versão do banco de dados é aumentada.
  // ///
  // /// Implemente aqui a lógica para migrar o schema do banco de dados
  // /// de uma versão antiga para uma nova.
  // Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  //   // Exemplo: Se migrando da versão 1 para 2, adicionar uma nova coluna
  //   // if (oldVersion < 2) {
  //   //   await db.execute("ALTER TABLE Adventure ADD COLUMN new_feature TEXT;");
  //   // }
  //   // Adicionar mais condições 'if' para outras migrações
  // }

  /// Fecha a conexão com o banco de dados, se estiver aberta.
  Future<void> close() async {
    final db = _database; // Use uma variável local para evitar race conditions
    if (db != null && db.isOpen) {
      await db.close();
      _database = null; // Reseta a instância estática
    }
  }
}
