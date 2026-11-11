import Foundation
import ScoreCardCore
import ScoreCardData

/// Loading / data / error for one resource. A failed refresh keeps the last
/// good data; `.failed` is only reached when there is nothing to show.
enum Loadable<T> {
  case loading
  case loaded(T)
  case failed

  var value: T? {
    if case .loaded(let v) = self { return v }
    return nil
  }

  /// Runs `fetch`; on error keeps what was already loaded.
  func reloaded(_ fetch: () async throws -> T) async -> Loadable<T> {
    do {
      return .loaded(try await fetch())
    } catch {
      return value == nil ? .failed : self
    }
  }
}

/// Upcoming and past event lists, shared by their tabs and Search.
///
/// Data comes from Supabase (the on-device cache only fills in when offline);
/// pull-to-refresh asks the backend to re-read Sherdog first. Without
/// `MMAConfig.plist` the app scrapes Sherdog itself, cache first.
@MainActor @Observable
final class EventsStore {
  let repo: EventsRepository

  private(set) var upcoming: Loadable<[MmaEvent]> = .loading

  private var pastPages: [Int: [MmaEvent]] = [:]
  private(set) var past: [MmaEvent] = []
  private(set) var pastHasMore = true
  private(set) var pastLoading = false
  private(set) var pastFailed = false
  private var pastStarted = false

  init(repo: EventsRepository = .live()) {
    self.repo = repo
  }

  func loadUpcoming(refresh: Bool = false) async {
    upcoming = await upcoming.reloaded { try await repo.upcomingEvents(refresh: refresh) }
  }

  /// Shows every cached past page, then reads page 1 (always from the
  /// backend; from Sherdog only when nothing is cached).
  func loadPast() async {
    guard !pastStarted else { return }
    pastStarted = true
    let cached = await repo.cachedPastPages()
    pastPages = cached.pages
    pastHasMore = cached.hasMore
    flatten()
    if pastPages.isEmpty || repo.readsFromBackend { await loadPastPage(1) }
  }

  /// Pull-to-refresh: the backend re-reads Sherdog, then page 1 is read again.
  func refreshPast() async {
    await repo.refreshEventLists()
    await loadPastPage(1)
  }

  /// Infinite scroll: the page after the last one loaded.
  func loadNextPastPage() async {
    guard !pastLoading, pastHasMore || pastPages.isEmpty else { return }
    await loadPastPage((pastPages.keys.max() ?? 0) + 1)
  }

  private func loadPastPage(_ page: Int) async {
    pastLoading = true
    defer { pastLoading = false }
    do {
      let result = try await repo.fetchPastPage(page)
      pastPages[page] = result.events
      pastHasMore = result.hasMore
      pastFailed = false
      flatten()
    } catch {
      pastFailed = true
    }
  }

  private func flatten() {
    past = pastPages.keys.sorted().flatMap { pastPages[$0] ?? [] }
  }
}
