import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/persistence/shared_preferences_provider.dart';
import '../data/composite_mma_events_repository.dart';
import '../data/events_cache.dart';
import '../data/sherdog/sherdog_events_repository.dart';
import '../domain/repositories/mma_events_repository.dart';

/// Single place to change/add MMA event sources. On error the composite
/// falls through to the next source in the list - add e.g.
/// `UfcComEventsRepository()` here later to get automatic fallback.
final mmaEventsRepositoryProvider = Provider<MmaEventsRepository>((ref) {
  return CompositeMmaEventsRepository([SherdogEventsRepository()]);
});

final eventsCacheProvider = Provider<EventsCache>((ref) {
  return EventsCache(ref.watch(sharedPreferencesProvider));
});
