import 'package:flutter/foundation.dart'; // Para ChangeNotifier
import '../models/adventure.dart';
import '../models/scenario.dart';
import '../repositories/adventure_repository.dart';
import '../services/app_preferences.dart';
import '../services/navigation_service.dart';
import '../services/scenario_loader.dart';
import 'package:uuid/uuid.dart'; // Importa o pacote uuid

/// Orchestrates the logic and data flow for the Main Screen.
///
/// Acts as an intermediary between the Model/Data Access layers
/// (`AdventureRepository`, `ScenarioLoader`) and the View (`MainScreenView`),
/// managing the screen's state and handling user interactions.
/// Uses [ChangeNotifier] to notify listeners (typically the View) about state changes.
class MainScreenController with ChangeNotifier {
  /// Repository for accessing adventure data.
  final AdventureRepository _adventureRepo;

  /// Service for loading available scenarios.
  final ScenarioLoader _scenarioLoader;

  /// Service for handling navigation between screens.
  final NavigationService _navigationService;

  /// Service for accessing application preferences (e.g., first launch status).
  final AppPreferences _appPreferences;

  /// Constructor requiring all dependencies.
  ///
  /// Initializes the controller with the necessary services and repositories.
  MainScreenController({
    required AdventureRepository adventureRepo,
    required ScenarioLoader scenarioLoader,
    required NavigationService navigationService,
    required AppPreferences appPreferences,
  }) : _adventureRepo = adventureRepo,
       _scenarioLoader = scenarioLoader,
       _navigationService = navigationService,
       _appPreferences = appPreferences;

  // --- State Attributes ---

  /// List of ongoing adventures for the user.
  /// Private variable holding the state.
  List<Adventure> _ongoingAdventures = [];

  /// Public getter for the ongoing adventures list.
  List<Adventure> get ongoingAdventures => _ongoingAdventures;

  /// List of available scenarios to start new adventures.
  /// Private variable holding the state.
  List<Scenario> _availableScenarios = [];

  /// Public getter for the available scenarios list.
  List<Scenario> get availableScenarios => _availableScenarios;

  /// Flag indicating if ongoing adventures are currently being loaded.
  /// Private variable holding the state.
  bool _isLoadingAdventures = false;

  /// Public getter for the adventures loading state.
  bool get isLoadingAdventures => _isLoadingAdventures;

  /// Flag indicating if available scenarios are currently being loaded.
  /// Private variable holding the state.
  bool _isLoadingScenarios = false;

  /// Public getter for the scenarios loading state.
  bool get isLoadingScenarios => _isLoadingScenarios;

  /// Stores an error message if scenario loading fails (RF-008).
  /// Private variable holding the state.
  String? _scenarioLoadingError;

  /// Public getter for the scenario loading error message.
  String? get scenarioLoadingError => _scenarioLoadingError;

  /// Flag indicating if this is the first launch of the application (RF-012).
  /// Primarily used internally during initialization.
  bool _isFirstLaunch = false;
  // No public getter needed currently, as it's mainly for internal logic during init.

  // --- Private Helper Methods ---

  /// Sets the loading state for adventures and notifies listeners.
  ///
  /// [value] The new loading state.
  void _setIsLoadingAdventures(bool value) {
    if (_isLoadingAdventures != value) {
      _isLoadingAdventures = value;
      notifyListeners();
    }
  }

  /// Sets the loading state for scenarios and notifies listeners.
  ///
  /// [value] The new loading state.
  void _setIsLoadingScenarios(bool value) {
    if (_isLoadingScenarios != value) {
      _isLoadingScenarios = value;
      notifyListeners();
    }
  }

  /// Updates the list of ongoing adventures and notifies listeners.
  ///
  /// [adventures] The new list of adventures.
  void _setOngoingAdventures(List<Adventure> adventures) {
    _ongoingAdventures = adventures;
    // No need to notifyListeners here if it's always called within a method
    // that already handles notification (like loadData).
  }

  /// Updates the list of available scenarios and notifies listeners.
  ///
  /// [scenarios] The new list of scenarios.
  void _setAvailableScenarios(List<Scenario> scenarios) {
    _availableScenarios = scenarios;
    // No need to notifyListeners here if it's always called within a method
    // that already handles notification (like loadData).
  }

  /// Sets the scenario loading error message and notifies listeners.
  ///
  /// [error] The error message string, or null to clear the error.
  void _setScenarioLoadingError(String? error) {
    if (_scenarioLoadingError != error) {
      _scenarioLoadingError = error;
      // No need to notifyListeners here if it's always called within a method
      // that already handles notification (like loadData).
    }
  }

  /// Checks if it's the first time the application is launched (RF-012).
  ///
  /// If it is, sets the [_isFirstLaunch] flag and potentially triggers
  /// navigation to an onboarding/instructions screen via [NavigationService] (RF-013).
  /// Updates the preference to mark the first launch as completed.
  Future<void> _checkFirstLaunch() async {
    try {
      _isFirstLaunch = await _appPreferences.isFirstLaunch();
      if (_isFirstLaunch) {
        // Requirement RF-013 might imply navigating here.
        // Example: Navigate to instructions on first launch.
        // _navigationService.goToInstructions(); // Uncomment if needed per RF-013

        // Mark first launch as completed so this block doesn't run again.
        await _appPreferences.setFirstLaunchCompleted();
        debugPrint("First launch detected and marked as completed.");

        // Notify listeners only if the View needs to react specifically to the first launch state.
        // notifyListeners();
      } else {
        debugPrint("Not the first launch.");
      }
    } catch (e) {
      debugPrint("Error checking first launch status: $e");
      // Decide how to handle errors: maybe proceed as if not first launch?
      _isFirstLaunch = false;
    }
  }

  // --- Public Methods ---

  /// Initializes the controller.
  ///
  /// Should be called once when the associated screen/widget is initialized.
  /// It first checks if this is the application's first launch (RF-012)
  /// and then proceeds to load the necessary data (adventures and scenarios).
  Future<void> initialize() async {
    debugPrint("MainScreenController initializing...");
    // RF-012: Check first launch status before loading main data.
    await _checkFirstLaunch();

    // Load initial data required for the main screen.
    await loadData();
    debugPrint("MainScreenController initialization complete.");
  }

  /// Fetches ongoing adventures from [AdventureRepository] and available
  /// scenarios from [ScenarioLoader] (RF-008).
  ///
  /// Updates the corresponding loading states ([isLoadingAdventures], [isLoadingScenarios])
  /// and handles potential errors during scenario loading by setting [scenarioLoadingError].
  /// Notifies listeners upon completion or error.
  Future<void> loadData() async {
    debugPrint("Loading main screen data...");
    // Set loading states and clear previous errors
    _setIsLoadingAdventures(true);
    _setIsLoadingScenarios(true);
    _setScenarioLoadingError(null);
    // Use a single notifyListeners call after initial state changes
    notifyListeners();

    bool adventureSuccess = false;
    bool scenarioSuccess = false;

    // Fetch ongoing adventures
    try {
      // Correção: Usar getAllAdventures para buscar todas as aventuras
      final adventures = await _adventureRepo.getAllAdventures();
      _setOngoingAdventures(adventures);
      adventureSuccess = true;
      debugPrint("Ongoing adventures loaded: ${adventures.length}");
    } catch (e, stackTrace) {
      debugPrint("Error loading ongoing adventures: $e\n$stackTrace");
      _setOngoingAdventures([]); // Set to empty list on error
    } finally {
      _setIsLoadingAdventures(false);
      // Don't notify yet, wait until both operations are done or failed.
    }

    // Fetch available scenarios
    try {
      final scenarios = await _scenarioLoader.loadScenarios();
      _setAvailableScenarios(scenarios);
      scenarioSuccess = true;
      _setScenarioLoadingError(null); // Clear error on success
      debugPrint("Available scenarios loaded: ${scenarios.length}");
    } catch (e, stackTrace) {
      debugPrint("Error loading scenarios: $e\n$stackTrace");
      // RF-008: Capture and store scenario loading error
      _setScenarioLoadingError('Failed to load scenarios. Please try again.');
      _setAvailableScenarios([]); // Set to empty list on error
    } finally {
      _setIsLoadingScenarios(false);
      // Notify listeners now that both loading operations are complete or have failed.
      notifyListeners();
    }
    debugPrint(
      "Main screen data loading finished. Adventure success: $adventureSuccess, Scenario success: $scenarioSuccess",
    );
  }

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
