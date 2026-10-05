import 'package:shared_preferences/shared_preferences.dart';

/// Stores whether the user chose to keep using the app without an account.
class AuthLocalDatasource {
  const AuthLocalDatasource(this._prefs);

  static const guestPreferenceKey = 'continue_without_account';

  final SharedPreferences _prefs;

  bool get isGuest => _prefs.getBool(guestPreferenceKey) ?? false;

  Future<void> setGuest(bool value) =>
      _prefs.setBool(guestPreferenceKey, value);
}
