import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper over the platform authenticator so it can be faked in tests.
abstract class BiometricService {
  Future<bool> isAvailable();

  Future<bool> authenticate(String reason);
}

class LocalBiometricService implements BiometricService {
  LocalBiometricService([LocalAuthentication? auth])
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> isAvailable() async {
    try {
      final supported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      final types = await _auth.getAvailableBiometrics();
      return supported && (types.isNotEmpty || canCheck);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }
}

/// Persists whether the user wants biometric (Face ID / fingerprint) app unlock.
///
/// This controller only stores the preference and reports hardware availability;
/// the app shell calls [authenticate] when gating access if [enabled] is true.
class AppBiometricUnlockController extends ChangeNotifier {
  AppBiometricUnlockController(this._service);

  static const _prefKey = 'app_biometric_unlock_enabled';

  final BiometricService _service;

  bool _enabled = false;
  bool _authenticatorAvailable = false;

  bool get enabled => _enabled;

  /// True when the device can authenticate with an enrolled biometric method.
  bool get authenticatorAvailable => _authenticatorAvailable;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_prefKey) ?? false;
    await refreshAuthenticatorAvailability();
    notifyListeners();
  }

  /// Call after OS settings may have changed (e.g. user enrolled a new fingerprint).
  Future<void> refreshAuthenticatorAvailability() async {
    _authenticatorAvailable = await _service.isAvailable();
    notifyListeners();
  }

  Future<bool> authenticate(String reason) => _service.authenticate(reason);

  Future<void> setEnabled(bool value) async {
    if (_enabled == value) return;
    _enabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, value);
  }
}
