import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persisted UI language: follow device, or fixed English / Spanish.
enum AppLanguagePreference {
  system,
  en,
  es;

  static AppLanguagePreference fromStorage(String? raw) {
    switch (raw) {
      case 'en':
        return AppLanguagePreference.en;
      case 'es':
        return AppLanguagePreference.es;
      default:
        return AppLanguagePreference.system;
    }
  }

  /// `null` means "follow the device" (the key is removed from storage).
  String? get storageValue => switch (this) {
    AppLanguagePreference.system => null,
    AppLanguagePreference.en => 'en',
    AppLanguagePreference.es => 'es',
  };

  /// `null` means use the device locale (resolved via [localeResolutionCallback]).
  Locale? get materialLocale => switch (this) {
    AppLanguagePreference.system => null,
    AppLanguagePreference.en => const Locale('en'),
    AppLanguagePreference.es => const Locale('es'),
  };
}

class AppLocaleController extends ChangeNotifier {
  AppLocaleController();

  /// Kept from the pre-migration settings repository so existing users keep
  /// their language choice.
  static const _prefKey = 'language_code';

  AppLanguagePreference _preference = AppLanguagePreference.system;

  AppLanguagePreference get preference => _preference;

  Locale? get materialAppLocale => _preference.materialLocale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _preference = AppLanguagePreference.fromStorage(prefs.getString(_prefKey));
    notifyListeners();
  }

  Future<void> setPreference(AppLanguagePreference value) async {
    if (_preference == value) return;
    _preference = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final stored = value.storageValue;
    if (stored == null) {
      await prefs.remove(_prefKey);
    } else {
      await prefs.setString(_prefKey, stored);
    }
  }
}
