import '../entities/cached_request_info.dart';
import '../entities/event_fight.dart';
import '../entities/events_page.dart';
import '../entities/fighter_profile.dart';
import '../entities/mma_event.dart';

/// Cache-aware access to MMA event data. Every `cached*` getter reads only
/// from the on-device cache; every `fetch*` call hits the network and
/// overwrites the cache entry with the fresh result.
abstract class EventsRepository {
  List<MmaEvent>? cachedUpcomingEvents();

  Future<List<MmaEvent>> fetchUpcomingEvents();

  /// Cached past-event pages keyed by page number.
  Map<int, List<MmaEvent>> cachedPastEventPages();

  bool cachedPastEventsHasMore();

  Future<EventsPage> fetchPastEventsPage(int page);

  List<EventFight>? cachedEventFights(String eventUrl);

  Future<List<EventFight>> fetchEventFights(String eventUrl);

  FighterProfile? cachedFighterProfile(String fighterUrl);

  Future<FighterProfile> fetchFighterProfile(String fighterUrl);

  /// Every cached request currently stored on disk, newest first.
  List<CachedRequestInfo> listCachedRequests();
}
