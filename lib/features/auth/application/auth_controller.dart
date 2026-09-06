import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import '../../../core/persistence/shared_preferences_provider.dart';
import '../data/supabase_auth_service.dart';
import '../domain/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return SupabaseAuthService(Supabase.instance.client);
});

enum AuthAccessMode { loading, signedOut, guest, authenticated }

class AuthAccessState {
  const AuthAccessState({required this.mode, this.isBusy = false, this.error});

  const AuthAccessState.loading() : this(mode: AuthAccessMode.loading);

  final AuthAccessMode mode;
  final bool isBusy;
  final String? error;

  AuthAccessState copyWith({
    AuthAccessMode? mode,
    bool? isBusy,
    String? error,
    bool clearError = false,
  }) {
    return AuthAccessState(
      mode: mode ?? this.mode,
      isBusy: isBusy ?? this.isBusy,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class AuthController extends Notifier<AuthAccessState> {
  static const guestPreferenceKey = 'continue_without_account';

  StreamSubscription<AuthUser?>? _subscription;

  @override
  AuthAccessState build() {
    ref.onDispose(() => _subscription?.cancel());
    Future.microtask(_initialize);
    return const AuthAccessState.loading();
  }

  Future<void> _initialize() async {
    final auth = ref.read(authServiceProvider);
    final prefs = ref.read(sharedPreferencesProvider);
    final guest = prefs.getBool(guestPreferenceKey) ?? false;
    state = AuthAccessState(
      mode: auth.currentUser != null
          ? AuthAccessMode.authenticated
          : guest
          ? AuthAccessMode.guest
          : AuthAccessMode.signedOut,
    );
    _subscription = auth.authStateChanges.listen((user) {
      if (user != null) {
        state = const AuthAccessState(mode: AuthAccessMode.authenticated);
      } else {
        final remainsGuest =
            ref.read(sharedPreferencesProvider).getBool(guestPreferenceKey) ??
            false;
        state = AuthAccessState(
          mode: remainsGuest ? AuthAccessMode.guest : AuthAccessMode.signedOut,
        );
      }
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(isBusy: true, clearError: true);
    try {
      await ref
          .read(authServiceProvider)
          .signIn(email: email, password: password);
      await ref
          .read(sharedPreferencesProvider)
          .setBool(guestPreferenceKey, false);
      state = const AuthAccessState(mode: AuthAccessMode.authenticated);
    } on AuthException catch (error) {
      state = state.copyWith(isBusy: false, error: error.message);
    } catch (_) {
      state = state.copyWith(isBusy: false, error: 'unexpected');
    }
  }

  Future<void> continueAsGuest() async {
    await ref.read(sharedPreferencesProvider).setBool(guestPreferenceKey, true);
    state = const AuthAccessState(mode: AuthAccessMode.guest);
  }

  Future<void> showSignIn() async {
    await ref
        .read(sharedPreferencesProvider)
        .setBool(guestPreferenceKey, false);
    state = const AuthAccessState(mode: AuthAccessMode.signedOut);
  }

  Future<void> signOut() async {
    state = state.copyWith(isBusy: true, clearError: true);
    try {
      await ref.read(authServiceProvider).signOut();
      await ref
          .read(sharedPreferencesProvider)
          .setBool(guestPreferenceKey, false);
      state = const AuthAccessState(mode: AuthAccessMode.signedOut);
    } on AuthException catch (error) {
      state = state.copyWith(isBusy: false, error: error.message);
    } catch (_) {
      state = state.copyWith(isBusy: false, error: 'unexpected');
    }
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthAccessState>(AuthController.new);
