import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/max_width_body.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../application/past_events_controller.dart';
import '../../application/upcoming_events_controller.dart';
import '../../domain/entities/mma_event.dart';
import '../widgets/event_search_utils.dart';
import '../widgets/month_section.dart';

/// Sherdog has no search endpoint, so this only filters events that have
/// already been fetched into the Upcoming/Past controllers - no network
/// calls happen here.
class EventSearchPage extends ConsumerStatefulWidget {
  const EventSearchPage({super.key});

  @override
  ConsumerState<EventSearchPage> createState() => _EventSearchPageState();
}

class _EventSearchPageState extends ConsumerState<EventSearchPage> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final upcoming =
        ref.watch(upcomingEventsControllerProvider).value ?? const [];
    final past = ref.watch(pastEventsControllerProvider).events;

    final byId = <String, MmaEvent>{};
    for (final event in [...upcoming, ...past]) {
      byId[event.id] = event;
    }
    final loaded = byId.values.toList()
      ..sort((a, b) => b.dateUtc.compareTo(a.dateUtc));

    final query = _query.trim();
    final localeName = Localizations.localeOf(context).toString();
    final groups = query.isEmpty
        ? const <MonthGroup>[]
        : groupEventsByMonth(filterEvents(loaded, query), localeName);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: loc.searchHint,
            border: InputBorder.none,
          ),
          onChanged: (value) => setState(() => _query = value),
        ),
      ),
      body: MaxWidthBody(
        child: query.isEmpty
            ? Center(child: Text(loc.searchEmptyPrompt))
            : groups.isEmpty
            ? Center(child: Text(loc.searchNoResults))
            : ListView.builder(
                itemCount: groups.length,
                itemBuilder: (context, index) =>
                    MonthSectionCard(group: groups[index]),
              ),
      ),
    );
  }
}
