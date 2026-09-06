import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/max_width_body.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../application/fighter_profile_controller.dart';
import '../../domain/entities/event_fight.dart';
import '../../domain/entities/fighter_profile.dart';
import 'fighter_fight_search_page.dart';

enum _FightMethodKind { koTko, submission, other }

_FightMethodKind _methodKind(String method) {
  final lower = method.toLowerCase();
  if (lower.contains('submission')) return _FightMethodKind.submission;
  if (lower.contains('ko')) return _FightMethodKind.koTko;
  return _FightMethodKind.other;
}

class FighterDetailPage extends ConsumerWidget {
  const FighterDetailPage({
    super.key,
    required this.fighterName,
    required this.fighterUrl,
    this.currentEventUrl,
    this.currentEventIsTitleFight = false,
  });

  final String fighterName;
  final String fighterUrl;
  final String? currentEventUrl;
  final bool currentEventIsTitleFight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(
      fighterProfileControllerProvider(fighterUrl),
    );

    return Scaffold(
      extendBody: true,
      appBar: AppBar(title: Text(fighterName)),
      bottomNavigationBar: profileAsync.maybeWhen(
        data: (profile) => profile.fightHistory.isEmpty
            ? null
            : Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SafeArea(
                  top: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Material(
                        elevation: 3,
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHigh,
                        shape: const CircleBorder(),
                        child: IconButton(
                          icon: const Icon(Icons.search),
                          tooltip: loc.tabSearch,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => FighterFightSearchPage(
                                fights: profile.fightHistory,
                              ),
                            ),
                          ),
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
              .read(fighterProfileControllerProvider(fighterUrl).notifier)
              .refresh(),
          child: profileAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) =>
                Center(child: Text(loc.fighterDetailLoadError)),
            data: (profile) => _FighterDetailBody(
              profile: profile,
              currentEventUrl: currentEventUrl,
              currentEventIsTitleFight: currentEventIsTitleFight,
            ),
          ),
        ),
      ),
    );
  }
}

class _FighterDetailBody extends StatelessWidget {
  const _FighterDetailBody({
    required this.profile,
    required this.currentEventUrl,
    required this.currentEventIsTitleFight,
  });

  final FighterProfile profile;
  final String? currentEventUrl;
  final bool currentEventIsTitleFight;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final yearGroups = groupFightsByYear(profile.fightHistory);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              if (profile.nationality != null)
                _InfoRow(
                  icon: Icons.flag_outlined,
                  label: loc.fighterDetailNationalityLabel,
                  value: profile.nationality!,
                ),
              if (profile.hometown != null) ...[
                const Divider(height: 1, indent: 16, endIndent: 16),
                _InfoRow(
                  icon: Icons.home_outlined,
                  label: loc.fighterDetailHometownLabel,
                  value: profile.hometown!,
                ),
              ],
              if (profile.age != null) ...[
                const Divider(height: 1, indent: 16, endIndent: 16),
                _InfoRow(
                  icon: Icons.cake_outlined,
                  label: loc.fighterDetailAgeLabel,
                  value:
                      '${profile.age}${profile.birthDate != null ? ' (${profile.birthDate})' : ''}',
                ),
              ],
              if (profile.height != null) ...[
                const Divider(height: 1, indent: 16, endIndent: 16),
                _InfoRow(
                  icon: Icons.straighten_outlined,
                  label: loc.fighterDetailHeightLabel,
                  value: profile.height!,
                ),
              ],
              if (profile.weight != null) ...[
                const Divider(height: 1, indent: 16, endIndent: 16),
                _InfoRow(
                  icon: Icons.monitor_weight_outlined,
                  label: loc.fighterDetailWeightLabel,
                  value: profile.weight!,
                ),
              ],
              if (profile.association != null) ...[
                const Divider(height: 1, indent: 16, endIndent: 16),
                _InfoRow(
                  icon: Icons.shield_outlined,
                  label: loc.fighterDetailAssociationLabel,
                  value: profile.association!,
                ),
              ],
              if (profile.weightClass != null) ...[
                const Divider(height: 1, indent: 16, endIndent: 16),
                _InfoRow(
                  icon: Icons.fitness_center_outlined,
                  label: loc.fighterDetailClassLabel,
                  value: profile.weightClass!,
                ),
              ],
              const Divider(height: 1, indent: 16, endIndent: 16),
              _InfoRow(
                icon: Icons.badge_outlined,
                label: loc.fighterDetailRecordLabel,
                value: profile.recordSummary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _RecordCard(
                title: loc.fighterDetailWinsLabel,
                count: profile.wins,
                color: Colors.green,
                breakdown: profile.winsBreakdown,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _RecordCard(
                title: loc.fighterDetailLossesLabel,
                count: profile.losses,
                color: theme.colorScheme.error,
                breakdown: profile.lossesBreakdown,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            loc.fighterDetailFightHistoryLabel.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 0.5),
          ),
        ),
        if (profile.fightHistory.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text(loc.fighterDetailEmpty)),
          )
        else
          for (final group in yearGroups) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 0, 8),
              child: Text(
                group.year,
                style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 0.5),
              ),
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (var i = 0; i < group.fights.length; i++) ...[
                    if (i > 0) const Divider(height: 1, indent: 16),
                    FightHistoryTile(
                      record: group.fights[i],
                      isTitleFight:
                          currentEventIsTitleFight &&
                          group.fights[i].eventUrl == currentEventUrl,
                    ),
                  ],
                ],
              ),
            ),
          ],
      ],
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
          SizedBox(
            width: 100,
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          Expanded(
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

class _RecordCard extends StatelessWidget {
  const _RecordCard({
    required this.title,
    required this.count,
    required this.color,
    required this.breakdown,
  });

  final String title;
  final int count;
  final Color color;
  final RecordBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$count',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            _MeterLine(
              icon: Icons.sports_mma,
              color: theme.colorScheme.error,
              label: loc.statKoTko,
              meter: breakdown.koTko,
            ),
            _MeterLine(
              icon: Icons.sports_kabaddi,
              color: theme.colorScheme.secondary,
              label: loc.statSubmissions,
              meter: breakdown.submissions,
            ),
            _MeterLine(
              icon: Icons.assignment_outlined,
              color: theme.colorScheme.primary,
              label: loc.statDecisions,
              meter: breakdown.decisions,
            ),
          ],
        ),
      ),
    );
  }
}

class _MeterLine extends StatelessWidget {
  const _MeterLine({
    required this.icon,
    required this.color,
    required this.label,
    required this.meter,
  });

  final IconData icon;
  final Color color;
  final String label;
  final RecordMeter meter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: theme.textTheme.bodySmall)),
          Text(
            '${meter.count} (${meter.percent}%)',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class FightHistoryTile extends StatelessWidget {
  const FightHistoryTile({
    super.key,
    required this.record,
    this.isTitleFight = false,
  });

  final FighterFightRecord record;
  final bool isTitleFight;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    String badgeText;
    Color badgeColor;
    switch (record.outcome) {
      case FightOutcome.win:
        badgeText = loc.fightOutcomeWin;
        badgeColor = Colors.green;
      case FightOutcome.loss:
        badgeText = loc.fightOutcomeLoss;
        badgeColor = theme.colorScheme.error;
      case FightOutcome.draw:
        badgeText = loc.fightOutcomeDraw;
        badgeColor = theme.colorScheme.outline;
      case FightOutcome.noContest:
        badgeText = loc.fightOutcomeNoContest;
        badgeColor = theme.colorScheme.outline;
      case FightOutcome.pending:
        badgeText = '';
        badgeColor = theme.colorScheme.outline;
    }

    final method = record.method;
    final kind = method == null ? null : _methodKind(method);
    final icon = kind == null
        ? Icons.schedule_outlined
        : switch (kind) {
            _FightMethodKind.koTko => Icons.sports_mma,
            _FightMethodKind.submission => Icons.sports_kabaddi,
            _FightMethodKind.other => Icons.assignment_outlined,
          };
    final iconColor = kind == null
        ? theme.colorScheme.outline
        : switch (kind) {
            _FightMethodKind.koTko => theme.colorScheme.error,
            _FightMethodKind.submission => theme.colorScheme.secondary,
            _FightMethodKind.other => theme.colorScheme.primary,
          };

    final opponentUrl = record.opponentUrl;
    return InkWell(
      onTap: opponentUrl == null
          ? null
          : () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => FighterDetailPage(
                  fighterName: record.opponentName,
                  fighterUrl: opponentUrl,
                ),
              ),
            ),
      child: Container(
        color: isTitleFight
            ? theme.colorScheme.tertiaryContainer.withValues(alpha: 0.35)
            : null,
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isTitleFight) ...[
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
                        loc.eventDetailTitleFightLabel.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onTertiary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    record.opponentName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (method != null)
                    Text(
                      method,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  Text(
                    record.eventName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  if (record.eventDateText != null)
                    Text(
                      record.eventDateText!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (badgeText.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeText.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (record.round != null && record.time != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'R${record.round} • ${record.time}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
