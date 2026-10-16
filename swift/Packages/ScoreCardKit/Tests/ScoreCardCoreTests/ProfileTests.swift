import Foundation
import Testing

@testable import ScoreCardCore

struct ProfileTests {
  private let none = RecordBreakdown(koTko: .zero, submissions: .zero, decisions: .zero)

  private func fight(_ outcome: FightOutcome, _ date: String = "Jan / 01 / 2024", amateur: Bool = false,
                     round: String? = "3", time: String? = "5:00") -> FighterFightRecord {
    FighterFightRecord(outcome: outcome, opponentName: "X", eventName: "E", eventDateText: date, round: round,
                       time: time, isAmateur: amateur)
  }

  private func profile(_ fights: [FighterFightRecord]) -> FighterProfile {
    FighterProfile(name: "A", wins: 0, losses: 0, winsBreakdown: none, lossesBreakdown: none, fightHistory: fights)
  }

  @Test func octagonTimeCountsFullRoundsPlusTheLastOne() {
    #expect(octagonTime(round: "5", time: "5:00") == TimeInterval(25 * 60))
    #expect(octagonTime(round: "2", time: "3:45") == TimeInterval(8 * 60 + 45))
    #expect(octagonTime(round: nil, time: "1:00") == nil)
    #expect(octagonTime(round: "0", time: "1:00") == nil)
    #expect(octagonTime(round: "1", time: "bad") == nil)
  }

  @Test func currentStreakSkipsScheduledFights() {
    let p = profile([fight(.pending), fight(.win), fight(.win), fight(.loss), fight(.win)])
    #expect(p.currentStreak == FightStreak(outcome: .win, count: 2))
    #expect(profile([fight(.pending)]).currentStreak == nil)
  }

  @Test func bestAndWorstStreaksIgnoreAmateurBouts() {
    let p = profile([
      fight(.win), fight(.loss), fight(.loss), fight(.win), fight(.pending), fight(.win), fight(.win),
      fight(.loss, amateur: true), fight(.loss, amateur: true), fight(.loss, amateur: true),
    ])
    #expect(p.bestWinStreak == 3)
    #expect(p.worstLossStreak == 2)
  }

  @Test func recordSummaryAndTotalTime() {
    let p = profile([fight(.draw), fight(.noContest, round: "1", time: "0:30"), fight(.win, amateur: true)])
    #expect(p.recordSummary == "0-0-1-1")
    #expect(p.totalOctagonTime == 15 * 60 + 30)
  }

  @Test func groupsByYearInOrder() {
    let groups = groupFightsByYear([fight(.win, "May / 09 / 2026"), fight(.win, "Jan / 01 / 2026"),
                                    fight(.loss, "Dec / 14 / 2024"), fight(.win, "")])
    #expect(groups.map(\.year) == ["2026", "2024", ""])
    #expect(groups[0].fights.count == 2)
  }

  @Test func methodKind() {
    #expect(FightMethodKind(method: "KO (Punches)") == .koTko)
    #expect(FightMethodKind(method: "TKO (Doctor Stoppage)") == .koTko)
    #expect(FightMethodKind(method: "Submission (Rear-Naked Choke)") == .submission)
    #expect(FightMethodKind(method: "Decision (Unanimous)") == .other)
  }
}
