import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mmascorecard/l10n/app_localizations.dart';

import '../features/events/presentation/cubit/load_state.dart';
import '../features/events/presentation/cubit/upcoming_events_cubit.dart';
import 'event_search_utils.dart';
import 'month_section.dart';

class UpcomingEventsView extends StatelessWidget {
  const UpcomingEventsView({super.key, this.query = ''});

  final String query;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final state = context.watch<UpcomingEventsCubit>().state;

    switch (state.status) {
      case LoadStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case LoadStatus.failure:
        return _ErrorView(
          message: loc.upcomingLoadError,
          onRetry: () => context.read<UpcomingEventsCubit>().refresh(),
        );
      case LoadStatus.success:
        final events = state.data!;
        if (events.isEmpty) {
          return Center(child: Text(loc.noUpcomingEvents));
        }
        final matches = filterEvents(events, query);
        if (matches.isEmpty) {
          return Center(child: Text(loc.searchNoResults));
        }
        final groups = groupEventsByMonth(
          matches,
          Localizations.localeOf(context).toString(),
        );
        return RefreshIndicator(
          onRefresh: () => context.read<UpcomingEventsCubit>().refresh(),
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: groups.length,
            itemBuilder: (context, index) =>
                MonthSectionCard(group: groups[index]),
          ),
        );
    }
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: 8),
          FilledButton(onPressed: onRetry, child: Text(loc.retryButton)),
        ],
      ),
    );
  }
}
