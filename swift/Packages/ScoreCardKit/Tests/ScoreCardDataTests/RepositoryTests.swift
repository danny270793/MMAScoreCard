import Foundation
import ScoreCardCore
import Testing

@testable import ScoreCardData

private actor FakeSource: EventsSource {
  var calls = 0
  var upcoming: [MmaEvent] = []

  func set(_ events: [MmaEvent]) { upcoming = events }
  func upcomingEvents() async throws -> [MmaEvent] {
    calls += 1
    return upcoming
  }
  func pastEvents(page: Int) async throws -> EventsPage { EventsPage(events: [], page: page, hasMore: page < 2) }
  func eventFights(_ eventUrl: String) async throws -> [EventFight] { [] }
  func fighterProfile(_ fighterUrl: String) async throws -> FighterProfile { throw EventsSourceError("offline") }
}

struct RepositoryTests {
  private func tempDir() -> URL {
    FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
  }

  private let event = MmaEvent(
    id: "1", eventName: "UFC 1", matchup: nil, dateUtc: Date(timeIntervalSince1970: 0), location: "Denver",
    url: "https://www.sherdog.com/events/UFC-1-1", isUpcoming: true)

  @Test func upcomingIsFetchedOnceThenServedFromCache() async throws {
    let source = FakeSource()
    await source.set([event])
    let repo = EventsRepository(source: source, cache: EventsCache(directory: tempDir()))
    _ = try await repo.upcomingEvents()
    let second = try await repo.upcomingEvents()
    #expect(second == [event])
    #expect(await source.calls == 1)
    _ = try await repo.upcomingEvents(refresh: true)
    #expect(await source.calls == 2)
  }

  @Test func cacheSurvivesRelaunchAndCountsReads() async throws {
    let dir = tempDir()
    let source = FakeSource()
    await source.set([event])
    _ = try await EventsRepository(source: source, cache: EventsCache(directory: dir)).upcomingEvents()

    let reopened = EventsRepository(source: source, cache: EventsCache(directory: dir))
    #expect(try await reopened.upcomingEvents() == [event])
    _ = try await reopened.upcomingEvents(refresh: true)
    let info = try #require(await reopened.cachedRequests().first)
    #expect(info.kind == .upcoming)
    #expect(info.readCount == 1)
    #expect(info.refreshedAt >= info.cachedAt)
    #expect(info.sizeBytes > 0)
  }

  @Test func pastPagesAndHasMoreArePersisted() async throws {
    let dir = tempDir()
    let repo = EventsRepository(source: FakeSource(), cache: EventsCache(directory: dir))
    _ = try await repo.fetchPastPage(1)
    _ = try await repo.fetchPastPage(2)
    let cached = await EventsRepository(source: FakeSource(), cache: EventsCache(directory: dir)).cachedPastPages()
    #expect(cached.pages.keys.sorted() == [1, 2])
    #expect(!cached.hasMore)
  }

  @Test func fallbackTriesTheNextSource() async throws {
    struct Broken: EventsSource {
      func upcomingEvents() async throws -> [MmaEvent] { throw EventsSourceError("down") }
      func pastEvents(page: Int) async throws -> EventsPage { throw EventsSourceError("down") }
      func eventFights(_ eventUrl: String) async throws -> [EventFight] { throw EventsSourceError("down") }
      func fighterProfile(_ fighterUrl: String) async throws -> FighterProfile { throw EventsSourceError("down") }
    }
    let good = FakeSource()
    await good.set([event])
    #expect(try await FallbackEventsSource([Broken(), good]).upcomingEvents() == [event])
    await #expect(throws: EventsSourceError.self) { try await FallbackEventsSource([Broken()]).upcomingEvents() }
  }
}
