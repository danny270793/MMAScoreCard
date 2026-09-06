import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsRepository {
  AppSettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _themeModeKey = 'theme_mode';
  static const _languageCodeKey = 'language_code';

  ThemeMode loadThemeMode() {
    switch (_prefs.getString(_themeModeKey)) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    await _prefs.setString(_themeModeKey, mode.name);
  }

  String? loadLanguageCode() => _prefs.getString(_languageCodeKey);

  Future<void> saveLanguageCode(String? code) async {
    if (code == null) {
      await _prefs.remove(_languageCodeKey);
    } else {
      await _prefs.setString(_languageCodeKey, code);
    }
  }
}
