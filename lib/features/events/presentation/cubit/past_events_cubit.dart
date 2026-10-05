import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/logger/app_logger.dart';
import '../../domain/entities/mma_event.dart';
import '../../domain/usecases/fetch_past_events_page_usecase.dart';
import '../../domain/usecases/get_cached_past_events_usecase.dart';
import 'past_events_state.dart';

/// Past events are paginated (100/page from Sherdog). Every page - including
/// page 1 - is fetched at most once: once it's on disk it's kept and never
/// re-fetched. Scrolling near the bottom of the list calls [loadNextPage]
/// for the classic infinite-scroll behavior.
class PastEventsCubit extends Cubit<PastEventsState> {
  PastEventsCubit({
    required this._getCachedPastEvents,
    required this._fetchPastEventsPage,
  }) : super(const PastEventsState(isLoadingMore: true));

  final GetCachedPastEventsUsecase _getCachedPastEvents;
  final FetchPastEventsPageUsecase _fetchPastEventsPage;
  final Map<int, List<MmaEvent>> _pages = {};

  /// Serves every cached page; fetches page 1 only if nothing is cached.
  Future<void> load() async {
    final cached = _getCachedPastEvents();
    _pages
      ..clear()
      ..addAll(cached.pages);
    final hasCachedData = _pages.isNotEmpty;
    emit(
      PastEventsState(
        events: _flatten(),
        hasMore: cached.hasMore,
        isLoadingMore: !hasCachedData,
      ),
    );
    if (!hasCachedData) await _loadPage(1);
  }

  /// Pull-to-refresh: force a fresh fetch of page 1, overwriting its cache
  /// entry, regardless of [PastEventsState.hasMore]/[PastEventsState.isLoadingMore].
  Future<void> refresh() => _loadPage(1);

  Future<void> loadNextPage() async {
    if (state.isLoadingMore) return;
    if (_pages.isNotEmpty && !state.hasMore) return;
    final nextPage = _pages.isEmpty
        ? 1
        : (_pages.keys.reduce((a, b) => a > b ? a : b) + 1);
    await _loadPage(nextPage);
  }

  List<MmaEvent> _flatten() {
    final sortedPages = _pages.keys.toList()..sort();
    return sortedPages.expand((page) => _pages[page]!).toList();
  }

  Future<void> _loadPage(int page) async {
    emit(
      PastEventsState(
        events: state.events,
        hasMore: state.hasMore,
        isLoadingMore: true,
      ),
    );

    try {
      final result = await _fetchPastEventsPage(page);
      _pages[page] = result.events;
      if (isClosed) return;
      emit(PastEventsState(events: _flatten(), hasMore: result.hasMore));
    } catch (e, s) {
      AppLogger.error('loading past events page $page failed', e, s);
      if (isClosed) return;
      emit(
        PastEventsState(events: _flatten(), hasMore: state.hasMore, error: e),
      );
    }
  }
}
