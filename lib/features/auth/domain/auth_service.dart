class AuthUser {
  const AuthUser({required this.email});

  final String email;
}

abstract class AuthService {
  AuthUser? get currentUser;

  Stream<AuthUser?> get authStateChanges;

  Future<void> signIn({required String email, required String password});

  Future<void> signOut();

  Future<void> updateEmail(String email);

  Future<void> updatePassword(String password);
}
