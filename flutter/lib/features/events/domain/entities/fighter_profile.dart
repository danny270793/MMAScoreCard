import 'event_fight.dart';

class RecordMeter {
  final int count;
  final int percent;

  const RecordMeter({required this.count, required this.percent});

  Map<String, dynamic> toJson() => {'count': count, 'percent': percent};

  factory RecordMeter.fromJson(Map<String, dynamic> json) =>
      RecordMeter(count: json['count'] as int, percent: json['percent'] as int);
}

class RecordBreakdown {
  final RecordMeter koTko;
  final RecordMeter submissions;
  final RecordMeter decisions;

  const RecordBreakdown({
    required this.koTko,
    required this.submissions,
    required this.decisions,
  });

  Map<String, dynamic> toJson() => {
    'koTko': koTko.toJson(),
    'submissions': submissions.toJson(),
    'decisions': decisions.toJson(),
  };

  factory RecordBreakdown.fromJson(Map<String, dynamic> json) =>
      RecordBreakdown(
        koTko: RecordMeter.fromJson(json['koTko'] as Map<String, dynamic>),
        submissions: RecordMeter.fromJson(
          json['submissions'] as Map<String, dynamic>,
        ),
        decisions: RecordMeter.fromJson(
          json['decisions'] as Map<String, dynamic>,
        ),
      );
}

class FighterFightRecord {
  final FightOutcome outcome;
  final String opponentName;
  final String? opponentUrl;
  final String eventName;
  final String? eventUrl;
  final String? eventDateText;
  final String? method;
  final String? referee;
  final String? round;
  final String? time;

  /// Amateur bouts are listed separately by the source and do not count
  /// towards the professional record.
  final bool isAmateur;

  const FighterFightRecord({
    required this.outcome,
    required this.opponentName,
    required this.eventName,
    this.opponentUrl,
    this.eventUrl,
    this.eventDateText,
    this.method,
    this.referee,
    this.round,
    this.time,
    this.isAmateur = false,
  });

  Duration? get octagonTime => octagonTimeOf(round: round, time: time);

  Map<String, dynamic> toJson() => {
    'outcome': outcome.name,
    'opponentName': opponentName,
    'opponentUrl': opponentUrl,
    'eventName': eventName,
    'eventUrl': eventUrl,
    'eventDateText': eventDateText,
    'method': method,
    'referee': referee,
    'round': round,
    'time': time,
    'isAmateur': isAmateur,
  };

  factory FighterFightRecord.fromJson(Map<String, dynamic> json) =>
      FighterFightRecord(
        outcome: FightOutcome.values.byName(json['outcome'] as String),
        opponentName: json['opponentName'] as String,
        opponentUrl: json['opponentUrl'] as String?,
        eventName: json['eventName'] as String,
        eventUrl: json['eventUrl'] as String?,
        eventDateText: json['eventDateText'] as String?,
        method: json['method'] as String?,
        referee: json['referee'] as String?,
        round: json['round'] as String?,
        time: json['time'] as String?,
        isAmateur: json['isAmateur'] as bool? ?? false,
      );
}

/// A run of consecutive fights that ended the same way.
class FightStreak {
  const FightStreak({required this.outcome, required this.count});

  final FightOutcome outcome;
  final int count;
}

class FighterProfile {
  final String name;
  final String? nationality;
  final String? hometown;
  final int? age;
  final String? birthDate;
  final String? height;
  final String? weight;
  final String? association;
  final String? weightClass;
  final int wins;
  final int losses;
  final RecordBreakdown winsBreakdown;
  final RecordBreakdown lossesBreakdown;
  final List<FighterFightRecord> fightHistory;

  const FighterProfile({
    required this.name,
    required this.wins,
    required this.losses,
    required this.winsBreakdown,
    required this.lossesBreakdown,
    required this.fightHistory,
    this.nationality,
    this.hometown,
    this.age,
    this.birthDate,
    this.height,
    this.weight,
    this.association,
    this.weightClass,
  });

  int get draws =>
      fightHistory.where((f) => f.outcome == FightOutcome.draw).length;

  int get noContests =>
      fightHistory.where((f) => f.outcome == FightOutcome.noContest).length;

  /// "wins-losses-draws-noContests", e.g. "30-0-1-0".
  String get recordSummary => '$wins-$losses-$draws-$noContests';

  /// Professional fights only, newest first - the source orders the history
  /// by date and lists amateur bouts separately from the record.
  List<FighterFightRecord> get professionalFights =>
      fightHistory.where((fight) => !fight.isAmateur).toList();

  /// Consecutive same-result fights counted back from the most recent one.
  /// Scheduled bouts have no result, so they neither start nor break a run.
  FightStreak? get currentStreak {
    FightOutcome? outcome;
    var count = 0;
    for (final fight in professionalFights) {
      if (fight.outcome == FightOutcome.pending) continue;
      if (outcome == null) {
        outcome = fight.outcome;
        count = 1;
        continue;
      }
      if (fight.outcome != outcome) break;
      count++;
    }
    return outcome == null ? null : FightStreak(outcome: outcome, count: count);
  }

  /// Longest run of wins anywhere in the professional history.
  int get bestWinStreak => _longestStreak(FightOutcome.win);

  /// Longest run of losses anywhere in the professional history.
  int get worstLossStreak => _longestStreak(FightOutcome.loss);

  /// Total time spent fighting across every professional bout with a result.
  Duration get totalOctagonTime {
    var total = Duration.zero;
    for (final fight in professionalFights) {
      total += fight.octagonTime ?? Duration.zero;
    }
    return total;
  }

  int _longestStreak(FightOutcome outcome) {
    var longest = 0;
    var run = 0;
    for (final fight in professionalFights) {
      if (fight.outcome == FightOutcome.pending) continue;
      if (fight.outcome != outcome) {
        run = 0;
        continue;
      }
      run++;
      if (run > longest) longest = run;
    }
    return longest;
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'nationality': nationality,
    'hometown': hometown,
    'age': age,
    'birthDate': birthDate,
    'height': height,
    'weight': weight,
    'association': association,
    'weightClass': weightClass,
    'wins': wins,
    'losses': losses,
    'winsBreakdown': winsBreakdown.toJson(),
    'lossesBreakdown': lossesBreakdown.toJson(),
    'fightHistory': fightHistory.map((f) => f.toJson()).toList(),
  };

  factory FighterProfile.fromJson(Map<String, dynamic> json) => FighterProfile(
    name: json['name'] as String,
    nationality: json['nationality'] as String?,
    hometown: json['hometown'] as String?,
    age: json['age'] as int?,
    birthDate: json['birthDate'] as String?,
    height: json['height'] as String?,
    weight: json['weight'] as String?,
    association: json['association'] as String?,
    weightClass: json['weightClass'] as String?,
    wins: json['wins'] as int,
    losses: json['losses'] as int,
    winsBreakdown: RecordBreakdown.fromJson(
      json['winsBreakdown'] as Map<String, dynamic>,
    ),
    lossesBreakdown: RecordBreakdown.fromJson(
      json['lossesBreakdown'] as Map<String, dynamic>,
    ),
    fightHistory: (json['fightHistory'] as List<dynamic>)
        .map((f) => FighterFightRecord.fromJson(f as Map<String, dynamic>))
        .toList(),
  );
}

class FightYearGroup {
  FightYearGroup(this.year, this.fights);

  final String year;
  final List<FighterFightRecord> fights;
}

/// Groups consecutive fights by year. Fight history is already
/// chronologically ordered coming from the repository, so a single pass
/// is enough - no need to sort or bucket by a map.
List<FightYearGroup> groupFightsByYear(List<FighterFightRecord> fights) {
  final groups = <FightYearGroup>[];
  for (final fight in fights) {
    final year =
        RegExp(r'\d{4}').firstMatch(fight.eventDateText ?? '')?.group(0) ?? '';
    if (groups.isNotEmpty && groups.last.year == year) {
      groups.last.fights.add(fight);
    } else {
      groups.add(FightYearGroup(year, [fight]));
    }
  }
  return groups;
}
