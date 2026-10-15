import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/logger/app_logger.dart';
import '../../domain/entities/mma_event.dart';
import '../../domain/usecases/get_upcoming_events_usecase.dart';
import 'load_state.dart';

typedef UpcomingEventsState = LoadState<List<MmaEvent>>;

/// The upcoming-events request is only ever fired once: if a cached list
/// already exists it's served as-is and the network is never hit again on
/// [load]. [refresh] (pull-to-refresh, error retry) is the only way to force
/// a re-fetch, and it overwrites the cache with the new result.
class UpcomingEventsCubit extends Cubit<UpcomingEventsState> {
  UpcomingEventsCubit(this._getUpcomingEvents)
    : super(const UpcomingEventsState.loading());

  final GetUpcomingEventsUsecase _getUpcomingEvents;

  Future<void> load() async {
    try {
      final events = await _getUpcomingEvents();
      if (!isClosed) emit(UpcomingEventsState.success(events));
    } catch (e, s) {
      AppLogger.error('loading upcoming events failed', e, s);
      if (!isClosed) emit(UpcomingEventsState.failure(e));
    }
  }

  Future<void> refresh() async {
    try {
      final events = await _getUpcomingEvents(refresh: true);
      if (!isClosed) emit(UpcomingEventsState.success(events));
    } catch (e, s) {
      AppLogger.error('refreshing upcoming events failed', e, s);
      // Keep showing the last good (possibly cached) data if we have any.
      if (!isClosed && !state.hasData) emit(UpcomingEventsState.failure(e));
    }
  }
}
