import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/mma_event.dart';
import 'events_providers.dart';

/// The upcoming-events request is only ever fired once: if a cached list
/// already exists it's served as-is and the network is never hit again on
/// build. [refresh] (pull-to-refresh, error retry) is the only way to force
/// a re-fetch, and it overwrites the cache with the new result.
class UpcomingEventsController extends AsyncNotifier<List<MmaEvent>> {
  bool _disposed = false;

  @override
  Future<List<MmaEvent>> build() async {
    ref.onDispose(() => _disposed = true);
    final cached = ref.read(eventsCacheProvider).loadUpcoming();
    if (cached != null) return cached;
    return _fetch();
  }

  Future<void> refresh() async {
    try {
      final events = await _fetch();
      if (!_disposed) state = AsyncData(events);
    } catch (e, st) {
      // Keep showing the last good (possibly cached) data if we have any.
      if (!_disposed && !state.hasValue) state = AsyncError(e, st);
    }
  }

  Future<List<MmaEvent>> _fetch() async {
    final repository = ref.read(mmaEventsRepositoryProvider);
    final events = await repository.fetchUpcomingEvents();
    await ref.read(eventsCacheProvider).saveUpcoming(events);
    return events;
  }
}

final upcomingEventsControllerProvider =
    AsyncNotifierProvider<UpcomingEventsController, List<MmaEvent>>(
      UpcomingEventsController.new,
    );
