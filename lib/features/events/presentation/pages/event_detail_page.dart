import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/max_width_body.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../application/event_fights_controller.dart';
import '../../domain/entities/event_fight.dart';
import '../../domain/entities/mma_event.dart';
import '../widgets/event_search_utils.dart';
import '../widgets/floating_search_field.dart';
import 'fight_detail_page.dart';

enum _FightMethodKind { koTko, submission, other }

_FightMethodKind _methodKind(String method) {
  final lower = method.toLowerCase();
  if (lower.contains('submission')) return _FightMethodKind.submission;
  if (lower.contains('ko')) return _FightMethodKind.koTko;
  return _FightMethodKind.other;
}

class EventDetailPage extends ConsumerStatefulWidget {
  const EventDetailPage({super.key, required this.event});

  final MmaEvent event;

  @override
  ConsumerState<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends ConsumerState<EventDetailPage> {
  final _searchController = TextEditingController();
  bool _searching = false;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _closeSearch() {
    _searchController.clear();
    setState(() {
      _searching = false;
      _query = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final localeName = Localizations.localeOf(context).toString();
    final fightsAsync = ref.watch(eventFightsControllerProvider(event.url));

    return Scaffold(
      extendBody: true,
      appBar: AppBar(title: Text(event.eventName)),
      bottomNavigationBar: fightsAsync.maybeWhen(
        data: (fights) => fights.isEmpty
            ? null
            : Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SafeArea(
                  top: false,
                  child: _searching
                      ? FloatingSearchField(
                          controller: _searchController,
                          hintText: loc.searchHint,
                          onChanged: (value) => setState(() => _query = value),
                          onClose: _closeSearch,
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Material(
                              elevation: 3,
                              color: colors.surfaceContainerHigh,
                              shape: const CircleBorder(),
                              child: IconButton(
                                icon: const Icon(Icons.search),
                                tooltip: loc.tabSearch,
                                onPressed: () =>
                                    setState(() => _searching = true),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
        orElse: () => null,
      ),
      body: MaxWidthBody(
        child: RefreshIndicator(
          onRefresh: () => ref
              .read(eventFightsControllerProvider(event.url).notifier)
              .refresh(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              Card(
                margin: EdgeInsets.zero,
                elevation: 0,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.location_on_outlined,
                      label: loc.eventDetailLocationLabel,
                      value: event.location,
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _InfoRow(
                      icon: Icons.calendar_month_outlined,
                      label: loc.eventDetailDateLabel,
                      value: DateFormat.yMMMd(localeName).format(event.dateUtc),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              fightsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (error, _) => const SizedBox.shrink(),
                data: (fights) => fights.isEmpty
                    ? const SizedBox.shrink()
                    : _StatisticsSection(fights: fights),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  loc.eventDetailFightCardLabel.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              fightsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text(loc.eventDetailLoadError)),
                ),
                data: (fights) {
                  if (fights.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: Text(loc.eventDetailEmpty)),
                    );
                  }
                  final matches = filterFights(fights, _query);
                  if (matches.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: Text(loc.searchNoResults)),
                    );
                  }
                  return Card(
                    margin: EdgeInsets.zero,
                    elevation: 0,
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        for (var i = 0; i < matches.length; i++) ...[
                          if (i > 0) const Divider(height: 1, indent: 56),
                          FightTile(
                            event: event,
                            fight: matches[i],
                            titleFightLabel: loc.eventDetailTitleFightLabel,
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatisticsSection extends StatelessWidget {
  const _StatisticsSection({required this.fights});

  final List<EventFight> fights;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    var koTko = 0;
    var submissions = 0;
    var decisions = 0;
    for (final fight in fights) {
      final method = fight.method;
      if (method == null) continue;
      switch (_methodKind(method)) {
        case _FightMethodKind.koTko:
          koTko++;
        case _FightMethodKind.submission:
          submissions++;
        case _FightMethodKind.other:
          decisions++;
      }
    }

    if (koTko == 0 && submissions == 0 && decisions == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            loc.eventDetailStatisticsLabel.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 0.5),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: _StatTile(
                    icon: Icons.sports_mma,
                    color: theme.colorScheme.error,
                    count: koTko,
                    label: loc.statKoTko,
                  ),
                ),
                VerticalDivider(
                  width: 1,
                  indent: 8,
                  endIndent: 8,
                  color: theme.dividerColor,
                ),
                Expanded(
                  child: _StatTile(
                    icon: Icons.sports_kabaddi,
                    color: theme.colorScheme.secondary,
                    count: submissions,
                    label: loc.statSubmissions,
                  ),
                ),
                VerticalDivider(
                  width: 1,
                  indent: 8,
                  endIndent: 8,
                  color: theme.dividerColor,
                ),
                Expanded(
                  child: _StatTile(
                    icon: Icons.assignment_outlined,
                    color: theme.colorScheme.primary,
                    count: decisions,
                    label: loc.statDecisions,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.color,
    required this.count,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 6),
        Text(
          '$count',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}

class FightTile extends StatelessWidget {
  const FightTile({
    super.key,
    required this.event,
    required this.fight,
    required this.titleFightLabel,
  });

  final MmaEvent event;
  final EventFight fight;
  final String titleFightLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final method = fight.method;
    final kind = method == null ? null : _methodKind(method);
    final icon = !fight.isCompleted
        ? Icons.schedule_outlined
        : switch (kind!) {
            _FightMethodKind.koTko => Icons.sports_mma,
            _FightMethodKind.submission => Icons.sports_kabaddi,
            _FightMethodKind.other => Icons.assignment_outlined,
          };
    final iconColor = !fight.isCompleted
        ? theme.colorScheme.outline
        : switch (kind!) {
            _FightMethodKind.koTko => theme.colorScheme.error,
            _FightMethodKind.submission => theme.colorScheme.secondary,
            _FightMethodKind.other => theme.colorScheme.primary,
          };

    var meta = fight.weightClass;
    if (fight.round != null && fight.time != null) {
      meta = '$meta   R${fight.round} • ${fight.time}';
    }

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => FightDetailPage(event: event, fight: fight),
        ),
      ),
      child: Container(
        color: fight.isTitleFight
            ? theme.colorScheme.tertiaryContainer.withValues(alpha: 0.35)
            : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22, color: iconColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (fight.isTitleFight) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        titleFightLabel.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onTertiary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          fight.fighterA,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(' vs ', style: theme.textTheme.bodySmall),
                      Expanded(
                        child: Text(
                          fight.fighterB,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (meta.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      meta,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                  if (fight.method != null) ...[
                    const SizedBox(height: 2),
                    Text(fight.method!, style: theme.textTheme.bodySmall),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: theme.colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}
