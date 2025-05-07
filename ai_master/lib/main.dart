import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import para Riverpod
import 'package:sqflite/sqflite.dart'; // Import para deleteDatabase e getDatabasesPath
import 'package:path/path.dart'; // Import para join

// Core Application Components
import 'package:ai_master/controllers/main_screen_controller.dart';
import 'package:ai_master/features/main_screen/view/material_main_screen_view.dart';
import 'package:ai_master/features/splash_screen/view/splash_screen.dart'; // Import da SplashScreen

// Models (Implicitly used by Controller/Repository)
// import 'package:ai_master/models/adventure.dart';
// import 'package:ai_master/models/scenario.dart';

// Services and Repositories (Dependencies)
import 'package:ai_master/repositories/adventure_repository.dart';
import 'package:ai_master/services/app_preferences.dart'; // Abstract class
import 'package:ai_master/services/shared_preferences_app_preferences.dart'; // Implementation
import 'package:ai_master/models/adventure.dart'; // Import para Adventure
import 'package:ai_master/models/chat_message.dart'; // Import para ChatMessage
import 'package:uuid/uuid.dart'; // Import para Uuid
import 'package:ai_master/services/database_helper.dart';
import 'package:ai_master/services/navigation_service.dart'; // Abstract class
import 'package:ai_master/services/mock_navigation_service.dart'; // Implementation
import 'package:ai_master/services/scenario_loader.dart';

/// Application entry point.
///
/// Initializes necessary services and sets up the root widget with dependency injection.
Future<void> main() async {
  /// Ensures Flutter bindings are initialized before any Flutter-specific code runs.
  /// Crucial for plugins like shared_preferences or path_provider.
  WidgetsFlutterBinding.ensureInitialized();

  // --- INÍCIO: Limpeza do Banco de Dados (Temporário para Teste) ---
  /* <<< COMENTADO PARA DEBUG - Bloco que excluía o DB a cada início
  // TODO: Remover esta seção após testes. Garante um DB limpo a cada reinício completo.
  try {
    final dbPath = join(await getDatabasesPath(), 'ai_master_database.db');
    print('[TEMP] Excluindo banco de dados existente em: $dbPath');
    await deleteDatabase(dbPath);
    print('[TEMP] Banco de dados excluído com sucesso.');
  } catch (e) {
    print('[TEMP] Erro ao excluir banco de dados (pode não existir ainda): $e');
  }
  */ // <<< FIM DO BLOCO COMENTADO
  // --- FIM: Limpeza do Banco de Dados ---

  /// Initialize asynchronous services before the app starts.
  /// This ensures that dependencies requiring async setup (like SharedPreferences)
  /// are ready before being injected.
  // Use the concrete implementation's factory method
  final AppPreferences appPreferences =
      await SharedPreferencesAppPreferences.getInstance();

  /// Get the Singleton instance of DatabaseHelper.
  /// Initialization happens lazily within the helper itself when `database` is first accessed.
  final DatabaseHelper databaseHelper = DatabaseHelper.instance;
  // No need to call initialize() here anymore.

  /// Instantiate synchronous services and repositories, injecting dependencies.
  final AdventureRepository adventureRepository = AdventureRepository(
    dbHelper: databaseHelper,
  ); // Pass dbHelper using named argument
  final ScenarioLoader scenarioLoader = ScenarioLoader();
  // Use the concrete implementation for NavigationService
  final NavigationService navigationService = MockNavigationService();

  // TODO: Remover este bloco após testes iniciais. Adiciona dados de exemplo se o DB estiver vazio.
  // --- INÍCIO: Código temporário para adicionar dados de teste ---
  /* <<< COMENTADO PARA DEBUG - Bloco que adicionava dados de teste ('A Floresta Sussurrante')
  print('[MAIN][TEMP_DATA] Verificando se dados de teste são necessários...');
  try {
    print(
      '[MAIN][TEMP_DATA] Chamando adventureRepository.getAllAdventures()...',
    );
    // Verifica se já existem aventuras antes de adicionar
    // Nota: A verificação ocorrerá após a exclusão acima, então sempre adicionará
    // se a exclusão for bem-sucedida. Se a exclusão falhar e o DB existir,
    // esta lógica ainda impedirá a duplicação.
    final existingAdventures = await adventureRepository.getAllAdventures();
    print(
      '[MAIN][TEMP_DATA] getAllAdventures() retornou ${existingAdventures.length} aventura(s).',
    );

    if (existingAdventures.isEmpty) {
      print(
        '[MAIN][TEMP_DATA] Nenhuma aventura encontrada. Iniciando adição de dados de teste...',
      );
      final uuid = Uuid();
      // --- Define a Aventura de Teste ---
      final testAdventureId = uuid.v4();
      final testAdventure = Adventure(
        id: testAdventureId,
        scenarioTitle: 'A Floresta Sussurrante',
        adventureTitle: 'Exploração Noturna', // Título diferente para teste
        gameState: '{"location": "entrada da floresta", "torch_lit": true}',
        lastPlayedDate: DateTime.now().millisecondsSinceEpoch,
        progressIndicator: 0.25, // 25%
        syncStatus: 0,
        messages: [], // As mensagens serão salvas separadamente
      );
      print(
        '[MAIN][TEMP_DATA] Aventura de teste criada (ID: $testAdventureId).',
      );

      print(
        '[MAIN][TEMP_DATA] Chamando adventureRepository.saveAdventure()...',
      );
      // Usa a instância já criada de adventureRepository
      await adventureRepository.saveAdventure(testAdventure);
      print('[MAIN][TEMP_DATA] adventureRepository.saveAdventure() concluído.');

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
      print('[MAIN][TEMP_DATA] ${messages.length} mensagens de teste criadas.');

      print('[MAIN][TEMP_DATA] Iniciando loop para salvar mensagens...');
      int msgCounter = 0;
      for (final msg in messages) {
        msgCounter++;
        print(
          '[MAIN][TEMP_DATA] Chamando adventureRepository.saveChatMessage() para msg $msgCounter/${messages.length} (ID: ${msg.id})...',
        );
        // Usa a instância já criada de adventureRepository
        await adventureRepository.saveChatMessage(msg);
        print(
          '[MAIN][TEMP_DATA] adventureRepository.saveChatMessage() concluído para msg $msgCounter.',
        );
      }
      print('[MAIN][TEMP_DATA] Loop de salvamento de mensagens concluído.');
      print('[MAIN][TEMP_DATA] Dados de teste adicionados com sucesso!');
    } else {
      print(
        '[MAIN][TEMP_DATA] Aventuras existentes encontradas (${existingAdventures.length}). Dados de teste NÃO foram adicionados.',
      );
    }
  } catch (e, stackTrace) {
    print('[MAIN][TEMP_DATA] ERRO FATAL ao adicionar dados de teste: $e');
    print('[MAIN][TEMP_DATA] StackTrace: $stackTrace');
  }
  */ // <<< FIM DO BLOCO COMENTADO
  // --- FIM: Código temporário para adicionar dados de teste ---

  /// Run the Flutter application.
  /// Uses `MultiProvider` to make all necessary services and controllers
  /// available throughout the widget tree.
  runApp(
    ProviderScope(
      // Envolve com ProviderScope
      child: provider.MultiProvider(
        // Adicionado prefixo provider.
        providers: [
          // --- Service/Repository Providers ---
          // Provides singleton instances of services and repositories.
          // Using `.value` is efficient for already instantiated objects.

          /// Provides the application preferences service.
          provider.Provider<AppPreferences>.value(
            value: appPreferences,
          ), // Adicionado prefixo provider.
          /// Provides the database helper service.
          provider.Provider<DatabaseHelper>.value(
            value: databaseHelper,
          ), // Adicionado prefixo provider.
          /// Provides the adventure repository.
          provider.Provider<AdventureRepository>.value(
            value: adventureRepository,
          ), // Adicionado prefixo provider.
          /// Provides the scenario loader service.
          provider.Provider<ScenarioLoader>.value(
            value: scenarioLoader,
          ), // Adicionado prefixo provider.
          /// Provides the navigation service.
          provider.Provider<NavigationService>.value(
            value: navigationService,
          ), // Adicionado prefixo provider.
          // --- Controller Provider (REMOVIDO) ---
          // O MainScreenController não é mais um ChangeNotifier e não precisa ser
          // fornecido globalmente aqui. A View o instanciará ou usará providers de ação.
        ],
        child: const MyApp(), // The root widget of the application
      ),
    ),
  );
}

/// The root widget of the application.
///
/// Sets up the `MaterialApp` and defines the global theme.
class MyApp extends StatelessWidget {
  /// Creates the MyApp widget.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    /// Builds the MaterialApp, the core widget for a Material Design app.
    return MaterialApp(
      /// Title displayed in the OS task switcher.
      title: 'IA Master',

      /// Defines the overall visual theme for the application.
      theme: ThemeData(
        /// Sets the theme to dark mode.
        brightness: Brightness.dark,

        /// Defines the color scheme based on a seed color.
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal, // Base color for generating the scheme
          brightness: Brightness.dark, // Ensures dark mode colors
        ),

        /// Enables Material 3 design components and styles.
        useMaterial3: true,

        /// Customizes the appearance of Card widgets.
        cardTheme: CardTheme(
          elevation: 3, // Shadow depth
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
        ),

        /// Customizes the appearance of text input fields.
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ), // Border style
        ),
      ),

      /// The initial screen displayed when the app starts.
      /// `MaterialMainScreenView` will obtain the `MainScreenController`
      /// from the `Provider` context automatically (e.g., using Consumer or context.watch).
      // Remove 'const' because the widget tree now depends on non-constant providers.
      // The view no longer takes the controller explicitly.
      home: const SplashScreen(), // Define SplashScreen como tela inicial
      /// Hides the debug banner in the top-right corner.
      debugShowCheckedModeBanner: false,
    );
  }
}
