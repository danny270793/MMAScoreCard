import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/mma_event.dart';
import 'event_list_tile.dart';

class MonthGroup {
  MonthGroup(this.label, this.events);

  final String label;
  final List<MmaEvent> events;
}

/// Groups consecutive events by month/year. Events are already
/// chronologically ordered coming from the repository, so a single pass
/// is enough - no need to sort or bucket by a map.
List<MonthGroup> groupEventsByMonth(List<MmaEvent> events, String localeName) {
  final format = DateFormat.yMMMM(localeName);
  final groups = <MonthGroup>[];
  for (final event in events) {
    final label = format.format(event.dateUtc);
    if (groups.isNotEmpty && groups.last.label == label) {
      groups.last.events.add(event);
    } else {
      groups.add(MonthGroup(label, [event]));
    }
  }
  return groups;
}

class MonthSectionCard extends StatelessWidget {
  const MonthSectionCard({super.key, required this.group, this.now});

  final MonthGroup group;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              group.label.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 0.5),
            ),
          ),
          Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < group.events.length; i++) ...[
                  if (i > 0) const Divider(height: 1, indent: 72),
                  EventListTile(event: group.events[i], now: now),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
