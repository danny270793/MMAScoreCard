import 'package:mmascorecard/l10n/app_localizations.dart';

import '../features/events/domain/entities/event_fight.dart';

/// "8m 45s" for a single bout, "3h 27m" once a career total passes an hour.
String formatOctagonTime(AppLocalizations loc, Duration time) {
  if (time.inHours > 0) {
    return loc.durationHoursMinutes(time.inHours, time.inMinutes % 60);
  }
  return loc.durationMinutesSeconds(time.inMinutes, time.inSeconds % 60);
}

/// Null for [FightOutcome.pending], which has no result to count.
String? formatStreak(AppLocalizations loc, FightOutcome outcome, int count) {
  return switch (outcome) {
    FightOutcome.win => loc.streakWins(count),
    FightOutcome.loss => loc.streakLosses(count),
    FightOutcome.draw => loc.streakDraws(count),
    FightOutcome.noContest => loc.streakNoContests(count),
    FightOutcome.pending => null,
  };
}
