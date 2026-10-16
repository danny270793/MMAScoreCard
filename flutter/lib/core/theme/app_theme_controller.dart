import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persisted brightness: follow device, or fixed light / dark.
enum AppThemePreference {
  system,
  light,
  dark;

  static AppThemePreference fromStorage(String? raw) {
    switch (raw) {
      case 'light':
        return AppThemePreference.light;
      case 'dark':
        return AppThemePreference.dark;
      default:
        return AppThemePreference.system;
    }
  }

  String get storageValue => switch (this) {
    AppThemePreference.system => 'system',
    AppThemePreference.light => 'light',
    AppThemePreference.dark => 'dark',
  };

  ThemeMode get themeMode => switch (this) {
    AppThemePreference.system => ThemeMode.system,
    AppThemePreference.light => ThemeMode.light,
    AppThemePreference.dark => ThemeMode.dark,
  };
}

class AppThemeController extends ChangeNotifier {
  AppThemeController();

  /// Kept from the pre-migration settings repository so existing users keep
  /// their theme choice.
  static const _prefKey = 'theme_mode';

  AppThemePreference _preference = AppThemePreference.system;

  AppThemePreference get preference => _preference;

  ThemeMode get themeMode => _preference.themeMode;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _preference = AppThemePreference.fromStorage(prefs.getString(_prefKey));
    notifyListeners();
  }

  Future<void> setPreference(AppThemePreference value) async {
    if (_preference == value) return;
    _preference = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, value.storageValue);
  }
}
