import ScoreCardCore
import SwiftUI

enum Fmt {
  /// Sherdog dates are calendar days at midnight UTC; format them in UTC so
  /// they never shift to the previous day west of Greenwich.
  static func date(_ d: Date, _ style: Date.FormatStyle) -> String {
    var s = style
    s.timeZone = TimeZone(identifier: "UTC")!
    return d.formatted(s.locale(L10n.locale))
  }

  static func eventDate(_ d: Date) -> String { date(d, .dateTime.year().month(.abbreviated).day()) }
  static func month(_ d: Date) -> String { date(d, .dateTime.year().month(.wide)) }

  /// "8m 45s" for a single bout, "3h 27m" once a career total passes an hour.
  static func octagonTime(_ t: TimeInterval) -> String {
    let s = Int(t)
    return s >= 3600
      ? L("durationHoursMinutes", s / 3600, s % 3600 / 60) : L("durationMinutesSeconds", s / 60, s % 60)
  }

  /// Nil for `.pending`, which has no result to count.
  static func streak(_ outcome: FightOutcome, _ count: Int) -> String? {
    switch outcome {
    case .win: L("streakWins", count)
    case .loss: L("streakLosses", count)
    case .draw: L("streakDraws", count)
    case .noContest: L("streakNoContests", count)
    case .pending: nil
    }
  }
}

extension FightOutcome {
  var label: String? {
    switch self {
    case .win: L("fightOutcomeWin")
    case .loss: L("fightOutcomeLoss")
    case .draw: L("fightOutcomeDraw")
    case .noContest: L("fightOutcomeNoContest")
    case .pending: nil
    }
  }

  var color: Color {
    switch self {
    case .win: .green
    case .loss: .red
    default: .secondary
    }
  }
}

extension FightMethodKind {
  var symbol: String {
    switch self {
    case .koTko: "figure.boxing"
    case .submission: "figure.wrestling"
    case .other: "list.clipboard"
    }
  }

  var color: Color {
    switch self {
    case .koTko: .red
    case .submission: .purple
    case .other: .blue
    }
  }
}
