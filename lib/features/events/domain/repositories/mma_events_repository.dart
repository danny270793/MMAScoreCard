import '../entities/event_fight.dart';
import '../entities/events_page.dart';
import '../entities/fighter_profile.dart';
import '../entities/mma_event.dart';

/// Source of MMA event listings. Implement this against any site
/// (Sherdog, UFC.com, Tapology, ...) to make it swappable at the
/// provider level without touching application or presentation code.
abstract class MmaEventsRepository {
  Future<List<MmaEvent>> fetchUpcomingEvents();

  Future<EventsPage> fetchPastEvents({required int page});

  Future<List<EventFight>> fetchEventFights(String eventUrl);

  Future<FighterProfile> fetchFighterProfile(String fighterUrl);
}

class MmaEventsException implements Exception {
  final String message;
  final Object? cause;

  MmaEventsException(this.message, [this.cause]);

  @override
  String toString() => 'MmaEventsException: $message';
}
