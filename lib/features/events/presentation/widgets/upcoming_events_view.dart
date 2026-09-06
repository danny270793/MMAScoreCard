import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../application/upcoming_events_controller.dart';
import 'month_section.dart';

class UpcomingEventsView extends ConsumerWidget {
  const UpcomingEventsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final eventsAsync = ref.watch(upcomingEventsControllerProvider);

    return eventsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ErrorView(
        message: loc.upcomingLoadError,
        onRetry: () =>
            ref.read(upcomingEventsControllerProvider.notifier).refresh(),
      ),
      data: (events) {
        if (events.isEmpty) {
          return Center(child: Text(loc.noUpcomingEvents));
        }
        final groups = groupEventsByMonth(
          events,
          Localizations.localeOf(context).toString(),
        );
        return RefreshIndicator(
          onRefresh: () =>
              ref.read(upcomingEventsControllerProvider.notifier).refresh(),
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: groups.length,
            itemBuilder: (context, index) =>
                MonthSectionCard(group: groups[index]),
          ),
        );
      },
    );
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
