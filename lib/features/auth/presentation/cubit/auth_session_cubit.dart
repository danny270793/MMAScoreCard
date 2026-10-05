import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/set_guest_access_usecase.dart';
import 'auth_session_state.dart';

/// App-wide auth gate: tracks the Supabase session plus the persisted
/// "continue without account" choice. Registered as a singleton so the
/// router can listen to it for redirects.
class AuthSessionCubit extends Cubit<AuthSessionState> {
  AuthSessionCubit(this._repository, this._setGuestAccess)
    : super(const AuthSessionState.loading());

  final AuthRepository _repository;
  final SetGuestAccessUsecase _setGuestAccess;
  StreamSubscription<UserEntity?>? _subscription;

  UserEntity? get currentUser => _repository.currentUser;

  void start() {
    emit(AuthSessionState(_resolve(_repository.currentUser)));
    _subscription ??= _repository.authStateChanges.listen((user) {
      if (!isClosed) emit(AuthSessionState(_resolve(user)));
    });
  }

  AuthAccessMode _resolve(UserEntity? user) {
    if (user != null) return AuthAccessMode.authenticated;
    return _repository.isGuest
        ? AuthAccessMode.guest
        : AuthAccessMode.signedOut;
  }

  /// Called after a successful sign in, without waiting for the auth stream.
  void markAuthenticated() =>
      emit(const AuthSessionState(AuthAccessMode.authenticated));

  /// Called after a successful sign out.
  void markSignedOut() =>
      emit(const AuthSessionState(AuthAccessMode.signedOut));

  Future<void> continueAsGuest() async {
    await _setGuestAccess(true);
    emit(const AuthSessionState(AuthAccessMode.guest));
  }

  /// Leaves guest mode and shows the sign-in screen.
  Future<void> showSignIn() async {
    await _setGuestAccess(false);
    emit(const AuthSessionState(AuthAccessMode.signedOut));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
