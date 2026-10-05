import '../entities/mma_event.dart';
import '../repositories/events_repository.dart';

/// Every past-events page already on disk, plus whether more pages exist.
class GetCachedPastEventsUsecase {
  final EventsRepository _repository;

  const GetCachedPastEventsUsecase(this._repository);

  ({Map<int, List<MmaEvent>> pages, bool hasMore}) call() => (
    pages: _repository.cachedPastEventPages(),
    hasMore: _repository.cachedPastEventsHasMore(),
  );
}
