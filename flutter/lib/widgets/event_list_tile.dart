import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:go_router/go_router.dart';
import 'package:mmascorecard/l10n/app_localizations.dart';

import '../features/events/domain/entities/mma_event.dart';

class EventListTile extends StatelessWidget {
  const EventListTile({super.key, required this.event, this.now});

  final MmaEvent event;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final localeName = Localizations.localeOf(context).toString();
    final date = event.dateUtc;
    final daysUntil = event.isUpcoming
        ? event.daysUntil(now ?? DateTime.now())
        : null;

    return InkWell(
      onTap: () => context.push('/event', extra: event),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 44,
              child: Column(
                children: [
                  Text(
                    '${date.day}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: event.isUpcoming ? theme.colorScheme.error : null,
                    ),
                  ),
                  Text(
                    DateFormat.MMM(localeName).format(date).toUpperCase(),
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.eventName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (daysUntil != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          '• ${daysUntil <= 0 ? loc.todayLabel : loc.inDaysLabel(daysUntil)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (event.matchup != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.sports_mma_outlined,
                          size: 14,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.matchup!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
