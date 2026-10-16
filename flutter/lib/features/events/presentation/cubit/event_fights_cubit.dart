import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/logger/app_logger.dart';
import '../../domain/entities/event_fight.dart';
import '../../domain/usecases/get_event_fights_usecase.dart';
import 'load_state.dart';

typedef EventFightsState = LoadState<List<EventFight>>;

/// A fight card is fetched at most once per event: [load] serves the cached
/// copy if present, and the network is never hit again on its own.
/// [refresh] (pull-to-refresh) is the only way to force a re-fetch, and it
/// overwrites the cache with the new result.
class EventFightsCubit extends Cubit<EventFightsState> {
  EventFightsCubit(this._getEventFights, {required this.eventUrl})
    : super(const EventFightsState.loading());

  final GetEventFightsUsecase _getEventFights;
  final String eventUrl;

  Future<void> load() => _run(refresh: false);

  Future<void> refresh() => _run(refresh: true);

  Future<void> _run({required bool refresh}) async {
    try {
      final fights = await _getEventFights(eventUrl, refresh: refresh);
      if (!isClosed) emit(EventFightsState.success(fights));
    } catch (e, s) {
      AppLogger.error('loading fight card failed', e, s);
      // Keep showing the last good (possibly cached) data if we have any.
      if (!isClosed && !state.hasData) emit(EventFightsState.failure(e));
    }
  }
}
