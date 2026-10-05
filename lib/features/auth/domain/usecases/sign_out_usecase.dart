import '../repositories/auth_repository.dart';

class SignOutUsecase {
  final AuthRepository _repository;

  const SignOutUsecase(this._repository);

  Future<void> call() => _repository.signOut();
}
