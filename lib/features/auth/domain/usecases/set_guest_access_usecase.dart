import '../repositories/auth_repository.dart';

/// Turns "continue without account" on (guest) or off (show sign in).
class SetGuestAccessUsecase {
  final AuthRepository _repository;

  const SetGuestAccessUsecase(this._repository);

  Future<void> call(bool guest) => _repository.setGuest(guest);
}
