import '../../domain/entities/event_fight.dart';
import '../../domain/entities/events_page.dart';
import '../../domain/entities/fighter_profile.dart';
import '../../domain/entities/mma_event.dart';

/// Source of MMA event listings. Implement this against any site
/// (Sherdog, UFC.com, Tapology, ...) to make it swappable at the
/// DI level without touching domain or presentation code.
abstract class MmaEventsRemoteDatasource {
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
