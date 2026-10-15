import '../entities/event_fight.dart';
import '../repositories/events_repository.dart';

/// A fight card is fetched at most once per event: the cached copy is served
/// if present. Pass `refresh: true` (pull-to-refresh) to force a re-fetch
/// that overwrites the cache.
class GetEventFightsUsecase {
  final EventsRepository _repository;

  const GetEventFightsUsecase(this._repository);

  Future<List<EventFight>> call(String eventUrl, {bool refresh = false}) async {
    if (!refresh) {
      final cached = _repository.cachedEventFights(eventUrl);
      if (cached != null) return cached;
    }
    return _repository.fetchEventFights(eventUrl);
  }
}
