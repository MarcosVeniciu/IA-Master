import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core Application Components
import 'package:ai_master/controllers/main_screen_controller.dart';
import 'package:ai_master/features/main_screen/view/material_main_screen_view.dart';

// Models (Implicitly used by Controller/Repository)
// import 'package:ai_master/models/adventure.dart';
// import 'package:ai_master/models/scenario.dart';

// Services and Repositories (Dependencies)
import 'package:ai_master/repositories/adventure_repository.dart';
import 'package:ai_master/services/app_preferences.dart'; // Abstract class
import 'package:ai_master/services/shared_preferences_app_preferences.dart'; // Implementation
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

  /// Run the Flutter application.
  /// Uses `MultiProvider` to make all necessary services and controllers
  /// available throughout the widget tree.
  runApp(
    MultiProvider(
      providers: [
        // --- Service/Repository Providers ---
        // Provides singleton instances of services and repositories.
        // Using `.value` is efficient for already instantiated objects.

        /// Provides the application preferences service.
        Provider<AppPreferences>.value(value: appPreferences),

        /// Provides the database helper service.
        Provider<DatabaseHelper>.value(value: databaseHelper),

        /// Provides the adventure repository.
        Provider<AdventureRepository>.value(value: adventureRepository),

        /// Provides the scenario loader service.
        Provider<ScenarioLoader>.value(value: scenarioLoader),

        /// Provides the navigation service.
        Provider<NavigationService>.value(value: navigationService),

        // --- Controller Provider ---
        // Provides the main screen controller, which manages the state for the main view.
        // `ChangeNotifierProvider` automatically handles listener notifications.

        /// Creates and provides the `MainScreenController`.
        /// It reads its dependencies (`AdventureRepository`, `ScenarioLoader`, etc.)
        /// from the `context` using `context.read<T>()`.
        /// The `..initialize()` cascade calls the controller's initialization logic
        /// immediately after creation.
        ChangeNotifierProvider<MainScreenController>(
          create:
              (context) => MainScreenController(
                adventureRepo: context.read<AdventureRepository>(),
                scenarioLoader: context.read<ScenarioLoader>(),
                navigationService: context.read<NavigationService>(),
                appPreferences: context.read<AppPreferences>(),
              )..initialize(), // Initialize the controller after creation
        ),
      ],
      child: const MyApp(), // The root widget of the application
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
      home: MaterialMainScreenView(),

      /// Hides the debug banner in the top-right corner.
      debugShowCheckedModeBanner: false,
    );
  }
}
