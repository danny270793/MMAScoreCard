import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/event_fight.dart';
import 'events_providers.dart';

/// A fight card is fetched at most once per event: [build] serves the
/// cached copy if present, and the network is never hit again on its own.
/// [refresh] (pull-to-refresh) is the only way to force a re-fetch, and it
/// overwrites the cache with the new result.
class EventFightsController extends AsyncNotifier<List<EventFight>> {
  EventFightsController(this.eventUrl);

  final String eventUrl;
  bool _disposed = false;

  @override
  Future<List<EventFight>> build() async {
    ref.onDispose(() => _disposed = true);
    final cached = ref.read(eventsCacheProvider).loadFights(eventUrl);
    if (cached != null) return cached;
    return _fetch();
  }

  Future<void> refresh() async {
    try {
      final fights = await _fetch();
      if (!_disposed) state = AsyncData(fights);
    } catch (e, st) {
      // Keep showing the last good (possibly cached) data if we have any.
      if (!_disposed && !state.hasValue) state = AsyncError(e, st);
    }
  }

  Future<List<EventFight>> _fetch() async {
    final fights = await ref
        .read(mmaEventsRepositoryProvider)
        .fetchEventFights(eventUrl);
    await ref.read(eventsCacheProvider).saveFights(eventUrl, fights);
    return fights;
  }
}

final eventFightsControllerProvider =
    AsyncNotifierProvider.family<
      EventFightsController,
      List<EventFight>,
      String
    >(EventFightsController.new);
