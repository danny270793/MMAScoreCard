import '../entities/fighter_profile.dart';
import '../repositories/events_repository.dart';

/// A fighter profile is fetched at most once per fighter: the cached copy is
/// served if present. Pass `refresh: true` (pull-to-refresh) to force a
/// re-fetch that overwrites the cache.
class GetFighterProfileUsecase {
  final EventsRepository _repository;

  const GetFighterProfileUsecase(this._repository);

  Future<FighterProfile> call(String fighterUrl, {bool refresh = false}) async {
    if (!refresh) {
      final cached = _repository.cachedFighterProfile(fighterUrl);
      if (cached != null) return cached;
    }
    return _repository.fetchFighterProfile(fighterUrl);
  }
}
