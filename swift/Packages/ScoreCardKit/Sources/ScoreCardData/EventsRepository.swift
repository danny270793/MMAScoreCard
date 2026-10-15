import Foundation
import ScoreCardCore

/// Cache-first access to event data. Plain reads serve the cached copy when
/// there is one and only hit the network otherwise; `refresh: true`
/// (pull-to-refresh, retry) always fetches and overwrites the cache.
public final class EventsRepository: Sendable {
  private let source: any EventsSource
  private let cache: EventsCache

  public init(source: any EventsSource = FallbackEventsSource([SherdogSource()]), cache: EventsCache = EventsCache()) {
    self.source = source
    self.cache = cache
  }

  public func upcomingEvents(refresh: Bool = false) async throws -> [MmaEvent] {
    if !refresh, let cached = await cache.upcoming() { return cached }
    let events = try await source.upcomingEvents()
    await cache.saveUpcoming(events)
    return events
  }

  /// Every past page already on disk, plus whether more pages exist.
  public func cachedPastPages() async -> (pages: [Int: [MmaEvent]], hasMore: Bool) {
    (await cache.pastPages(), await cache.pastHasMore)
  }

  public func fetchPastPage(_ page: Int) async throws -> EventsPage {
    let result = try await source.pastEvents(page: page)
    await cache.savePastPage(page, result.events, hasMore: result.hasMore)
    return result
  }

  public func eventFights(_ eventUrl: String, refresh: Bool = false) async throws -> [EventFight] {
    if !refresh, let cached = await cache.fights(eventUrl) { return cached }
    let fights = try await source.eventFights(eventUrl)
    await cache.saveFights(eventUrl, fights)
    return fights
  }

  public func fighterProfile(_ fighterUrl: String, refresh: Bool = false) async throws -> FighterProfile {
    if !refresh, let cached = await cache.fighter(fighterUrl) { return cached }
    let profile = try await source.fighterProfile(fighterUrl)
    await cache.saveFighter(fighterUrl, profile)
    return profile
  }

  public func cachedRequests() async -> [CachedRequestInfo] { await cache.requests() }
}
