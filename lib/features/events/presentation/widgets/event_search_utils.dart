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
