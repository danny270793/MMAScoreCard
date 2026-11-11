import Foundation
import ScoreCardCore

/// Event data with an on-device copy.
///
/// With a backend (`refresher`, the Supabase setup): every read goes to the
/// backend, which is cheap. The source keeps the last response of each
/// request and serves it when the backend can't be reached, so this type
/// doesn't cache anything itself. `refresh: true` (pull-to-refresh, retry)
/// first asks the backend to re-read Sherdog, then reads.
///
/// Without one (scraping Sherdog directly): reads serve the cached copy when
/// there is one, and only `refresh: true` hits the network, to keep Sherdog
/// requests to a minimum.
public final class EventsRepository: Sendable {
  private let source: any EventsSource
  private let refresher: (any EventsRefreshing)?
  private let cache: EventsCache

  public init(
    source: any EventsSource = FallbackEventsSource([SherdogSource()]), refresher: (any EventsRefreshing)? = nil,
    cache: EventsCache = EventsCache()
  ) {
    self.source = source
    self.refresher = refresher
    self.cache = cache
  }

  /// Supabase when `MMAConfig.plist` is set up, otherwise Sherdog directly.
  public static func live(config: SupabaseConfig? = .fromBundle()) -> EventsRepository {
    guard let config else { return EventsRepository() }
    let cache = EventsCache()
    // Copies saved before reads moved to Supabase are never read again.
    Task { await cache.removeNonResponseEntries() }
    let supabase = SupabaseEventsSource(config: config, cache: cache)
    return EventsRepository(source: supabase, refresher: supabase, cache: cache)
  }

  /// Whether reads come from the backend (and the cache is just a fallback).
  public var readsFromBackend: Bool { refresher != nil }

  public func upcomingEvents(refresh: Bool = false) async throws -> [MmaEvent] {
    if refresh { await refresher?.refreshEvents() }
    return try await read(
      refresh: refresh, cached: { await self.cache.upcoming() }, save: { await self.cache.saveUpcoming($0) }
    ) { try await self.source.upcomingEvents() }
  }

  /// Every past page already on disk, plus whether more pages exist.
  public func cachedPastPages() async -> (pages: [Int: [MmaEvent]], hasMore: Bool) {
    if readsFromBackend { return ([:], true) }
    return (await cache.pastPages(), await cache.pastHasMore)
  }

  public func fetchPastPage(_ page: Int) async throws -> EventsPage {
    let result = try await source.pastEvents(page: page)
    if !readsFromBackend { await cache.savePastPage(page, result.events, hasMore: result.hasMore) }
    return result
  }

  /// An event by its Sherdog link, from the backend; nil without one or when
  /// it isn't stored (events of other promotions).
  public func event(_ eventUrl: String) async throws -> MmaEvent? {
    guard let supabase = source as? SupabaseEventsSource else { return nil }
    return try await supabase.event(eventUrl)
  }

  /// Searches every stored event and fighter; nil without a backend (search
  /// the loaded lists instead).
  public func search(_ query: String) async throws -> SearchResults? {
    guard let supabase = source as? SupabaseEventsSource else { return nil }
    return try await supabase.search(query)
  }

  /// The Browse tab's lists and what each item was involved in (backend only).
  public var browser: SupabaseEventsSource? { source as? SupabaseEventsSource }

  /// Asks the backend to re-read the event lists (no-op without one).
  public func refreshEventLists() async { await refresher?.refreshEvents() }

  public func eventFights(_ eventUrl: String, refresh: Bool = false) async throws -> [EventFight] {
    if refresh { await refresher?.refreshEvent(eventUrl) }
    return try await read(
      refresh: refresh, cached: { await self.cache.fights(eventUrl) },
      save: { await self.cache.saveFights(eventUrl, $0) }
    ) { try await self.source.eventFights(eventUrl) }
  }

  public func fighterProfile(_ fighterUrl: String, refresh: Bool = false) async throws -> FighterProfile {
    if refresh { await refresher?.refreshFighter(fighterUrl) }
    return try await read(
      refresh: refresh, cached: { await self.cache.fighter(fighterUrl) },
      save: { await self.cache.saveFighter(fighterUrl, $0) }
    ) { try await self.source.fighterProfile(fighterUrl) }
  }

  /// Saved entries for the settings screen (with the backend, its saved responses).
  public func cachedRequests() async -> [CachedRequestInfo] {
    if readsFromBackend { await cache.removeNonResponseEntries() }
    return await cache.requests()
  }

  /// Backend: always fetch (the source falls back to its saved responses).
  /// Direct scraping: cache first unless refreshing, and save what's fetched.
  private func read<T>(
    refresh: Bool, cached: () async -> T?, save: (T) async -> Void, fetch: () async throws -> T
  ) async throws -> T {
    if readsFromBackend { return try await fetch() }
    if !refresh, let value = await cached() { return value }
    let value = try await fetch()
    await save(value)
    return value
  }
}
