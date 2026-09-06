enum FightOutcome { win, loss, draw, noContest, pending }

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
