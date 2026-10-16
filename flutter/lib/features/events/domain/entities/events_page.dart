import 'mma_event.dart';

class EventsPage {
  final List<MmaEvent> events;
  final int page;
  final bool hasMore;

  const EventsPage({
    required this.events,
    required this.page,
    required this.hasMore,
  });
}
