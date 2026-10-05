import '../../domain/entities/cached_request_info.dart';
import '../../domain/entities/event_fight.dart';
import '../../domain/entities/events_page.dart';
import '../../domain/entities/fighter_profile.dart';
import '../../domain/entities/mma_event.dart';
import '../../domain/repositories/events_repository.dart';
import '../datasources/events_local_datasource.dart';
import '../datasources/mma_events_remote_datasource.dart';

class EventsRepositoryImpl implements EventsRepository {
  final MmaEventsRemoteDatasource _remote;
  final EventsLocalDatasource _local;

  const EventsRepositoryImpl(this._remote, this._local);

  @override
  List<MmaEvent>? cachedUpcomingEvents() => _local.loadUpcoming();

  @override
  Future<List<MmaEvent>> fetchUpcomingEvents() async {
    final events = await _remote.fetchUpcomingEvents();
    await _local.saveUpcoming(events);
    return events;
  }

  @override
  Map<int, List<MmaEvent>> cachedPastEventPages() {
    final pages = <int, List<MmaEvent>>{};
    for (final page in _local.loadPastPageNumbers()) {
      final events = _local.loadPastPage(page);
      if (events != null) pages[page] = events;
    }
    return pages;
  }

  @override
  bool cachedPastEventsHasMore() => _local.loadPastHasMore();

  @override
  Future<EventsPage> fetchPastEventsPage(int page) async {
    final result = await _remote.fetchPastEvents(page: page);
    await _local.savePastPage(page, result.events, hasMore: result.hasMore);
    return result;
  }

  @override
  List<EventFight>? cachedEventFights(String eventUrl) =>
      _local.loadFights(eventUrl);

  @override
  Future<List<EventFight>> fetchEventFights(String eventUrl) async {
    final fights = await _remote.fetchEventFights(eventUrl);
    await _local.saveFights(eventUrl, fights);
    return fights;
  }

  @override
  FighterProfile? cachedFighterProfile(String fighterUrl) =>
      _local.loadFighterProfile(fighterUrl);

  @override
  Future<FighterProfile> fetchFighterProfile(String fighterUrl) async {
    final profile = await _remote.fetchFighterProfile(fighterUrl);
    await _local.saveFighterProfile(fighterUrl, profile);
    return profile;
  }

  @override
  List<CachedRequestInfo> listCachedRequests() => _local.listCachedRequests();
}
