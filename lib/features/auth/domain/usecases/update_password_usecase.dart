import '../repositories/auth_repository.dart';

class UpdatePasswordUsecase {
  final AuthRepository _repository;

  const UpdatePasswordUsecase(this._repository);

  Future<void> call({required String newPassword}) =>
      _repository.updatePassword(newPassword: newPassword);
}
