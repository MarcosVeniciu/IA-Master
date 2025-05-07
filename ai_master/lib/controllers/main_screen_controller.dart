import 'package:flutter/foundation.dart'; // Para debugPrint
// import 'package:flutter/foundation.dart'; // Removido - Não é mais ChangeNotifier
import '../models/adventure.dart';
import '../models/scenario.dart';
import '../repositories/adventure_repository.dart';
// import '../services/app_preferences.dart'; // Removido - Não utilizado
import '../services/navigation_service.dart';
import '../services/scenario_loader.dart';
import 'package:uuid/uuid.dart'; // Importa o pacote uuid

/// Orchestrates the logic and data flow for the Main Screen.
///
/// Acts as an intermediary between the Model/Data Access layers
/// (`AdventureRepository`, `ScenarioLoader`) and the View (`MainScreenView`),
/// managing the screen's state and handling user interactions.
/// Uses [ChangeNotifier] to notify listeners (typically the View) about state changes. - OBSOLETO
/// Gerencia as ações do usuário na tela principal, delegando para os serviços apropriados.
class MainScreenController /* Removido: with ChangeNotifier */ {
  /// Repository for accessing adventure data.
  final AdventureRepository _adventureRepo;

  /// Service for loading available scenarios.
  final ScenarioLoader _scenarioLoader;

  /// Service for handling navigation between screens.
  final NavigationService _navigationService;

  // final AppPreferences _appPreferences; // Removido - Não utilizado

  /// Constructor requiring necessary dependencies for actions.
  ///
  /// Initializes the controller with the necessary services and repositories.
  MainScreenController({
    required AdventureRepository adventureRepo,
    required ScenarioLoader scenarioLoader,
    required NavigationService navigationService,
    // required AppPreferences appPreferences, // Removido
  }) : _adventureRepo = adventureRepo,
       _scenarioLoader = scenarioLoader,
       _navigationService = navigationService;
  // _appPreferences = appPreferences; // Removido

  // --- State Attributes (REMOVIDOS) ---
  // A lógica de estado (listas, flags de loading, erros) foi movida para os Providers Riverpod.

  // --- Private Helper Methods (REMOVIDOS) ---
  // Os métodos _setIsLoading..., _setOngoing..., _setAvailable..., _setScenarioLoadingError
  // e _checkFirstLaunch não são mais necessários.

  // --- Public Methods ---

  // O método initialize() foi removido. A inicialização (carregamento de dados)
  // é feita automaticamente pelos FutureProviders.

  // O método loadData() foi removido. O recarregamento é feito invalidando
  // os providers (ex: no RefreshIndicator).

  /// Handles the user action to continue an ongoing adventure (RF-004).
  ///
  /// Delegates the navigation logic to the [NavigationService], providing the
  /// [adventureId] to navigate to the correct adventure screen.
  ///
  /// [adventureId] The unique identifier of the adventure to continue.
  void onContinueAdventure(String adventureId) {
    debugPrint("Continuing adventure: $adventureId");
    _navigationService.goToAdventure(adventureId);
  }

  /// Handles the user action to start a new adventure based on a selected scenario (RF-007).
  ///
  /// Uses the [AdventureRepository] to create a new [Adventure] instance based
  /// on the provided [scenario] and then uses the [NavigationService] to navigate
  /// the user to the screen for this newly created adventure.
  ///
  /// [scenario] The [Scenario] object selected by the user to start the adventure.
  Future<void> onStartScenario(Scenario scenario) async {
    debugPrint("Starting new adventure from scenario: ${scenario.title}");
    try {
      // Correção: Criar manualmente a instância de Adventure e salvá-la
      final now = DateTime.now().millisecondsSinceEpoch;
      final newId = const Uuid().v4();

      // Cria a nova aventura com base no cenário
      final adventureToSave = Adventure(
        id: newId,
        scenarioTitle: scenario.title, // Renomeado
        /// Inicialmente, o título da aventura será o mesmo do cenário.
        /// Poderá ser editado futuramente (feature separada).
        adventureTitle: scenario.title,
        // Define um estado inicial vazio. O estado real será construído durante o jogo.
        gameState: '{}', // Renomeado
        lastPlayedDate: now, // Renomeado
        // Define o progresso inicial como 0.0 (0% concluído).
        progressIndicator: 0.0, // Renomeado
      );

      // Salva a nova aventura no repositório (retorna void)
      await _adventureRepo.saveAdventure(adventureToSave);
      // Usa o ID da instância criada localmente, pois saveAdventure retorna void.
      debugPrint(
        "New adventure created and saved with ID: ${adventureToSave.id}",
      );

      // Navega para a tela da nova aventura usando o ID local.
      _navigationService.goToNewAdventure(adventureToSave.id);
    } catch (e, stackTrace) {
      debugPrint("Error starting new adventure: $e\n$stackTrace");
      // Optionally, provide user feedback (e.g., using a messenger service)
      // messengerService.showError('Could not start the adventure. Please try again.');
    }
  }

  /// Handles the user action to navigate to the subscription screen (RF-010).
  ///
  /// Delegates the navigation task to the [NavigationService].
  void onGoToSubscription() {
    debugPrint("Navigating to Subscription screen.");
    _navigationService.goToSubscription();
  }

  /// Handles the user action to navigate to the instructions screen (RF-011).
  ///
  /// Delegates the navigation task to the [NavigationService].
  void onGoToInstructions() {
    debugPrint("Navigating to Instructions screen.");
    _navigationService.goToInstructions();
  }
}
