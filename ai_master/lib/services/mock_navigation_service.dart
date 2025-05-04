import 'package:flutter/foundation.dart'; // Para debugPrint
import 'navigation_service.dart';

/// A mock implementation of [NavigationService] for testing and development.
///
/// Prints navigation actions to the console instead of performing actual navigation.
/// This allows testing components that depend on navigation without needing a full
/// navigation setup (like GoRouter or Navigator).
class MockNavigationService implements NavigationService {
  /// Prints a debug message indicating navigation to the adventure screen.
  ///
  /// [adventureId] The ID of the adventure being navigated to.
  @override
  void goToAdventure(String adventureId) {
    debugPrint('[MockNavigationService] Navigating to Adventure: $adventureId');
  }

  /// Prints a debug message indicating navigation to the new adventure screen.
  ///
  /// [adventureId] The ID of the newly created adventure.
  @override
  void goToNewAdventure(String adventureId) {
    debugPrint(
      '[MockNavigationService] Navigating to New Adventure: $adventureId',
    );
  }

  /// Prints a debug message indicating navigation to the instructions screen.
  @override
  void goToInstructions() {
    debugPrint('[MockNavigationService] Navigating to Instructions');
  }

  /// Prints a debug message indicating navigation to the subscription screen.
  @override
  void goToSubscription() {
    debugPrint('[MockNavigationService] Navigating to Subscription');
  }

  /// Prints a debug message indicating a 'go back' action.
  @override
  void goBack() {
    debugPrint('[MockNavigationService] Navigating Back');
  }
}
