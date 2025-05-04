import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ai_master/controllers/main_screen_controller.dart';
import 'package:ai_master/features/main_screen/view/material_main_screen_view.dart';
import 'package:ai_master/models/adventure.dart';
import 'package:ai_master/models/scenario.dart';
import 'package:ai_master/repositories/adventure_repository.dart'; // Import adicionado
import 'package:ai_master/services/scenario_loader.dart'; // Import adicionado
import 'package:ai_master/services/navigation_service.dart'; // Import adicionado
import 'package:ai_master/services/app_preferences.dart'; // Import adicionado

/// A fake implementation of [MainScreenController] for widget testing.
///
/// Allows setting specific states (loading, error, data) to test how the UI reacts.
class FakeMainScreenController extends ChangeNotifier
    implements MainScreenController {
  bool _isLoadingAdventures = false;
  bool _isLoadingScenarios = false;
  List<Adventure> _ongoingAdventures = [];
  List<Scenario> _availableScenarios = [];
  String? _scenarioLoadingError;

  // --- Setters for test setup ---
  set isLoadingAdventures(bool value) {
    _isLoadingAdventures = value;
    notifyListeners();
  }

  set isLoadingScenarios(bool value) {
    _isLoadingScenarios = value;
    notifyListeners();
  }

  set ongoingAdventures(List<Adventure> value) {
    _ongoingAdventures = value;
    notifyListeners();
  }

  set availableScenarios(List<Scenario> value) {
    _availableScenarios = value;
    notifyListeners();
  }

  set scenarioLoadingError(String? value) {
    _scenarioLoadingError = value;
    notifyListeners();
  }

  // --- Getters used by the View ---
  @override
  bool get isLoadingAdventures => _isLoadingAdventures;

  @override
  bool get isLoadingScenarios => _isLoadingScenarios;

  @override
  List<Adventure> get ongoingAdventures => _ongoingAdventures;

  @override
  List<Scenario> get availableScenarios => _availableScenarios;

  @override
  String? get scenarioLoadingError => _scenarioLoadingError;

  // --- Mocked methods (not strictly needed for these tests, but required by interface) ---
  @override
  Future<void> initialize() async {
    // No-op
  }

  @override
  Future<void> loadData() async {
    // No-op
  }

  @override
  void onContinueAdventure(String adventureId) {
    // No-op
  }

  @override
  Future<void> onStartScenario(Scenario scenario) async {
    // Correct signature
    // No-op
  }

  // Add missing methods
  @override
  Future<void> onGoToInstructions() async {
    // No-op
  }

  @override
  Future<void> onGoToSubscription() async {
    // No-op
  }

  // @override removido - não está na interface?
  void onSearchQueryChanged(String query) {
    // No-op
  }

  // @override removido - não está na interface?
  void onFilterPressed() {
    // No-op
  }

  // --- Inherited from ChangeNotifier ---
  // addListener, removeListener, dispose, notifyListeners are inherited
  // hasListeners is also inherited but not part of the MainScreenController interface

  // --- Required by MainScreenController interface but not directly used by View state ---
  // These are late final and will throw if accessed, which is fine for these tests.
  // @override removido - não está na interface?
  late final AdventureRepository adventureRepo; // Tipo adicionado
  // @override removido - não está na interface?
  late final ScenarioLoader scenarioLoader; // Tipo adicionado
  // @override removido - não está na interface?
  late final NavigationService navigationService; // Tipo adicionado
  // @override removido - não está na interface?
  late final AppPreferences appPreferences; // Tipo adicionado
}

void main() {
  /// Helper function to build the MaterialMainScreenView with a fake controller.
  Widget buildTestableWidget(FakeMainScreenController controller) {
    return ChangeNotifierProvider<MainScreenController>.value(
      value: controller,
      child: const MaterialApp(home: MaterialMainScreenView()),
    );
  }

  /// Test group for Main Screen empty states.
  group('MaterialMainScreenView Empty States', () {
    /// Tests if the correct message is shown when there are no ongoing adventures.
    testWidgets('Shows correct message when ongoing adventures list is empty', (
      WidgetTester tester,
    ) async {
      // Arrange: Create a controller with empty adventures and some scenarios (to isolate the test)
      final fakeController = FakeMainScreenController();
      fakeController.isLoadingAdventures = false;
      fakeController.ongoingAdventures = [];
      fakeController.isLoadingScenarios = false; // Assume scenarios loaded
      // Correctly instantiate Scenario with all required fields
      fakeController.availableScenarios = [
        const Scenario(
          title: 'Dummy Scenario',
          author: 'Test Author',
          date: '2025-04-30',
          genre: 'Test Genre',
          ambiance: 'Test Ambiance',
          imageBase64: null,
          origins: [],
          plots: [],
          scenes: [],
          bankOfIdeas: [],
          rules: [],
          license: 'Test License',
          credits: 'Test Credits',
        ),
      ];
      fakeController.scenarioLoadingError = null;

      // Act: Build the widget tree
      await tester.pumpWidget(buildTestableWidget(fakeController));

      // Assert: Verify the empty adventures message is displayed
      expect(find.text('Ongoing Adventures'), findsOneWidget); // Section title
      expect(
        find.text('No adventures started yet. Begin one below!'),
        findsOneWidget,
      );
      expect(
        find.byType(CircularProgressIndicator),
        findsNothing,
      ); // No loading indicators
    });

    /// Tests if the correct messages are shown when there are no available scenarios.
    testWidgets('Shows correct messages when available scenarios list is empty', (
      WidgetTester tester,
    ) async {
      // Arrange: Create a controller with empty scenarios and some adventures (to isolate the test)
      final fakeController = FakeMainScreenController();
      fakeController.isLoadingScenarios = false;
      fakeController.availableScenarios = [];
      fakeController.scenarioLoadingError = null;
      fakeController.isLoadingAdventures = false; // Assume adventures loaded
      // Correctly instantiate Adventure with required fields
      fakeController.ongoingAdventures = [
        const Adventure(
          id: 'adv1',
          scenarioTitle: 'Dummy Adv', // Renomeado
          gameState: '{}', // Renomeado e Use empty JSON string
          lastPlayedDate: 0, // Renomeado
          // progressIndicator, syncStatus, messages use defaults
        ),
      ];

      // Act: Build the widget tree
      await tester.pumpWidget(buildTestableWidget(fakeController));
      await tester.pumpAndSettle(); // Allow layout to settle

      // Assert: Verify the empty scenarios messages are displayed
      // 1. Highlight Section
      expect(find.text('No highlights available.'), findsOneWidget);

      // 2. Available Scenarios Section
      expect(find.text('Available Scenarios'), findsOneWidget); // Section title
      expect(
        find.text('No scenarios available at the moment.'),
        findsOneWidget,
      );
      expect(
        find.byType(CircularProgressIndicator),
        findsNothing,
      ); // No loading indicators
    });
  });
}
