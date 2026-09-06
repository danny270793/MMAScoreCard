import '../domain/entities/event_fight.dart';
import '../domain/entities/events_page.dart';
import '../domain/entities/fighter_profile.dart';
import '../domain/entities/mma_event.dart';
import '../domain/repositories/mma_events_repository.dart';

/// Tries each source in order, falling back to the next one if a source
/// throws. This is what lets us swap/add MMA event sources (Sherdog,
/// UFC.com, ...) without the application layer knowing which one served
/// the data.
class CompositeMmaEventsRepository implements MmaEventsRepository {
  CompositeMmaEventsRepository(this._sources)
    : assert(_sources.isNotEmpty, 'Provide at least one source');

  final List<MmaEventsRepository> _sources;

  @override
  Future<List<MmaEvent>> fetchUpcomingEvents() =>
      _tryEach((source) => source.fetchUpcomingEvents());

  @override
  Future<EventsPage> fetchPastEvents({required int page}) =>
      _tryEach((source) => source.fetchPastEvents(page: page));

  @override
  Future<List<EventFight>> fetchEventFights(String eventUrl) =>
      _tryEach((source) => source.fetchEventFights(eventUrl));

  @override
  Future<FighterProfile> fetchFighterProfile(String fighterUrl) =>
      _tryEach((source) => source.fetchFighterProfile(fighterUrl));

  Future<T> _tryEach<T>(
    Future<T> Function(MmaEventsRepository source) action,
  ) async {
    Object? lastError;
    for (final source in _sources) {
      try {
        return await action(source);
      } catch (e) {
        lastError = e;
      }
    }
    throw MmaEventsException('All MMA event sources failed', lastError);
  }
}
