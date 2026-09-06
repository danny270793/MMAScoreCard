import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../application/past_events_controller.dart';
import 'event_search_utils.dart';
import 'month_section.dart';

class PastEventsView extends ConsumerStatefulWidget {
  const PastEventsView({super.key, this.query = ''});

  final String query;

  @override
  ConsumerState<PastEventsView> createState() => _PastEventsViewState();
}

class _PastEventsViewState extends ConsumerState<PastEventsView> {
  final _scrollController = ScrollController();

  static const _loadMoreThreshold = 300.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _loadMoreThreshold) {
      ref.read(pastEventsControllerProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final state = ref.watch(pastEventsControllerProvider);

    if (state.events.isEmpty && state.isLoadingMore) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.events.isEmpty && state.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(loc.pastLoadError),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => ref
                  .read(pastEventsControllerProvider.notifier)
                  .loadNextPage(),
              child: Text(loc.retryButton),
            ),
          ],
        ),
      );
    }

    if (state.events.isEmpty) {
      return Center(child: Text(loc.noPastEvents));
    }

    final matches = filterEvents(state.events, widget.query);
    if (matches.isEmpty) {
      return Center(child: Text(loc.searchNoResults));
    }

    final groups = groupEventsByMonth(
      matches,
      Localizations.localeOf(context).toString(),
    );

    // Filtered pages can be short enough not to fill the viewport, so keep
    // the "load more" row visible to reach older matches.
    return RefreshIndicator(
      onRefresh: () =>
          ref.read(pastEventsControllerProvider.notifier).refresh(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 96),
        itemCount: groups.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= groups.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return MonthSectionCard(group: groups[index]);
        },
      ),
    );
  }
}
