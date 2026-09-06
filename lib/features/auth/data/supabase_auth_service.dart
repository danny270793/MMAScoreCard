import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import '../domain/auth_service.dart';

class SupabaseAuthService implements AuthService {
  SupabaseAuthService(this._client);

  final SupabaseClient _client;

  @override
  AuthUser? get currentUser => _mapUser(_client.auth.currentUser);

  @override
  Stream<AuthUser?> get authStateChanges => _client.auth.onAuthStateChange.map(
    (event) => _mapUser(event.session?.user),
  );

  @override
  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  @override
  Future<void> updateEmail(String email) =>
      _client.auth.updateUser(UserAttributes(email: email));

  @override
  Future<void> updatePassword(String password) =>
      _client.auth.updateUser(UserAttributes(password: password));

  AuthUser? _mapUser(User? user) {
    if (user == null) return null;
    return AuthUser(email: user.email ?? '');
  }
}
