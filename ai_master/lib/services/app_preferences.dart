/// Defines a contract for accessing and modifying application preferences.
///
/// This abstraction allows decoupling preference storage logic from specific
/// implementations (like shared_preferences), improving testability and flexibility.
abstract class AppPreferences {
  /// Checks if this is the first time the application is launched.
  ///
  /// Returns `true` if it's the first launch, `false` otherwise.
  Future<bool> isFirstLaunch();

  /// Marks that the first launch sequence has been completed.
  Future<void> setFirstLaunchCompleted();

  // Add other preference methods as needed (e.g., theme, user settings).
}
