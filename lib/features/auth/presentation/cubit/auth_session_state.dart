import 'package:equatable/equatable.dart';

enum AuthAccessMode { loading, signedOut, guest, authenticated }

/// Which part of the app the user can see: the sign-in screen, or the
/// events (as a guest or signed in).
class AuthSessionState extends Equatable {
  const AuthSessionState(this.mode);

  const AuthSessionState.loading() : this(AuthAccessMode.loading);

  final AuthAccessMode mode;

  bool get canBrowse =>
      mode == AuthAccessMode.guest || mode == AuthAccessMode.authenticated;

  @override
  List<Object?> get props => [mode];
}
