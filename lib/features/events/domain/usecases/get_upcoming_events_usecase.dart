import '../entities/mma_event.dart';
import '../repositories/events_repository.dart';

/// The upcoming-events request is only ever fired once: if a cached list
/// exists it's served as-is. Pass `refresh: true` (pull-to-refresh, error
/// retry) to force a re-fetch that overwrites the cache.
class GetUpcomingEventsUsecase {
  final EventsRepository _repository;

  const GetUpcomingEventsUsecase(this._repository);

  Future<List<MmaEvent>> call({bool refresh = false}) async {
    if (!refresh) {
      final cached = _repository.cachedUpcomingEvents();
      if (cached != null) return cached;
    }
    return _repository.fetchUpcomingEvents();
  }
}
