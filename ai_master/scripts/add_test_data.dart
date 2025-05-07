/// COMO EXECUTAR ESTE SCRIPT:
/// 1. Certifique-se de que um emulador ou dispositivo esteja conectado e visível para o Flutter.
/// 2. Navegue até o diretório raiz do projeto Flutter no terminal: `cd ai_master`
/// 3. Execute o comando: `flutter run scripts/add_test_data.dart`
///
/// Este script irá:
/// - Limpar completamente o banco de dados existente (se houver).
/// - Recriar as tabelas do banco de dados.
/// - Popular o banco de dados com várias aventuras de teste e suas respectivas mensagens de chat.
///
/// NOTA: O script é projetado para ser executado com `flutter run` para garantir
/// que todos os bindings e plugins do Flutter (como sqflite) sejam inicializados corretamente.
import 'package:ai_master/models/adventure.dart';
import 'package:ai_master/models/chat_message.dart';
import 'package:ai_master/repositories/adventure_repository.dart';
import 'package:ai_master/services/database_helper.dart';
import 'package:flutter/widgets.dart'; // Necessário para WidgetsFlutterBinding
import 'package:uuid/uuid.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // FFI não é mais inicializado aqui

/// Script para adicionar uma aventura de teste com histórico de mensagens ao banco de dados.
/// Execute com: flutter run scripts/add_test_data.dart (dentro da pasta ai_master)
/// NOTA: Este script requer 'sqflite_common_ffi' para funcionar fora do ambiente Flutter.
/// Certifique-se de ter a dependência em pubspec.yaml.
Future<void> main() async {
  // Garante que os bindings do Flutter estejam inicializados.
  // Necessário para usar plugins como sqflite via 'flutter run'.
  WidgetsFlutterBinding.ensureInitialized();
  print('Bindings do Flutter inicializados.');

  // A inicialização FFI foi removida daqui. O DatabaseHelper agora decide qual factory usar.
  // sqfliteFfiInit(); // REMOVIDO
  // print('Inicializando ambiente para sqflite (FFI)...'); // REMOVIDO

  print('Iniciando adição de dados de teste...');

  try {
    // 1. Inicializa o helper
    final dbHelper = DatabaseHelper.instance;
    print('Instância do DatabaseHelper obtida.');

    // 2. Limpa o banco de dados existente (exclui o arquivo)
    print('Limpando banco de dados existente (se houver)...');
    await dbHelper.deleteDatabaseFile();
    print('Banco de dados limpo.');

    // 3. Garante que o DB seja recriado/inicializado antes de usar o repositório
    print('Inicializando/Recriando o banco de dados...');
    await dbHelper
        .database; // Isso chamará _initDb e _onCreate se o arquivo foi excluído
    print('Banco de dados inicializado/recriado.');

    // 4. Inicializa o repositório
    final repository = AdventureRepository(dbHelper: dbHelper);
    final uuid = Uuid();

    // --- Define a Aventura de Teste ---
    final testAdventureId = uuid.v4();
    final testAdventure = Adventure(
      id: testAdventureId,
      scenarioTitle: 'DRAGONLANCE',
      adventureTitle: 'Exploração Noturna', // Título diferente para teste
      gameState: '{"location": "entrada da floresta", "torch_lit": true}',
      lastPlayedDate: DateTime.now().millisecondsSinceEpoch,
      progressIndicator: 0.25, // 25%
      syncStatus: 0,
      messages: [], // As mensagens serão salvas separadamente
    );

    print('Salvando aventura de teste (ID: $testAdventureId)...');
    await repository.saveAdventure(testAdventure);
    print('Aventura salva com sucesso.');

    // --- Define as Mensagens de Teste ---
    final messages = [
      ChatMessage(
        id: uuid.v4(),
        adventureId: testAdventureId,
        sender: 'system',
        content: 'A noite caiu sobre a Floresta Sussurrante. O que você faz?',
        timestamp:
            DateTime.now()
                .subtract(Duration(minutes: 5))
                .millisecondsSinceEpoch,
      ),
      ChatMessage(
        id: uuid.v4(),
        adventureId: testAdventureId,
        sender: 'user',
        content: 'Acendo minha tocha e entro cautelosamente.',
        timestamp:
            DateTime.now()
                .subtract(Duration(minutes: 4))
                .millisecondsSinceEpoch,
      ),
      ChatMessage(
        id: uuid.v4(),
        adventureId: testAdventureId,
        sender: 'ai',
        content:
            'A luz da tocha dança nas árvores retorcidas. Você ouve um galho quebrar à sua direita.',
        timestamp:
            DateTime.now()
                .subtract(Duration(minutes: 3))
                .millisecondsSinceEpoch,
      ),
      ChatMessage(
        id: uuid.v4(),
        adventureId: testAdventureId,
        sender: 'user',
        content: 'Investigo o som com minha espada em mãos.',
        timestamp:
            DateTime.now()
                .subtract(Duration(minutes: 2))
                .millisecondsSinceEpoch,
      ),
      ChatMessage(
        id: uuid.v4(),
        adventureId: testAdventureId,
        sender: 'ai',
        content:
            'Era apenas um esquilo assustado. A trilha continua à frente, dividindo-se em duas.',
        timestamp:
            DateTime.now()
                .subtract(Duration(minutes: 1))
                .millisecondsSinceEpoch,
      ),
    ];

    print('Salvando ${messages.length} mensagens de teste...');
    for (final msg in messages) {
      await repository.saveChatMessage(msg);
    }
    print('Mensagens salvas com sucesso.');

    // --- Define a Segunda Aventura de Teste ---
    final testAdventureId2 = uuid.v4();
    final testAdventure2 = Adventure(
      id: testAdventureId2,
      scenarioTitle: 'Pepinos Macabros',
      adventureTitle:
          'A Busca Pela Lança', // Título diferente para o segundo teste
      gameState: '{"location": "Khryssalia", "weather": "stormy"}',
      lastPlayedDate: DateTime.now().millisecondsSinceEpoch,
      progressIndicator: 0.50, // 50%
      syncStatus: 0,
      messages: [], // As mensagens serão salvas separadamente
    );

    print('Salvando segunda aventura de teste (ID: $testAdventureId2)...');
    await repository.saveAdventure(testAdventure2);
    print('Segunda aventura salva com sucesso.');

    // --- Define as Mensagens de Teste para a Segunda Aventura ---
    final messages2 = [
      ChatMessage(
        id: uuid.v4(),
        adventureId: testAdventureId2,
        sender: 'system',
        content:
            'Uma tempestade torrencial assola Khryssalia. O que você faz em busca da Lança de Cristal?',
        timestamp:
            DateTime.now()
                .subtract(Duration(minutes: 5))
                .millisecondsSinceEpoch,
      ),
      ChatMessage(
        id: uuid.v4(),
        adventureId: testAdventureId2,
        sender: 'user',
        content: 'Procuro abrigo na estalagem local e pergunto sobre a Lança.',
        timestamp:
            DateTime.now()
                .subtract(Duration(minutes: 4))
                .millisecondsSinceEpoch,
      ),
      ChatMessage(
        id: uuid.v4(),
        adventureId: testAdventureId2,
        sender: 'ai',
        content:
            'O estalajadeiro diz que a Lança está escondida no Pico do Trovão, mas a jornada é perigosa.',
        timestamp:
            DateTime.now()
                .subtract(Duration(minutes: 3))
                .millisecondsSinceEpoch,
      ),
      ChatMessage(
        id: uuid.v4(),
        adventureId: testAdventureId2,
        sender: 'user',
        content: 'Compro mantimentos e sigo para o Pico do Trovão.',
        timestamp:
            DateTime.now()
                .subtract(Duration(minutes: 2))
                .millisecondsSinceEpoch,
      ),
      ChatMessage(
        id: uuid.v4(),
        adventureId: testAdventureId2,
        sender: 'ai',
        content:
            'A trilha é íngreme e escorregadia. A tempestade não dá sinais de diminuir.',
        timestamp:
            DateTime.now()
                .subtract(Duration(minutes: 1))
                .millisecondsSinceEpoch,
      ),
    ];

    print(
      'Salvando ${messages2.length} mensagens de teste para a segunda aventura...',
    );
    for (final msg in messages2) {
      await repository.saveChatMessage(msg);
    }
    print('Mensagens da segunda aventura salvas com sucesso.');

    // --- Adiciona Aventura: ARQUIVO X ---
    final testAdventureIdXFiles = uuid.v4();
    final testAdventureXFiles = Adventure(
      id: testAdventureIdXFiles,
      scenarioTitle: 'ARQUIVO X',
      adventureTitle: 'O Caso do Milharal',
      gameState: '{"location": "campo de milho", "time": "noite"}',
      lastPlayedDate: DateTime.now().millisecondsSinceEpoch,
      progressIndicator: 0.10, // 10%
      syncStatus: 0,
      messages: [],
    );
    print('Salvando aventura ARQUIVO X (ID: $testAdventureIdXFiles)...');
    await repository.saveAdventure(testAdventureXFiles);
    print('Aventura ARQUIVO X salva com sucesso.');
    final messagesXFiles = [
      ChatMessage(
        id: uuid.v4(),
        adventureId: testAdventureIdXFiles,
        sender: 'system',
        content:
            'Vocês chegam a um milharal isolado onde luzes estranhas foram vistas. O que fazem?',
        timestamp:
            DateTime.now()
                .subtract(Duration(minutes: 2))
                .millisecondsSinceEpoch,
      ),
      ChatMessage(
        id: uuid.v4(),
        adventureId: testAdventureIdXFiles,
        sender: 'user',
        content:
            'Mulder, pegue a lanterna. Scully, prepare o equipamento científico.',
        timestamp:
            DateTime.now()
                .subtract(Duration(minutes: 1))
                .millisecondsSinceEpoch,
      ),
    ];
    print(
      'Salvando ${messagesXFiles.length} mensagens de teste para ARQUIVO X...',
    );
    for (final msg in messagesXFiles) {
      await repository.saveChatMessage(msg);
    }
    print('Mensagens de ARQUIVO X salvas com sucesso.');

    // --- Adiciona Aventura: Caverna do Dragão ---
    final testAdventureIdDungeons = uuid.v4();
    final testAdventureDungeons = Adventure(
      id: testAdventureIdDungeons,
      scenarioTitle: 'Caverna do Dragão',
      adventureTitle: 'O Portal Perdido',
      gameState:
          '{"location": "floresta sombria", "objective": "encontrar portal"}',
      lastPlayedDate: DateTime.now().millisecondsSinceEpoch,
      progressIndicator: 0.35, // 35%
      syncStatus: 0,
      messages: [],
    );
    print(
      'Salvando aventura Caverna do Dragão (ID: $testAdventureIdDungeons)...',
    );
    await repository.saveAdventure(testAdventureDungeons);
    print('Aventura Caverna do Dragão salva com sucesso.');
    final messagesDungeons = [
      ChatMessage(
        id: uuid.v4(),
        adventureId: testAdventureIdDungeons,
        sender: 'system',
        content:
            'O Mestre dos Magos aparece: "O caminho para casa está próximo, mas Vingador os observa."',
        timestamp:
            DateTime.now()
                .subtract(Duration(minutes: 3))
                .millisecondsSinceEpoch,
      ),
      ChatMessage(
        id: uuid.v4(),
        adventureId: testAdventureIdDungeons,
        sender: 'user',
        content: 'Hank, use seu arco! Eric, proteja a Uni!',
        timestamp:
            DateTime.now()
                .subtract(Duration(minutes: 2))
                .millisecondsSinceEpoch,
      ),
      ChatMessage(
        id: uuid.v4(),
        adventureId: testAdventureIdDungeons,
        sender: 'ai',
        content: 'Vingador lança uma magia negra, bloqueando a passagem.',
        timestamp:
            DateTime.now()
                .subtract(Duration(minutes: 1))
                .millisecondsSinceEpoch,
      ),
    ];
    print(
      'Salvando ${messagesDungeons.length} mensagens de teste para Caverna do Dragão...',
    );
    for (final msg in messagesDungeons) {
      await repository.saveChatMessage(msg);
    }
    print('Mensagens de Caverna do Dragão salvas com sucesso.');

    // --- Adiciona Aventura: Dominus & Dragons ---
    final testAdventureIdDominus = uuid.v4();
    final testAdventureDominus = Adventure(
      id: testAdventureIdDominus,
      scenarioTitle: 'Dominus & Dragons',
      adventureTitle: 'A Torre do Feiticeiro',
      gameState: '{"location": "base da torre", "party_status": "saudável"}',
      lastPlayedDate: DateTime.now().millisecondsSinceEpoch,
      progressIndicator: 0.60, // 60%
      syncStatus: 0,
      messages: [],
    );
    print(
      'Salvando aventura Dominus & Dragons (ID: $testAdventureIdDominus)...',
    );
    await repository.saveAdventure(testAdventureDominus);
    print('Aventura Dominus & Dragons salva com sucesso.');
    final messagesDominus = [
      ChatMessage(
        id: uuid.v4(),
        adventureId: testAdventureIdDominus,
        sender: 'system',
        content:
            'A porta da torre range ao abrir. Escuridão e o cheiro de magia antiga preenchem o ar.',
        timestamp:
            DateTime.now()
                .subtract(Duration(minutes: 2))
                .millisecondsSinceEpoch,
      ),
      ChatMessage(
        id: uuid.v4(),
        adventureId: testAdventureIdDominus,
        sender: 'user',
        content: 'Vamos entrar com cautela. Mantenham as armas prontas.',
        timestamp:
            DateTime.now()
                .subtract(Duration(minutes: 1))
                .millisecondsSinceEpoch,
      ),
    ];
    print(
      'Salvando ${messagesDominus.length} mensagens de teste para Dominus & Dragons...',
    );
    for (final msg in messagesDominus) {
      await repository.saveChatMessage(msg);
    }
    print('Mensagens de Dominus & Dragons salvas com sucesso.');

    // --- Adiciona Aventura: Um Minuto Para o Fim ---
    final testAdventureIdOneMinute = uuid.v4();
    final testAdventureOneMinute = Adventure(
      id: testAdventureIdOneMinute,
      scenarioTitle: 'Um Minuto Para o Fim',
      adventureTitle: 'A Bomba no Museu',
      gameState: '{"location": "salão principal", "timer": 55}',
      lastPlayedDate: DateTime.now().millisecondsSinceEpoch,
      progressIndicator: 0.80, // 80%
      syncStatus: 0,
      messages: [],
    );
    print(
      'Salvando aventura Um Minuto Para o Fim (ID: $testAdventureIdOneMinute)...',
    );
    await repository.saveAdventure(testAdventureOneMinute);
    print('Aventura Um Minuto Para o Fim salva com sucesso.');
    final messagesOneMinute = [
      ChatMessage(
        id: uuid.v4(),
        adventureId: testAdventureIdOneMinute,
        sender: 'system',
        content:
            'O contador marca 55 segundos. A bomba está escondida em algum lugar neste salão lotado.',
        timestamp:
            DateTime.now()
                .subtract(Duration(minutes: 1))
                .millisecondsSinceEpoch,
      ),
      ChatMessage(
        id: uuid.v4(),
        adventureId: testAdventureIdOneMinute,
        sender: 'user',
        content:
            'Dividir e procurar! Verifiquem atrás das estátuas e tapeçarias!',
        timestamp:
            DateTime.now()
                .subtract(Duration(seconds: 30))
                .millisecondsSinceEpoch,
      ),
    ];
    print(
      'Salvando ${messagesOneMinute.length} mensagens de teste para Um Minuto Para o Fim...',
    );
    for (final msg in messagesOneMinute) {
      await repository.saveChatMessage(msg);
    }
    print('Mensagens de Um Minuto Para o Fim salvas com sucesso.');

    // --- Adiciona Aventura: Vampiro, a Milanesa ---
    final testAdventureIdVampire = uuid.v4();
    final testAdventureVampire = Adventure(
      id: testAdventureIdVampire,
      scenarioTitle: 'Vampiro, a Milanesa',
      adventureTitle: 'O Banquete Sangrento',
      gameState: '{"location": "restaurante chique", "disfarce": "ativo"}',
      lastPlayedDate: DateTime.now().millisecondsSinceEpoch,
      progressIndicator: 0.05, // 5%
      syncStatus: 0,
      messages: [],
    );
    print(
      'Salvando aventura Vampiro, a Milanesa (ID: $testAdventureIdVampire)...',
    );
    await repository.saveAdventure(testAdventureVampire);
    print('Aventura Vampiro, a Milanesa salva com sucesso.');
    final messagesVampire = [
      ChatMessage(
        id: uuid.v4(),
        adventureId: testAdventureIdVampire,
        sender: 'system',
        content:
            'Você se infiltrou no banquete anual dos vampiros gourmet. Seu alvo: o Conde Parmegiana.',
        timestamp:
            DateTime.now()
                .subtract(Duration(minutes: 2))
                .millisecondsSinceEpoch,
      ),
      ChatMessage(
        id: uuid.v4(),
        adventureId: testAdventureIdVampire,
        sender: 'user',
        content: 'Peço um "Sangue Negroni" e observo o salão discretamente.',
        timestamp:
            DateTime.now()
                .subtract(Duration(minutes: 1))
                .millisecondsSinceEpoch,
      ),
      ChatMessage(
        id: uuid.v4(),
        adventureId: testAdventureIdVampire,
        sender: 'ai',
        content:
            'O Conde Parmegiana está na mesa principal, rindo enquanto saboreia um raro "O Negativo".',
        timestamp:
            DateTime.now()
                .subtract(Duration(seconds: 45))
                .millisecondsSinceEpoch,
      ),
    ];
    print(
      'Salvando ${messagesVampire.length} mensagens de teste para Vampiro, a Milanesa...',
    );
    for (final msg in messagesVampire) {
      await repository.saveChatMessage(msg);
    }
    print('Mensagens de Vampiro, a Milanesa salvas com sucesso.');
    print('Dados de teste adicionados!');
  } catch (e, stackTrace) {
    print('Erro ao adicionar dados de teste: $e');
    print('StackTrace: $stackTrace');
  } finally {
    // É importante fechar o banco de dados se o script for autônomo
    // await DatabaseHelper.instance.close();
    // print('Conexão com o banco de dados fechada.');
    // No entanto, fechar aqui pode interferir se o app ainda estiver rodando
    // ou se outro processo for usar o DB logo em seguida. Deixe comentado por segurança.
  }
}
