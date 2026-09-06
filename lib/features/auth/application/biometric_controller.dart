import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/persistence/shared_preferences_provider.dart';

abstract class BiometricService {
  Future<bool> isAvailable();

  Future<bool> authenticate(String reason);
}

class LocalBiometricService implements BiometricService {
  LocalBiometricService(this._auth);

  final LocalAuthentication _auth;

  @override
  Future<bool> isAvailable() async {
    try {
      final supported = await _auth.isDeviceSupported();
      final types = await _auth.getAvailableBiometrics();
      return supported && (types.isNotEmpty || await _auth.canCheckBiometrics);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return LocalBiometricService(LocalAuthentication());
});

class BiometricState {
  const BiometricState({
    required this.enabled,
    required this.available,
    this.checking = false,
  });

  final bool enabled;
  final bool available;
  final bool checking;

  BiometricState copyWith({bool? enabled, bool? available, bool? checking}) {
    return BiometricState(
      enabled: enabled ?? this.enabled,
      available: available ?? this.available,
      checking: checking ?? this.checking,
    );
  }
}

class BiometricController extends Notifier<BiometricState> {
  static const preferenceKey = 'app_biometric_unlock_enabled';

  @override
  BiometricState build() {
    final enabled =
        ref.watch(sharedPreferencesProvider).getBool(preferenceKey) ?? false;
    unawaited(refreshAvailability());
    return BiometricState(enabled: enabled, available: false, checking: true);
  }

  Future<bool> refreshAvailability() async {
    final available = await ref.read(biometricServiceProvider).isAvailable();
    state = state.copyWith(available: available, checking: false);
    return available;
  }

  Future<bool> enableWithConfirmation(String reason) async {
    state = state.copyWith(checking: true);
    final available = await refreshAvailability();
    if (!available) return false;
    final confirmed = await ref
        .read(biometricServiceProvider)
        .authenticate(reason);
    if (!confirmed) return false;
    await _setEnabled(true);
    return true;
  }

  Future<void> disable() => _setEnabled(false);

  Future<bool> authenticate(String reason) {
    return ref.read(biometricServiceProvider).authenticate(reason);
  }

  Future<void> _setEnabled(bool enabled) async {
    await ref.read(sharedPreferencesProvider).setBool(preferenceKey, enabled);
    state = state.copyWith(enabled: enabled);
  }
}

final biometricControllerProvider =
    NotifierProvider<BiometricController, BiometricState>(
      BiometricController.new,
    );
