import '../../domain/entities/event_fight.dart';
import '../../domain/entities/fighter_profile.dart';
import '../../domain/entities/mma_event.dart';

/// Matches against event name, matchup and location - the same fields
/// shown on the tile - case-insensitively.
List<MmaEvent> filterEvents(List<MmaEvent> events, String query) {
  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) return events;
  return events.where((event) {
    return event.eventName.toLowerCase().contains(normalized) ||
        (event.matchup?.toLowerCase().contains(normalized) ?? false) ||
        event.location.toLowerCase().contains(normalized);
  }).toList();
}

/// Matches against both fighters and the division.
List<EventFight> filterFights(List<EventFight> fights, String query) {
  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) return fights;
  return fights.where((fight) {
    return fight.fighterA.toLowerCase().contains(normalized) ||
        fight.fighterB.toLowerCase().contains(normalized) ||
        fight.weightClass.toLowerCase().contains(normalized);
  }).toList();
}

/// Matches against the opponent and the event a fight belongs to.
List<FighterFightRecord> filterFightHistory(
  List<FighterFightRecord> fights,
  String query,
) {
  final normalized = query.trim().toLowerCase();
  if (normalized.isEmpty) return fights;
  return fights.where((fight) {
    return fight.opponentName.toLowerCase().contains(normalized) ||
        fight.eventName.toLowerCase().contains(normalized);
  }).toList();
}
