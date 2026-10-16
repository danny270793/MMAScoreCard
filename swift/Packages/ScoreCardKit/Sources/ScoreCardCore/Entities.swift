import Foundation

/// A UFC event listed on the organization page.
public struct MmaEvent: Codable, Hashable, Identifiable, Sendable {
  public let id: String
  public let eventName: String
  public let matchup: String?
  public let dateUtc: Date
  public let location: String
  public let url: String
  public let isUpcoming: Bool

  public init(
    id: String, eventName: String, matchup: String?, dateUtc: Date, location: String, url: String, isUpcoming: Bool
  ) {
    self.id = id
    self.eventName = eventName
    self.matchup = matchup
    self.dateUtc = dateUtc
    self.location = location
    self.url = url
    self.isUpcoming = isUpcoming
  }

  /// Whole calendar days between `from` and the event date, both read in UTC.
  public func daysUntil(_ from: Date) -> Int {
    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = TimeZone(identifier: "UTC")!
    return cal.dateComponents([.day], from: cal.startOfDay(for: from), to: cal.startOfDay(for: dateUtc)).day ?? 0
  }
}

public struct EventsPage: Sendable {
  public let events: [MmaEvent]
  public let page: Int
  public let hasMore: Bool

  public init(events: [MmaEvent], page: Int, hasMore: Bool) {
    self.events = events
    self.page = page
    self.hasMore = hasMore
  }
}

public enum FightOutcome: String, Codable, Sendable {
  case win, loss, draw, noContest, pending
}

/// How a bout ended, read from the free-text method ("KO (Punches)",
/// "Submission (Rear-Naked Choke)", "Decision (Unanimous)").
public enum FightMethodKind: Sendable {
  case koTko, submission, other

  public init(method: String) {
    let lower = method.lowercased()
    if lower.contains("submission") {
      self = .submission
    } else if lower.contains("ko") {
      self = .koTko
    } else {
      self = .other
    }
  }
}

/// Time spent in the cage: every round before the last one is a full five
/// minutes, plus the time elapsed in the round the fight ended in. A decision
/// after five rounds is 25:00; a stoppage at 3:45 of round two is 8:45.
///
/// Nil when the bout has no result yet or the source data is not in the
/// expected "round" / "m:ss" shape.
public func octagonTime(round: String?, time: String?) -> TimeInterval? {
  guard let lastRound = Int(round?.trimmingCharacters(in: .whitespaces) ?? ""), lastRound >= 1 else { return nil }
  let parts = (time?.trimmingCharacters(in: .whitespaces) ?? "").split(separator: ":", omittingEmptySubsequences: false)
  guard parts.count == 2, let minutes = Int(parts[0]), let seconds = Int(parts[1]) else { return nil }
  return TimeInterval((lastRound - 1) * 300 + minutes * 60 + seconds)
}

/// A single bout on an event's fight card, ordered main event first.
public struct EventFight: Codable, Hashable, Sendable {
  public let fighterA: String
  public let fighterB: String
  public let fighterAUrl: String?
  public let fighterBUrl: String?
  public let weightClass: String
  public let isTitleFight: Bool
  public let outcomeA: FightOutcome
  public let outcomeB: FightOutcome
  public let method: String?
  public let round: String?
  public let time: String?
  public let referee: String?

  public init(
    fighterA: String, fighterB: String, fighterAUrl: String? = nil, fighterBUrl: String? = nil, weightClass: String,
    isTitleFight: Bool, outcomeA: FightOutcome, outcomeB: FightOutcome, method: String? = nil, round: String? = nil,
    time: String? = nil, referee: String? = nil
  ) {
    self.fighterA = fighterA
    self.fighterB = fighterB
    self.fighterAUrl = fighterAUrl
    self.fighterBUrl = fighterBUrl
    self.weightClass = weightClass
    self.isTitleFight = isTitleFight
    self.outcomeA = outcomeA
    self.outcomeB = outcomeB
    self.method = method
    self.round = round
    self.time = time
    self.referee = referee
  }

  public var isCompleted: Bool { outcomeA != .pending }
  public var octagonTime: TimeInterval? { ScoreCardCore.octagonTime(round: round, time: time) }
}

/// KO/TKO, submission and decision counts for one side of the record.
public struct RecordMeter: Codable, Hashable, Sendable {
  public let count: Int
  public let percent: Int

  public init(count: Int, percent: Int) {
    self.count = count
    self.percent = percent
  }

  public static let zero = RecordMeter(count: 0, percent: 0)
}

public struct RecordBreakdown: Codable, Hashable, Sendable {
  public let koTko: RecordMeter
  public let submissions: RecordMeter
  public let decisions: RecordMeter

  public init(koTko: RecordMeter, submissions: RecordMeter, decisions: RecordMeter) {
    self.koTko = koTko
    self.submissions = submissions
    self.decisions = decisions
  }
}

public struct FighterFightRecord: Codable, Hashable, Sendable {
  public let outcome: FightOutcome
  public let opponentName: String
  public let opponentUrl: String?
  public let eventName: String
  public let eventUrl: String?
  public let eventDateText: String?
  public let method: String?
  public let referee: String?
  public let round: String?
  public let time: String?
  /// Amateur bouts are listed separately by the source and do not count
  /// towards the professional record.
  public let isAmateur: Bool

  public init(
    outcome: FightOutcome, opponentName: String, opponentUrl: String? = nil, eventName: String, eventUrl: String? = nil,
    eventDateText: String? = nil, method: String? = nil, referee: String? = nil, round: String? = nil,
    time: String? = nil, isAmateur: Bool = false
  ) {
    self.outcome = outcome
    self.opponentName = opponentName
    self.opponentUrl = opponentUrl
    self.eventName = eventName
    self.eventUrl = eventUrl
    self.eventDateText = eventDateText
    self.method = method
    self.referee = referee
    self.round = round
    self.time = time
    self.isAmateur = isAmateur
  }

  public var octagonTime: TimeInterval? { ScoreCardCore.octagonTime(round: round, time: time) }

  /// The four-digit year in `eventDateText` ("May / 09 / 2026"), or "".
  public var year: String { eventDateText?.firstMatch(of: /\d{4}/).map { String($0.output) } ?? "" }
}

/// A run of consecutive fights that ended the same way.
public struct FightStreak: Hashable, Sendable {
  public let outcome: FightOutcome
  public let count: Int

  public init(outcome: FightOutcome, count: Int) {
    self.outcome = outcome
    self.count = count
  }
}

public struct FighterProfile: Codable, Hashable, Sendable {
  public let name: String
  public let nationality: String?
  public let hometown: String?
  public let age: Int?
  public let birthDate: String?
  public let height: String?
  public let weight: String?
  public let association: String?
  public let weightClass: String?
  public let wins: Int
  public let losses: Int
  public let winsBreakdown: RecordBreakdown
  public let lossesBreakdown: RecordBreakdown
  public let fightHistory: [FighterFightRecord]

  public init(
    name: String, nationality: String? = nil, hometown: String? = nil, age: Int? = nil, birthDate: String? = nil,
    height: String? = nil, weight: String? = nil, association: String? = nil, weightClass: String? = nil, wins: Int,
    losses: Int, winsBreakdown: RecordBreakdown, lossesBreakdown: RecordBreakdown, fightHistory: [FighterFightRecord]
  ) {
    self.name = name
    self.nationality = nationality
    self.hometown = hometown
    self.age = age
    self.birthDate = birthDate
    self.height = height
    self.weight = weight
    self.association = association
    self.weightClass = weightClass
    self.wins = wins
    self.losses = losses
    self.winsBreakdown = winsBreakdown
    self.lossesBreakdown = lossesBreakdown
    self.fightHistory = fightHistory
  }

  public var draws: Int { fightHistory.count { $0.outcome == .draw } }
  public var noContests: Int { fightHistory.count { $0.outcome == .noContest } }

  /// "wins-losses-draws-noContests", e.g. "30-0-1-0".
  public var recordSummary: String { "\(wins)-\(losses)-\(draws)-\(noContests)" }

  /// Professional fights only, newest first: the source orders the history
  /// by date and lists amateur bouts separately from the record.
  public var professionalFights: [FighterFightRecord] { fightHistory.filter { !$0.isAmateur } }

  /// Consecutive same-result fights counted back from the most recent one.
  /// Scheduled bouts have no result, so they neither start nor break a run.
  public var currentStreak: FightStreak? {
    var outcome: FightOutcome?
    var count = 0
    for fight in professionalFights where fight.outcome != .pending {
      guard let current = outcome else {
        outcome = fight.outcome
        count = 1
        continue
      }
      if fight.outcome != current { break }
      count += 1
    }
    return outcome.map { FightStreak(outcome: $0, count: count) }
  }

  /// Longest run of wins anywhere in the professional history.
  public var bestWinStreak: Int { longestStreak(.win) }

  /// Longest run of losses anywhere in the professional history.
  public var worstLossStreak: Int { longestStreak(.loss) }

  /// Total time spent fighting across every professional bout with a result.
  public var totalOctagonTime: TimeInterval { professionalFights.reduce(0) { $0 + ($1.octagonTime ?? 0) } }

  private func longestStreak(_ outcome: FightOutcome) -> Int {
    var longest = 0
    var run = 0
    for fight in professionalFights where fight.outcome != .pending {
      if fight.outcome != outcome {
        run = 0
        continue
      }
      run += 1
      longest = max(longest, run)
    }
    return longest
  }
}

public enum CachedRequestKind: String, Sendable {
  case upcoming, pastPage, fightCard, fighterProfile
}

public struct CachedRequestInfo: Hashable, Identifiable, Sendable {
  public let url: String
  /// When this URL was first fetched and cached.
  public let cachedAt: Date
  /// The last time the entry was re-fetched (a pull-to-refresh). Equal to
  /// `cachedAt` until the first refresh.
  public let refreshedAt: Date
  /// How many times the cached entry has been served. A refresh never resets it.
  public let readCount: Int
  public let sizeBytes: Int
  public let kind: CachedRequestKind
  /// Only set for `.pastPage` entries.
  public let page: Int?

  public var id: String { url }

  public init(
    url: String, cachedAt: Date, refreshedAt: Date, readCount: Int, sizeBytes: Int, kind: CachedRequestKind,
    page: Int? = nil
  ) {
    self.url = url
    self.cachedAt = cachedAt
    self.refreshedAt = refreshedAt
    self.readCount = readCount
    self.sizeBytes = sizeBytes
    self.kind = kind
    self.page = page
  }
}
