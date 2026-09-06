import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/max_width_body.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../events/application/events_providers.dart';
import '../../../events/data/cached_request_info.dart';

class CachedRecordsPage extends ConsumerWidget {
  const CachedRecordsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final entries = ref.watch(eventsCacheProvider).listCachedRequests();
    final dateFormat = DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    ).add_jm();

    return Scaffold(
      appBar: AppBar(title: Text(loc.cachedRecordsTitle)),
      body: MaxWidthBody(
        child: entries.isEmpty
            ? Center(child: Text(loc.cachedRecordsEmpty))
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: [
                  Card(
                    margin: EdgeInsets.zero,
                    elevation: 0,
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        for (var i = 0; i < entries.length; i++) ...[
                          if (i > 0)
                            const Divider(height: 1, indent: 16, endIndent: 16),
                          _CachedRecordTile(
                            entry: entries[i],
                            dateFormat: dateFormat,
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

class _CachedRecordTile extends StatelessWidget {
  const _CachedRecordTile({required this.entry, required this.dateFormat});

  final CachedRequestInfo entry;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final label = switch (entry.kind) {
      CachedRequestKind.upcoming => loc.cachedUpcomingLabel,
      CachedRequestKind.pastPage => loc.cachedPastPageLabel(entry.page!),
      CachedRequestKind.fightCard => loc.cachedFightCardLabel,
      CachedRequestKind.fighterProfile => loc.cachedFighterProfileLabel,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  Uri.parse(entry.url).path,
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  loc.cachedAtLabel(
                    dateFormat.format(entry.cachedAt.toLocal()),
                  ),
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  loc.cachedRefreshedAtLabel(
                    dateFormat.format(entry.refreshedAt.toLocal()),
                  ),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatBytes(entry.sizeBytes),
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 2),
              Text(
                loc.cachedReadCountLabel(entry.readCount),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
