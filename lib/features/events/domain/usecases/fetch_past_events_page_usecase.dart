import '../entities/events_page.dart';
import '../repositories/events_repository.dart';

/// Fetches one past-events page from the network and caches it.
class FetchPastEventsPageUsecase {
  final EventsRepository _repository;

  const FetchPastEventsPageUsecase(this._repository);

  Future<EventsPage> call(int page) => _repository.fetchPastEventsPage(page);
}
