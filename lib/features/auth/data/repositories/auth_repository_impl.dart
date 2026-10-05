import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remote;
  final AuthLocalDatasource _local;

  const AuthRepositoryImpl(this._remote, this._local);

  @override
  UserEntity? get currentUser => _remote.currentUser;

  @override
  Stream<UserEntity?> get authStateChanges => _remote.authStateChanges;

  @override
  bool get isGuest => _local.isGuest;

  @override
  Future<void> setGuest(bool value) => _local.setGuest(value);

  @override
  Future<void> signIn({required String email, required String password}) async {
    await _remote.signIn(email: email, password: password);
    await _local.setGuest(false);
  }

  @override
  Future<void> signOut() async {
    await _remote.signOut();
    await _local.setGuest(false);
  }

  @override
  Future<void> updateEmail({required String newEmail}) =>
      _remote.updateEmail(newEmail: newEmail);

  @override
  Future<void> updatePassword({required String newPassword}) =>
      _remote.updatePassword(newPassword: newPassword);
}
