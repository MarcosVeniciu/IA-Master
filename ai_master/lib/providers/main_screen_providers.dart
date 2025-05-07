import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_master/models/adventure.dart';
import 'package:ai_master/models/scenario.dart';
import 'package:ai_master/models/scenario_data.dart'; // Importa ScenarioData
import 'package:ai_master/repositories/adventure_repository.dart';
import 'package:ai_master/services/app_preferences.dart';
import 'package:ai_master/services/database_helper.dart';
import 'package:ai_master/services/mock_navigation_service.dart';
import 'package:ai_master/services/navigation_service.dart';
import 'package:ai_master/services/scenario_loader.dart';
import 'package:ai_master/services/shared_preferences_app_preferences.dart';

/// Provides the singleton instance of [DatabaseHelper].
///
/// This provider ensures that only one instance of the database helper is used
/// throughout the application.
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  /// Returns the singleton instance obtained from [DatabaseHelper.instance].
  return DatabaseHelper.instance;
});

/// Provides the singleton instance of [AppPreferences] asynchronously.
///
/// This uses a [FutureProvider] because initializing SharedPreferences is an
/// asynchronous operation. It retrieves the instance using
/// [SharedPreferencesAppPreferences.getInstance].
final appPreferencesProvider = FutureProvider<AppPreferences>((ref) async {
  /// Asynchronously gets the singleton instance of the AppPreferences implementation.
  return await SharedPreferencesAppPreferences.getInstance();
});

/// Provides an instance of [NavigationService].
///
/// Currently, this provider is configured to return the [MockNavigationService]
/// implementation, suitable for testing or development environments where
/// actual navigation might not be needed or available.
final navigationServiceProvider = Provider<NavigationService>((ref) {
  /// Creates and returns a new instance of the mock navigation service.
  return MockNavigationService();
});

/// Provides an instance of [ScenarioLoader].
///
/// This service is responsible for loading scenario data, typically from assets.
final scenarioLoaderProvider = Provider<ScenarioLoader>((ref) {
  /// Creates and returns a new instance of ScenarioLoader.
  return ScenarioLoader();
});

/// Provides an instance of [AdventureRepository].
///
/// This repository handles data operations related to adventures. It depends
/// on the [DatabaseHelper] provided by [databaseHelperProvider].
final adventureRepositoryProvider = Provider<AdventureRepository>((ref) {
  /// Watches [databaseHelperProvider] to get the required [DatabaseHelper] instance.
  /// If [databaseHelperProvider] changes, this provider will rebuild.
  final dbHelper = ref.watch(databaseHelperProvider);

  /// Creates and returns a new instance of [AdventureRepository], injecting the
  /// obtained [DatabaseHelper].
  return AdventureRepository(dbHelper: dbHelper);
});

/// Provides the list of available scenarios asynchronously.
///
/// This [FutureProvider] uses the [scenarioLoaderProvider] to load the scenarios
/// (which now include pre-decoded images as ScenarioData).
/// It automatically handles loading, data, and error states.
final availableScenariosProvider = FutureProvider<List<ScenarioData>>((
  ref,
) async {
  /// Watches the [scenarioLoaderProvider] to get the [ScenarioLoader] instance.
  final loader = ref.watch(scenarioLoaderProvider);

  /// Calls the asynchronous method to load scenarios.
  /// This now returns Future<List<ScenarioData>>.
  return await loader.loadScenarios();
});

/// Provides the list of ongoing adventures asynchronously.
///
/// This [FutureProvider] uses the [adventureRepositoryProvider] to fetch all adventures.
/// It automatically handles loading, data, and error states.
final ongoingAdventuresProvider = FutureProvider<List<Adventure>>((ref) async {
  /// Watches the [adventureRepositoryProvider] to get the [AdventureRepository] instance.
  final repository = ref.watch(adventureRepositoryProvider);

  /// Calls the asynchronous method to get all adventures from the repository.
  return await repository.getAllAdventures();
});
