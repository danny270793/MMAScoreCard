import Foundation
import ScoreCardCore
import SwiftSoup
import Testing

@testable import ScoreCardData

/// Parses trimmed copies of real Sherdog pages saved under `Fixtures/`.
struct SherdogParserTests {
  private func fixture(_ name: String) throws -> Document {
    let url = try #require(Bundle.module.url(forResource: name, withExtension: "html", subdirectory: "Fixtures"))
    return try SwiftSoup.parse(String(contentsOf: url, encoding: .utf8))
  }

  @Test func pastPageReadsTheRecentTableAndPagination() throws {
    let page = try SherdogParser.pastPage(fixture("past_page"), page: 2)
    #expect(page.events.count == 3)
    #expect(page.hasMore)
    let first = try #require(page.events.first)
    #expect(first.eventName == "UFC")
    #expect(first.matchup == "Road to UFC Season 3: Las Vegas Semifinals 2")
    #expect(first.id == "103685")
    #expect(first.url == "https://www.sherdog.com/events/UFC-Road-to-UFC-Season-3-Las-Vegas-Semifinals-2-103685")
    #expect(!first.isUpcoming)
    #expect(page.events[2].eventName == "UFC 305")
    #expect(page.events[2].matchup == "Du Plessis vs. Adesanya")
  }

  @Test func lastPageHasNoMore() throws {
    #expect(try !SherdogParser.pastPage(fixture("past_page"), page: 3).hasMore)
  }

  @Test func fightCardReadsHeadlinerAndRows() throws {
    let fights = try SherdogParser.fights(fixture("event"))
    #expect(fights.count == 3)
    let main = fights[0]
    #expect(main.fighterA == "Bin Xie")
    #expect(main.fighterB == "Masuto Kawana")
    #expect(main.fighterAUrl == "https://www.sherdog.com/fighter/Bin-Xie-231979")
    #expect(main.weightClass == "Featherweight")
    #expect(main.outcomeA == .win)
    #expect(main.outcomeB == .loss)
    #expect(main.method == "KO (Punches)")
    #expect(main.round == "1")
    #expect(main.time == "4:17")
    #expect(main.referee == "Herb Dean")
    // Names split with <br> keep their space.
    #expect(fights[1].fighterA == "Ming Shi")
    #expect(fights[1].fighterB == "Huaxiang Dong")
    #expect(fights[1].method == "Decision (Split)")
    #expect(fights[1].referee == "Mark Smith")
    #expect(fights[1].round == "3")
    #expect(fights[1].time == "5:00")
  }

  @Test func fighterProfile() throws {
    let p = try SherdogParser.fighter(fixture("fighter"))
    #expect(p.name == "Joaquin Buckley")
    #expect(p.nationality == "United States")
    #expect(p.hometown == "St. Louis, Missouri")
    #expect(p.age == 32)
    #expect(p.birthDate == "Apr 27, 1994")
    #expect(p.height == "5'8\" (172.72 cm)")
    #expect(p.weight == "170 lbs (77.11 kg)")
    #expect(p.association == "Murcielago MMA")
    #expect(p.weightClass == "Welterweight")
    #expect(p.wins == 21)
    #expect(p.losses == 8)
    #expect(p.winsBreakdown.koTko == RecordMeter(count: 15, percent: 71))
    #expect(p.fightHistory.count == 5)
    #expect(p.fightHistory[0].opponentName == "Sean Brady")
    #expect(p.fightHistory[0].eventDateText == "May / 09 / 2026")
    #expect(p.fightHistory[0].referee == "Keith Peterson")
    #expect(p.fightHistory.last?.isAmateur == true)
    #expect(p.professionalFights.count == 4)
    #expect(p.currentStreak == FightStreak(outcome: .loss, count: 2))
  }

  @Test func historyDateSortsByYearMonthDay() {
    #expect(SherdogParser.historyDate("May / 09 / 2026") == 2026_05_09)
    #expect(SherdogParser.historyDate("bad") == nil)
  }
}
