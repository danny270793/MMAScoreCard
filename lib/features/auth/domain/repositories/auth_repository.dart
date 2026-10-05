import '../entities/user_entity.dart';

abstract class AuthRepository {
  UserEntity? get currentUser;

  Stream<UserEntity?> get authStateChanges;

  /// True when the user picked "Continue without account".
  bool get isGuest;

  Future<void> setGuest(bool value);

  Future<void> signIn({required String email, required String password});

  Future<void> signOut();

  Future<void> updateEmail({required String newEmail});

  Future<void> updatePassword({required String newPassword});
}
