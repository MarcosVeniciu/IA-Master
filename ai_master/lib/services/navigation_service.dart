import 'package:flutter/material.dart';

/// Abstract interface for navigation operations within the application.
///
/// Defines a contract for navigating between different screens or routes.
/// Implementations can use various navigation strategies (e.g., Navigator 1.0, GoRouter).
abstract class NavigationService {
  /// Navigates to the screen displaying details of a specific adventure.
  ///
  /// [adventureId] The unique identifier of the adventure to display.
  void goToAdventure(String adventureId);

  /// Navigates to the screen for creating or starting a new adventure.
  ///
  /// [adventureId] The unique identifier associated with the new adventure session.
  void goToNewAdventure(String adventureId);

  /// Navigates to the application's instructions or help screen.
  void goToInstructions();

  /// Navigates to the subscription management screen.
  void goToSubscription();

  /// Navigates back to the previous screen in the navigation stack.
  void goBack();
}

/// A concrete implementation of [NavigationService] using Flutter's Navigator 1.0.
///
/// Requires a [GlobalKey<NavigatorState>] to interact with the root navigator.
/// Assumes named routes are configured in the [MaterialApp].
class AppNavigationService implements NavigationService {
  /// A global key to access the [NavigatorState] of the root [MaterialApp].
  ///
  /// This key must be assigned to the `navigatorKey` property of the [MaterialApp].
  final GlobalKey<NavigatorState> navigatorKey;

  /// Creates an instance of [AppNavigationService].
  ///
  /// [navigatorKey] is required to perform navigation actions.
  AppNavigationService({required this.navigatorKey});

  /// Navigates to the adventure detail screen using a named route.
  ///
  /// Assumes a route named '/adventure' is defined, potentially taking
  /// [adventureId] as an argument or part of the route path.
  /// TODO: Define actual route name and argument passing mechanism.
  @override
  void goToAdventure(String adventureId) {
    // Example: Using pushNamed with arguments
    navigatorKey.currentState?.pushNamed('/adventure', arguments: adventureId);
    // Alternative: If route includes ID: navigatorKey.currentState?.pushNamed('/adventure/$adventureId');
  }

  /// Navigates to the new adventure screen using a named route.
  ///
  /// Assumes a route named '/new_adventure' is defined.
  /// TODO: Define actual route name.
  @override
  void goToNewAdventure(String adventureId) {
    // Example: Using pushNamed
    navigatorKey.currentState?.pushNamed(
      '/new_adventure',
      arguments: adventureId,
    );
  }

  /// Navigates to the instructions screen using a named route.
  ///
  /// Assumes a route named '/instructions' is defined.
  /// TODO: Define actual route name.
  @override
  void goToInstructions() {
    navigatorKey.currentState?.pushNamed('/instructions');
  }

  /// Navigates to the subscription screen using a named route.
  ///
  /// Assumes a route named '/subscription' is defined.
  /// TODO: Define actual route name.
  @override
  void goToSubscription() {
    navigatorKey.currentState?.pushNamed('/subscription');
  }

  /// Pops the current route off the navigator stack.
  @override
  void goBack() {
    navigatorKey.currentState?.pop();
  }
}
