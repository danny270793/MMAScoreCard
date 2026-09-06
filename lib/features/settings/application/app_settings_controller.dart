import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/persistence/shared_preferences_provider.dart';
import '../data/app_settings_repository.dart';

final appSettingsRepositoryProvider = Provider<AppSettingsRepository>((ref) {
  return AppSettingsRepository(ref.watch(sharedPreferencesProvider));
});

class AppSettingsState {
  final ThemeMode themeMode;

  /// Null means "follow the device's system language".
  final Locale? locale;

  const AppSettingsState({required this.themeMode, required this.locale});
}

class AppSettingsController extends Notifier<AppSettingsState> {
  @override
  AppSettingsState build() {
    final repository = ref.watch(appSettingsRepositoryProvider);
    final languageCode = repository.loadLanguageCode();
    return AppSettingsState(
      themeMode: repository.loadThemeMode(),
      locale: languageCode == null ? null : Locale(languageCode),
    );
  }

  void setThemeMode(ThemeMode mode) {
    state = AppSettingsState(themeMode: mode, locale: state.locale);
    ref.read(appSettingsRepositoryProvider).saveThemeMode(mode);
  }

  void setLocale(Locale? locale) {
    state = AppSettingsState(themeMode: state.themeMode, locale: locale);
    ref
        .read(appSettingsRepositoryProvider)
        .saveLanguageCode(locale?.languageCode);
  }
}

final appSettingsControllerProvider =
    NotifierProvider<AppSettingsController, AppSettingsState>(
      AppSettingsController.new,
    );
