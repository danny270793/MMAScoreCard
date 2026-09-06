import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/max_width_body.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/event_fight.dart';
import '../../domain/entities/mma_event.dart';
import 'fighter_detail_page.dart';

class FightDetailPage extends StatelessWidget {
  const FightDetailPage({super.key, required this.event, required this.fight});

  final MmaEvent event;
  final EventFight fight;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final localeName = Localizations.localeOf(context).toString();

    return Scaffold(
      appBar: AppBar(title: Text('${fight.fighterA} vs. ${fight.fighterB}')),
      body: MaxWidthBody(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _SectionLabel(loc.fightDetailEventInfoLabel),
            Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.confirmation_number_outlined,
                    label: loc.fightDetailEventLabel,
                    value: event.eventName,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
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
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _InfoRow(
                    icon: Icons.fitness_center_outlined,
                    label: loc.fightDetailDivisionLabel,
                    value: fight.weightClass,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionLabel(loc.fightDetailResultLabel),
            if (!fight.isCompleted)
              Card(
                margin: EdgeInsets.zero,
                elevation: 0,
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    loc.fightDetailNotYetContested,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              )
            else
              Card(
                margin: EdgeInsets.zero,
                elevation: 0,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          _MethodIcon(method: fight.method!),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fight.method!,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  loc.fightDetailMethodOfVictoryLabel,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (fight.time != null || fight.round != null) ...[
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          children: [
                            if (fight.time != null)
                              Expanded(
                                child: _StatItem(
                                  icon: Icons.timer_outlined,
                                  color: theme.colorScheme.secondary,
                                  value: fight.time!,
                                  label: loc.fightDetailTimeLabel,
                                ),
                              ),
                            if (fight.time != null && fight.round != null)
                              VerticalDivider(
                                width: 1,
                                indent: 8,
                                endIndent: 8,
                                color: theme.dividerColor,
                              ),
                            if (fight.round != null)
                              Expanded(
                                child: _StatItem(
                                  icon: Icons.tag,
                                  color: theme.colorScheme.primary,
                                  value: fight.round!,
                                  label: loc.fightDetailRoundLabel,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                    if (fight.referee != null) ...[
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _InfoRow(
                        icon: Icons.person_outline,
                        label: loc.fightDetailRefereeLabel,
                        value: fight.referee!,
                      ),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 24),
            _SectionLabel(loc.fightDetailFightersLabel),
            Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _FighterRow(
                    name: fight.fighterA,
                    url: fight.fighterAUrl,
                    outcome: fight.outcomeA,
                    currentEventUrl: event.url,
                    currentEventIsTitleFight: fight.isTitleFight,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _FighterRow(
                    name: fight.fighterB,
                    url: fight.fighterBUrl,
                    outcome: fight.outcomeB,
                    currentEventUrl: event.url,
                    currentEventIsTitleFight: fight.isTitleFight,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(letterSpacing: 0.5),
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
          SizedBox(
            width: 72,
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

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}

class _MethodIcon extends StatelessWidget {
  const _MethodIcon({required this.method});

  final String method;

  @override
  Widget build(BuildContext context) {
    final lower = method.toLowerCase();
    final IconData icon;
    final Color color;
    if (lower.contains('submission')) {
      icon = Icons.sports_kabaddi;
      color = Theme.of(context).colorScheme.secondary;
    } else if (lower.contains('ko')) {
      icon = Icons.sports_mma;
      color = Theme.of(context).colorScheme.error;
    } else {
      icon = Icons.assignment_outlined;
      color = Theme.of(context).colorScheme.primary;
    }
    return CircleAvatar(
      radius: 22,
      backgroundColor: color.withValues(alpha: 0.15),
      child: Icon(icon, color: color),
    );
  }
}

class _FighterRow extends StatelessWidget {
  const _FighterRow({
    required this.name,
    required this.url,
    required this.outcome,
    required this.currentEventUrl,
    required this.currentEventIsTitleFight,
  });

  final String name;
  final String? url;
  final FightOutcome outcome;
  final String currentEventUrl;
  final bool currentEventIsTitleFight;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    String? badgeText;
    Color? badgeColor;
    switch (outcome) {
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
        badgeText = null;
        badgeColor = null;
    }

    final fighterUrl = url;
    return InkWell(
      onTap: fighterUrl == null
          ? null
          : () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => FighterDetailPage(
                  fighterName: name,
                  fighterUrl: fighterUrl,
                  currentEventUrl: currentEventUrl,
                  currentEventIsTitleFight: currentEventIsTitleFight,
                ),
              ),
            ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (badgeText != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badgeText.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (fighterUrl != null)
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
