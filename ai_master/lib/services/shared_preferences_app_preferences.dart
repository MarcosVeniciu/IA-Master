import 'package:shared_preferences/shared_preferences.dart';
import 'app_preferences.dart';

/// An implementation of [AppPreferences] using the `shared_preferences` package.
///
/// Stores application preferences locally on the device.
class SharedPreferencesAppPreferences implements AppPreferences {
  /// The key used to store the first launch flag in SharedPreferences.
  static const String _firstLaunchKey = 'first_launch_completed';

  /// The underlying SharedPreferences instance.
  final SharedPreferences _prefs;

  /// Private constructor to ensure initialization via [getInstance].
  SharedPreferencesAppPreferences._(this._prefs);

  /// Creates and initializes an instance of [SharedPreferencesAppPreferences].
  ///
  /// This factory method ensures that the SharedPreferences instance is
  /// obtained asynchronously before creating the AppPreferences object.
  static Future<SharedPreferencesAppPreferences> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPreferencesAppPreferences._(prefs);
  }

  /// Checks if this is the first time the application is launched.
  ///
  /// Reads the [_firstLaunchKey] from SharedPreferences. If the key doesn't exist
  /// or is false, it assumes it's the first launch.
  ///
  /// Returns `true` if it's the first launch, `false` otherwise.
  @override
  Future<bool> isFirstLaunch() async {
    // If the key doesn't exist, `getBool` returns null.
    // We treat null as meaning the first launch hasn't completed yet.
    return !(_prefs.getBool(_firstLaunchKey) ?? false);
  }

  /// Marks that the first launch sequence has been completed.
  ///
  /// Sets the [_firstLaunchKey] to `true` in SharedPreferences.
  @override
  Future<void> setFirstLaunchCompleted() async {
    await _prefs.setBool(_firstLaunchKey, true);
  }
}
