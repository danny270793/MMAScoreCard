enum FightOutcome { win, loss, draw, noContest, pending }

const _roundLength = Duration(minutes: 5);

/// Time spent in the cage: every round before the last one is a full five
/// minutes, plus the time elapsed in the round the fight ended in. A decision
/// after five rounds is 25:00; a stoppage at 3:45 of round two is 8:45.
///
/// Returns null when the bout has no result yet or the source data is not in
/// the expected "round" / "m:ss" shape.
Duration? octagonTimeOf({String? round, String? time}) {
  final lastRound = int.tryParse(round?.trim() ?? '');
  if (lastRound == null || lastRound < 1) return null;
  final parts = (time?.trim() ?? '').split(':');
  if (parts.length != 2) return null;
  final minutes = int.tryParse(parts[0]);
  final seconds = int.tryParse(parts[1]);
  if (minutes == null || seconds == null) return null;
  return _roundLength * (lastRound - 1) +
      Duration(minutes: minutes, seconds: seconds);
}

/// A single bout on an event's fight card, ordered main event first.
class EventFight {
  final String fighterA;
  final String fighterB;
  final String? fighterAUrl;
  final String? fighterBUrl;
  final String weightClass;
  final bool isTitleFight;
  final FightOutcome outcomeA;
  final FightOutcome outcomeB;
  final String? method;
  final String? round;
  final String? time;
  final String? referee;

  const EventFight({
    required this.fighterA,
    required this.fighterB,
    required this.weightClass,
    required this.isTitleFight,
    required this.outcomeA,
    required this.outcomeB,
    this.fighterAUrl,
    this.fighterBUrl,
    this.method,
    this.round,
    this.time,
    this.referee,
  });

  bool get isCompleted => outcomeA != FightOutcome.pending;

  Map<String, dynamic> toJson() => {
    'fighterA': fighterA,
    'fighterB': fighterB,
    'fighterAUrl': fighterAUrl,
    'fighterBUrl': fighterBUrl,
    'weightClass': weightClass,
    'isTitleFight': isTitleFight,
    'outcomeA': outcomeA.name,
    'outcomeB': outcomeB.name,
    'method': method,
    'round': round,
    'time': time,
    'referee': referee,
  };

  factory EventFight.fromJson(Map<String, dynamic> json) => EventFight(
    fighterA: json['fighterA'] as String,
    fighterB: json['fighterB'] as String,
    fighterAUrl: json['fighterAUrl'] as String?,
    fighterBUrl: json['fighterBUrl'] as String?,
    weightClass: json['weightClass'] as String,
    isTitleFight: json['isTitleFight'] as bool,
    outcomeA: FightOutcome.values.byName(json['outcomeA'] as String),
    outcomeB: FightOutcome.values.byName(json['outcomeB'] as String),
    method: json['method'] as String?,
    round: json['round'] as String?,
    time: json['time'] as String?,
    referee: json['referee'] as String?,
  );
}
