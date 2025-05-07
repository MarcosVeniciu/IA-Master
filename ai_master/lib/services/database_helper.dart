import 'dart:async';
import 'dart:io'; // Necessário para Platform e File

import 'package:flutter/foundation.dart'; // Para kIsWeb
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
// Import FFI apenas se necessário, ou condicionalmente
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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
      3; // Incrementado para adicionar adventure_title

  /// Construtor privado usado internamente para criar a instância Singleton.
  DatabaseHelper._init();

  /// Retorna a instância do banco de dados SQFlite.
  ///
  /// Se o banco de dados ainda não foi inicializado, este getter chama [_initDb]
  /// para criá-lo e abri-lo. Caso contrário, retorna a instância existente.
  Future<Database> get database async {
    print('[DB_HELPER] Acessando getter database...');
    if (_database != null) {
      print('[DB_HELPER] Instância _database já existe. Retornando.');
      return _database!;
    }
    print('[DB_HELPER] Instância _database é nula. Chamando _initDb()...');
    _database = await _initDb(); // _initDb agora seleciona a factory correta
    print('[DB_HELPER] _initDb() concluído. Retornando instância.');
    return _database!;
  }

  /// Obtém a factory apropriada para a plataforma atual.
  DatabaseFactory _getDatabaseFactory() {
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      // Usa FFI para Desktop
      // Precisa importar 'package:sqflite_common_ffi/sqflite_ffi.dart' e inicializar
      // sqfliteFfiInit(); // A inicialização deve ocorrer fora daqui, talvez no main.dart ou no script
      // return databaseFactoryFfi;
      // --- TEMPORARY: Throw error until FFI setup is confirmed needed/done elsewhere ---
      // Ou, se o script for o único usuário FFI, inicializar aqui pode ser ok,
      // mas é melhor fazer isso no ponto de entrada do script/app.
      // Por enquanto, vamos assumir que FFI não é usado no app principal.
      // Se precisar de FFI, descomente as linhas acima e garanta a inicialização.
      print(
        '[DB_HELPER] AVISO: Tentando usar FFI, mas não implementado/inicializado aqui.',
      );
      // return databaseFactoryFfi; // Descomente se FFI for necessário e inicializado
      throw UnsupportedError(
        'FFI factory not fully configured in DatabaseHelper',
      );
    } else {
      // Usa a factory padrão para Android, iOS e Web (se sqflite suportar Web no futuro)
      print('[DB_HELPER] Usando databaseFactory padrão.');
      return databaseFactory; // A factory padrão do pacote sqflite
    }
  }

  /// Inicializa o banco de dados SQFlite.
  ///
  /// Determina o caminho do banco de dados no sistema de arquivos do dispositivo
  /// e abre a conexão. Se o banco de dados não existir, ele será criado
  /// chamando o método [_onCreate].
  ///
  /// Retorna uma [Future] que completa com a instância do [Database].
  Future<Database> _initDb() async {
    print('[DB_HELPER] Iniciando _initDb()...');
    try {
      final factory = _getDatabaseFactory(); // Obtém a factory correta
      final String databasesPath = await factory.getDatabasesPath();
      final String path = join(databasesPath, _dbName);
      print(
        '[DB_HELPER] Caminho do banco de dados: $path (Usando factory: ${factory.runtimeType})',
      );
      print(
        '[DB_HELPER] Chamando ${factory.runtimeType}.openDatabase (version: $_dbVersion)...',
      );

      // Usa a factory selecionada para abrir o banco
      final db = await factory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: _dbVersion,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade, // Habilitado para migração
          // onDowngrade: onDatabaseDowngradeDelete, // Estratégia para downgrade
        ),
      );
      print(
        '[DB_HELPER] ${factory.runtimeType}.openDatabase concluído com sucesso.',
      );
      return db;
    } catch (e) {
      // O erro agora pode ser de qualquer factory
      print('[DB_HELPER] ERRO FATAL durante _initDb: $e');
      // Removido stackTrace não utilizado
      // TODO: Implementar um mecanismo de log mais robusto
      // Relançar a exceção para que o chamador saiba da falha
      rethrow;
    }
    // Código duplicado removido daqui
  }

  /// Chamado quando o banco de dados é criado pela primeira vez.
  ///
  /// Executa as instruções SQL para criar as tabelas `Adventure` e `ChatMessage`,
  /// bem como seus índices correspondentes, conforme definido no schema.
  ///
  /// - [db]: A instância do banco de dados sendo criada.
  /// - [version]: A versão do banco de dados que está sendo criada.
  Future<void> _onCreate(Database db, int version) async {
    print('[DB_HELPER] Iniciando _onCreate (version: $version)...');
    try {
      print('[DB_HELPER] Criando tabela Adventure...');
      await db.execute('''
        CREATE TABLE Adventure (
            id TEXT PRIMARY KEY NOT NULL,       -- UUID da aventura
            scenario_title TEXT NOT NULL,       -- Título do cenário base
            adventure_title TEXT NOT NULL,      -- Título específico da instância da aventura
            progress_indicator REAL,            -- Progresso numérico (0.0 a 1.0)
            game_state TEXT NOT NULL,           -- Estado do jogo serializado em JSON
            last_played_date INTEGER NOT NULL,  -- Timestamp da última interação (millisecondsSinceEpoch)
            sync_status INTEGER NOT NULL DEFAULT 0 -- Status de sincronização (0=local, 1=syncing, 2=synced, -1=error)
        );
      ''');
      print('[DB_HELPER] Tabela Adventure criada.');

      print('[DB_HELPER] Criando índice idx_adventure_last_played...');
      await db.execute('''
        CREATE INDEX idx_adventure_last_played ON Adventure(last_played_date DESC);
      ''');
      print('[DB_HELPER] Índice idx_adventure_last_played criado.');

      print('[DB_HELPER] Criando tabela ChatMessage...');
      await db.execute('''
        CREATE TABLE ChatMessage (
            id TEXT PRIMARY KEY NOT NULL,           -- UUID da mensagem
            adventureId TEXT NOT NULL,             -- FK para Adventure.id (camelCase)
            sender TEXT NOT NULL,                   -- 'player', 'ai', 'system'
            content TEXT NOT NULL,                  -- Conteúdo da mensagem
            timestamp INTEGER NOT NULL,             -- Timestamp da mensagem (millisecondsSinceEpoch)
            syncStatus INTEGER NOT NULL DEFAULT 0, -- Status de sincronização (0=local) (camelCase)
            FOREIGN KEY (adventureId) REFERENCES Adventure(id) ON DELETE CASCADE -- Garante integridade referencial (camelCase)
        );
      ''');
      print('[DB_HELPER] Tabela ChatMessage criada.');

      print(
        '[DB_HELPER] Criando índice idx_chatmessage_adventure_timestamp...',
      );
      await db.execute('''
        CREATE INDEX idx_chatmessage_adventure_timestamp ON ChatMessage(adventureId, timestamp ASC); -- Corrigido para camelCase
      ''');
      print('[DB_HELPER] Índice idx_chatmessage_adventure_timestamp criado.');
      print('[DB_HELPER] _onCreate concluído com sucesso.');
    } catch (e) {
      print('[DB_HELPER] ERRO FATAL durante _onCreate: $e');
      // Removido stackTrace não utilizado
      // TODO: Implementar um mecanismo de log mais robusto
      // print('Erro ao criar tabelas do banco de dados: $e'); // Removido - usar logger
      // Relançar a exceção para que o chamador (openDatabase) saiba da falha
      rethrow;
    }
  }

  // --- Métodos de Migração ---

  /// Chamado quando a versão do banco de dados é aumentada.
  ///
  /// Implementa a lógica para migrar o schema do banco de dados
  /// de versões antigas para a nova versão definida em [_dbVersion].
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print(
      "[DB_HELPER] Iniciando _onUpgrade da versão $oldVersion para $newVersion...",
    );
    // --- Migração v1/v2 -> v3 ---
    if (oldVersion < 3 && newVersion >= 3) {
      print(
        "[DB_HELPER] Aplicando migração para versão 3: Adicionando adventure_title...",
      );
      try {
        // Abordagem segura para adicionar coluna NOT NULL no SQLite:
        // 1. Renomear tabela antiga
        print("[DB_HELPER] Renomeando Adventure para Adventure_old...");
        await db.execute('ALTER TABLE Adventure RENAME TO Adventure_old;');
        print("[DB_HELPER] Tabela Adventure renomeada para Adventure_old.");

        // 2. Criar nova tabela com a coluna adventure_title NOT NULL
        print(
          "[DB_HELPER] Criando nova tabela Adventure com adventure_title...",
        );
        await db.execute('''
          CREATE TABLE Adventure (
              id TEXT PRIMARY KEY NOT NULL,
              scenario_title TEXT NOT NULL,
              adventure_title TEXT NOT NULL, -- Nova coluna obrigatória
              progress_indicator REAL,
              game_state TEXT NOT NULL,
              last_played_date INTEGER NOT NULL,
              sync_status INTEGER NOT NULL DEFAULT 0
          );
        ''');
        print("[DB_HELPER] Nova tabela Adventure criada com adventure_title.");

        // Recriar índice (usando IF NOT EXISTS para segurança)
        print("[DB_HELPER] Garantindo índice idx_adventure_last_played...");
        await db.execute('''
          CREATE INDEX IF NOT EXISTS idx_adventure_last_played ON Adventure(last_played_date DESC);
        ''');
        print("[DB_HELPER] Índice idx_adventure_last_played garantido.");

        // 3. Copiar dados, usando scenario_title como valor inicial para adventure_title
        print("[DB_HELPER] Copiando dados de Adventure_old para Adventure...");
        await db.execute('''
          INSERT INTO Adventure (id, scenario_title, adventure_title, progress_indicator, game_state, last_played_date, sync_status)
          SELECT id, scenario_title, scenario_title, progress_indicator, game_state, last_played_date, sync_status
          FROM Adventure_old;
        ''');
        print(
          "[DB_HELPER] Dados copiados (adventure_title populado com scenario_title).",
        );

        // 4. Remover tabela antiga
        print("[DB_HELPER] Removendo tabela Adventure_old...");
        await db.execute('DROP TABLE Adventure_old;');
        print("[DB_HELPER] Tabela Adventure_old removida.");

        // Migração para ChatMessage (se necessário no futuro, adicionar aqui)
        // Exemplo: Adicionar coluna se migrando de versão < X
        // await db.execute('ALTER TABLE ChatMessage ADD COLUMN new_chat_field TEXT;');
        print("[DB_HELPER] Migração para versão 3 concluída com sucesso.");
      } catch (e) {
        print("[DB_HELPER] ERRO FATAL durante migração para v3: $e");
        rethrow; // Relança para interromper o processo de upgrade
      }
    }
    // --- Fim Migração v1/v2 -> v3 ---

    // Adicionar mais blocos 'if (oldVersion < X && newVersion >= X)' para futuras migrações
    // Exemplo:
    // if (oldVersion < 4 && newVersion >= 4) {
    //   print("[DB_HELPER] Aplicando migração para versão 4...");
    //   // ... código da migração v4 ...
    //   print("[DB_HELPER] Migração para versão 4 concluída.");
    // }

    print("[DB_HELPER] _onUpgrade concluído.");
  }

  /// Fecha a conexão com o banco de dados, se estiver aberta.
  Future<void> close() async {
    final db = _database; // Use uma variável local para evitar race conditions
    if (db != null && db.isOpen) {
      await db.close();
      _database = null; // Reseta a instância estática
    }
  }

  /// Exclui o arquivo físico do banco de dados do sistema de arquivos.
  ///
  /// ATENÇÃO: Esta operação é destrutiva e irreversível. Todos os dados
  /// armazenados no banco de dados serão perdidos.
  ///
  /// Fecha a conexão existente antes de tentar excluir o arquivo.
  Future<void> deleteDatabaseFile() async {
    print('[DB_HELPER] Iniciando deleteDatabaseFile()...');
    try {
      // 1. Fechar a conexão atual, se aberta
      print('[DB_HELPER] Fechando conexão atual (se aberta)...');
      await close(); // Garante que o arquivo não esteja em uso
      print('[DB_HELPER] Conexão fechada.');

      // 2. Obter o caminho do arquivo do banco de dados (usando a factory correta)
      final factory = _getDatabaseFactory();
      final String databasesPath = await factory.getDatabasesPath();
      final String path = join(databasesPath, _dbName);
      print(
        '[DB_HELPER] Caminho do arquivo a ser excluído: $path (Usando factory: ${factory.runtimeType})',
      );

      // 3. Verificar se o arquivo existe e excluí-lo
      // A exclusão do arquivo em si não depende da factory, apenas o caminho
      final file = File(path);
      if (await file.exists()) {
        print('[DB_HELPER] Arquivo encontrado. Excluindo...');
        await file.delete();
        print('[DB_HELPER] Arquivo do banco de dados excluído com sucesso.');
      } else {
        print(
          '[DB_HELPER] Arquivo do banco de dados não encontrado em $path. Nenhuma ação necessária.',
        );
      }
      // 4. Resetar a instância estática para forçar reinicialização na próxima chamada
      _database = null;
      print('[DB_HELPER] Instância _database resetada para null.');
      print('[DB_HELPER] deleteDatabaseFile() concluído com sucesso.');
    } catch (e) {
      print('[DB_HELPER] ERRO durante deleteDatabaseFile: $e');
      // TODO: Implementar um mecanismo de log mais robusto
      // Relançar a exceção para que o chamador saiba da falha
      rethrow;
    }
  }
}
