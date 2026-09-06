import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/fighter_profile.dart';
import 'events_providers.dart';

/// A fighter profile is fetched at most once per fighter: [build] serves the
/// cached copy if present, and the network is never hit again on its own.
/// [refresh] (pull-to-refresh) is the only way to force a re-fetch, and it
/// overwrites the cache with the new result.
class FighterProfileController extends AsyncNotifier<FighterProfile> {
  FighterProfileController(this.fighterUrl);

  final String fighterUrl;
  bool _disposed = false;

  @override
  Future<FighterProfile> build() async {
    ref.onDispose(() => _disposed = true);
    final cached = ref.read(eventsCacheProvider).loadFighterProfile(fighterUrl);
    if (cached != null) return cached;
    return _fetch();
  }

  Future<void> refresh() async {
    try {
      final profile = await _fetch();
      if (!_disposed) state = AsyncData(profile);
    } catch (e, st) {
      // Keep showing the last good (possibly cached) data if we have any.
      if (!_disposed && !state.hasValue) state = AsyncError(e, st);
    }
  }

  Future<FighterProfile> _fetch() async {
    final profile = await ref
        .read(mmaEventsRepositoryProvider)
        .fetchFighterProfile(fighterUrl);
    await ref.read(eventsCacheProvider).saveFighterProfile(fighterUrl, profile);
    return profile;
  }
}

final fighterProfileControllerProvider =
    AsyncNotifierProvider.family<
      FighterProfileController,
      FighterProfile,
      String
    >(FighterProfileController.new);
