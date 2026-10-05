import '../repositories/auth_repository.dart';

class UpdateEmailUsecase {
  final AuthRepository _repository;

  const UpdateEmailUsecase(this._repository);

  Future<void> call({required String newEmail}) =>
      _repository.updateEmail(newEmail: newEmail.trim());
}
