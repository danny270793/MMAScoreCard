import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/mma_event.dart';
import 'events_providers.dart';

class PastEventsState {
  final List<MmaEvent> events;
  final bool hasMore;
  final bool isLoadingMore;
  final Object? error;

  const PastEventsState({
    this.events = const [],
    this.hasMore = true,
    this.isLoadingMore = false,
    this.error,
  });
}

/// Past events are paginated (100/page from Sherdog). Every page - including
/// page 1 - is fetched at most once: once it's on disk it's kept and never
/// re-fetched. Scrolling near the bottom of the list calls [loadNextPage]
/// for the classic infinite-scroll behavior.
class PastEventsController extends Notifier<PastEventsState> {
  final Map<int, List<MmaEvent>> _pages = {};
  bool _disposed = false;

  @override
  PastEventsState build() {
    ref.onDispose(() => _disposed = true);

    final cache = ref.read(eventsCacheProvider);
    for (final page in cache.loadPastPageNumbers()) {
      final events = cache.loadPastPage(page);
      if (events != null) _pages[page] = events;
    }

    final hasCachedData = _pages.isNotEmpty;
    if (!hasCachedData) {
      // Deferred to a microtask: build() hasn't returned yet, so _loadPage's
      // synchronous `state = ...` write (before its first await) would hit
      // an uninitialized provider if called directly from here.
      unawaited(Future.microtask(() => _loadPage(1)));
    }

    return PastEventsState(
      events: _flatten(),
      hasMore: cache.loadPastHasMore(),
      isLoadingMore: !hasCachedData,
    );
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
    state = PastEventsState(
      events: state.events,
      hasMore: state.hasMore,
      isLoadingMore: true,
    );

    try {
      final repository = ref.read(mmaEventsRepositoryProvider);
      final result = await repository.fetchPastEvents(page: page);
      _pages[page] = result.events;
      await ref
          .read(eventsCacheProvider)
          .savePastPage(page, result.events, hasMore: result.hasMore);
      if (_disposed) return;
      state = PastEventsState(events: _flatten(), hasMore: result.hasMore);
    } catch (e) {
      if (_disposed) return;
      state = PastEventsState(
        events: _flatten(),
        hasMore: state.hasMore,
        error: e,
      );
    }
  }
}

final pastEventsControllerProvider =
    NotifierProvider<PastEventsController, PastEventsState>(
      PastEventsController.new,
    );
