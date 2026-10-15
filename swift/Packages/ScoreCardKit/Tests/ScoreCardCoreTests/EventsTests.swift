import Foundation
import Testing

@testable import ScoreCardCore

struct EventsTests {
  private func event(_ name: String, _ iso: String, matchup: String? = nil, location: String = "Las Vegas") -> MmaEvent {
    MmaEvent(id: name, eventName: name, matchup: matchup, dateUtc: ISO8601DateFormatter().date(from: iso)!,
             location: location, url: "u/\(name)", isUpcoming: true)
  }

  @Test func daysUntilCountsCalendarDaysInUTC() {
    let e = event("A", "2026-10-17T00:00:00Z")
    #expect(e.daysUntil(ISO8601DateFormatter().date(from: "2026-10-15T23:59:00Z")!) == 2)
    #expect(e.daysUntil(ISO8601DateFormatter().date(from: "2026-10-17T12:00:00Z")!) == 0)
  }

  @Test func groupsConsecutiveEventsByMonth() {
    let groups = groupEventsByMonth([event("A", "2026-10-17T00:00:00Z"), event("B", "2026-10-31T00:00:00Z"),
                                     event("C", "2026-11-07T00:00:00Z")])
    #expect(groups.map { $0.events.map(\.eventName) } == [["A", "B"], ["C"]])
  }

  @Test func searchMatchesNameMatchupAndLocation() {
    let events = [event("UFC 333", "2026-10-24T00:00:00Z", matchup: "Volkanovski vs. Evloev", location: "Abu Dhabi"),
                  event("UFC FN", "2026-10-31T00:00:00Z", matchup: "Moicano vs. Nolan")]
    #expect(filterEvents(events, " evloev ").map(\.eventName) == ["UFC 333"])
    #expect(filterEvents(events, "ABU").count == 1)
    #expect(filterEvents(events, "").count == 2)
  }

  @Test func cardStatisticsCountsMethods() {
    let fights = ["KO (Punch)", "Submission (Armbar)", "Decision (Split)", nil].map {
      EventFight(fighterA: "A", fighterB: "B", weightClass: "Lightweight", isTitleFight: false, outcomeA: .win,
                 outcomeB: .loss, method: $0)
    }
    let s = CardStatistics(fights)
    #expect(s.koTko == 1 && s.submissions == 1 && s.decisions == 1)
    #expect(filterFights(fights, "lightweight").count == 4)
  }
}
