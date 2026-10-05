import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/logger/app_logger.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthRemoteDatasource {
  UserEntity? get currentUser;

  Stream<UserEntity?> get authStateChanges;

  Future<void> signIn({required String email, required String password});

  Future<void> signOut();

  Future<void> updateEmail({required String newEmail});

  Future<void> updatePassword({required String newPassword});
}

class AuthSupabaseDatasource implements AuthRemoteDatasource {
  final SupabaseClient _client;

  const AuthSupabaseDatasource(this._client);

  @override
  UserEntity? get currentUser => _mapUser(_client.auth.currentUser);

  @override
  Stream<UserEntity?> get authStateChanges => _client.auth.onAuthStateChange
      .map((event) => _mapUser(event.session?.user));

  @override
  Future<void> signIn({required String email, required String password}) async {
    AppLogger.debug('signIn called');
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() {
    AppLogger.debug('signOut called');
    return _client.auth.signOut();
  }

  @override
  Future<void> updateEmail({required String newEmail}) async {
    AppLogger.debug('updateEmail called');
    await _client.auth.updateUser(UserAttributes(email: newEmail));
  }

  @override
  Future<void> updatePassword({required String newPassword}) async {
    AppLogger.debug('updatePassword called');
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  UserEntity? _mapUser(User? user) {
    if (user == null) return null;
    return UserEntity(email: user.email ?? '');
  }
}
