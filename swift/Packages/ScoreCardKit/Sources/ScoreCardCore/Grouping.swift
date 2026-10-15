import Foundation

public struct MonthGroup: Identifiable, Sendable {
  /// First day of the month, in UTC.
  public let month: Date
  public var events: [MmaEvent]
  public var id: Date { month }
}

/// Groups consecutive events by month. Events already come in chronological
/// order from the source, so a single pass is enough.
public func groupEventsByMonth(_ events: [MmaEvent]) -> [MonthGroup] {
  var cal = Calendar(identifier: .gregorian)
  cal.timeZone = TimeZone(identifier: "UTC")!
  var groups: [MonthGroup] = []
  for event in events {
    let month = cal.date(from: cal.dateComponents([.year, .month], from: event.dateUtc))!
    if groups.last?.month == month {
      groups[groups.count - 1].events.append(event)
    } else {
      groups.append(MonthGroup(month: month, events: [event]))
    }
  }
  return groups
}

public struct FightYearGroup: Identifiable, Sendable {
  public let year: String
  public var fights: [FighterFightRecord]
  public var id: String { year }
}

/// Groups consecutive fights by year. The history is already newest first.
public func groupFightsByYear(_ fights: [FighterFightRecord]) -> [FightYearGroup] {
  var groups: [FightYearGroup] = []
  for fight in fights {
    if groups.last?.year == fight.year {
      groups[groups.count - 1].fights.append(fight)
    } else {
      groups.append(FightYearGroup(year: fight.year, fights: [fight]))
    }
  }
  return groups
}

/// KO/TKO, submission and decision counts across a fight card.
public struct CardStatistics: Equatable, Sendable {
  public var koTko = 0
  public var submissions = 0
  public var decisions = 0

  public init(_ fights: [EventFight]) {
    for method in fights.compactMap(\.method) {
      switch FightMethodKind(method: method) {
      case .koTko: koTko += 1
      case .submission: submissions += 1
      case .other: decisions += 1
      }
    }
  }

  public var isEmpty: Bool { koTko + submissions + decisions == 0 }
}

private func normalized(_ query: String) -> String { query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }

/// Matches event name, matchup and location, case-insensitively.
public func filterEvents(_ events: [MmaEvent], _ query: String) -> [MmaEvent] {
  let q = normalized(query)
  guard !q.isEmpty else { return events }
  return events.filter {
    $0.eventName.lowercased().contains(q) || ($0.matchup?.lowercased().contains(q) ?? false)
      || $0.location.lowercased().contains(q)
  }
}

/// Matches both fighters and the division.
public func filterFights(_ fights: [EventFight], _ query: String) -> [EventFight] {
  let q = normalized(query)
  guard !q.isEmpty else { return fights }
  return fights.filter {
    $0.fighterA.lowercased().contains(q) || $0.fighterB.lowercased().contains(q)
      || $0.weightClass.lowercased().contains(q)
  }
}

/// Matches the opponent and the event a fight belongs to.
public func filterFightHistory(_ fights: [FighterFightRecord], _ query: String) -> [FighterFightRecord] {
  let q = normalized(query)
  guard !q.isEmpty else { return fights }
  return fights.filter { $0.opponentName.lowercased().contains(q) || $0.eventName.lowercased().contains(q) }
}
