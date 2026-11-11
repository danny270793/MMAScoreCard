import ScoreCardCore
import ScoreCardData
import SwiftUI

/// The system search tab, at the bottom of every screen.
///
/// Opened from an event it searches that card (fighter or division), from a
/// fighter their bouts (by opponent), from a Browse list that list (by name).
/// Opened from anywhere else it searches everything: with Supabase every
/// stored event (name, headline, venue, city or country), fighter (name or
/// nickname), referee and place; without it, upcoming and loaded past events.
struct SearchView: View {
  @Environment(EventsStore.self) private var store
  @Environment(TabChrome.self) private var chrome
  @State private var query = ""

  var body: some View {
    let trimmed = query.trimmingCharacters(in: .whitespaces)
    Group {
      switch chrome.scope {
      case .event(let event, let fights):
        ScopedFightsList(event: event, fights: fights, query: trimmed)
      case .fighter(let fighter, let history):
        ScopedHistoryList(fighter: fighter, history: history, query: trimmed)
      case .browse(let kind):
        BrowseListView(kind: kind, query: trimmed)
      case nil:
        GlobalSearchList(query: trimmed)
      }
    }
    .searchable(text: $query, prompt: prompt)
    // A new scope starts with an empty field.
    .onChange(of: chrome.scope?.key) { query = "" }
  }

  private var prompt: String {
    switch chrome.scope {
    case .event: L("searchFightsHint")
    case .fighter: L("searchHistoryHint")
    case .browse: L("browseSearchHint")
    case nil: L("searchHint")
    }
  }
}

/// An event's card, filtered by fighter or division.
private struct ScopedFightsList: View {
  let event: MmaEvent
  let fights: [EventFight]
  let query: String

  var body: some View {
    let matches = filterFights(fights, query)
    List {
      if matches.isEmpty { ContentUnavailableView.search(text: query).listRowBackground(Color.clear) }
      Section(L("eventDetailFightCardLabel")) {
        ForEach(Array(matches.enumerated()), id: \.offset) { _, fight in
          NavigationLink(value: FightRoute(event: event, fight: fight)) { FightRow(fight: fight) }
            .fightMenu(fight, event: event)
            .listRowBackground(fight.isTitleFight ? Color.yellow.opacity(0.12) : nil)
        }
      }
    }
    .fightMenuDestinations()
    .navigationTitle(event.eventName)
    .toolbarTitleDisplayMode(.inline)
  }
}

/// A fighter's bouts, filtered by opponent.
private struct ScopedHistoryList: View {
  let fighter: FighterRoute
  let history: [FighterFightRecord]
  let query: String

  var body: some View {
    let matches = query.isEmpty ? history : history.filter { $0.opponentName.localizedCaseInsensitiveContains(query) }
    List {
      if matches.isEmpty { ContentUnavailableView.search(text: query).listRowBackground(Color.clear) }
      ForEach(Array(groupFightsByYear(matches).enumerated()), id: \.offset) { _, group in
        Section(group.year) {
          ForEach(Array(group.fights.enumerated()), id: \.offset) { _, record in
            let row = HistoryRow(record: record, isTitleFight: false)
              .listRowBackground(record.isAmateur ? Color.purple.opacity(0.07) : nil)
            Group {
              if let url = record.opponentUrl {
                NavigationLink(value: FighterRoute(name: record.opponentName, url: url)) { row }
              } else {
                row
              }
            }
            .historyMenu(record, isTitleFight: false)
          }
        }
      }
    }
    .fightMenuDestinations()
    .navigationTitle(fighter.name)
    .toolbarTitleDisplayMode(.inline)
  }
}

/// Everything: events, fighters, referees and places.
private struct GlobalSearchList: View {
  @Environment(EventsStore.self) private var store
  let query: String
  @State private var results: SearchResults?
  /// Referees, cities, countries and venues matching the query, a few of each.
  @State private var others: [(BrowseKind, [BrowseItem])] = []
  @State private var searching = false
  @State private var failed = false

  private static let otherKinds: [BrowseKind] = [.referees, .cities, .countries, .locations]

  var body: some View {
    List {
      if query.isEmpty {
        ContentUnavailableView(
          L("tabSearch"), systemImage: "magnifyingglass", description: Text(L("searchEmptyPrompt"))
        )
        .listRowBackground(Color.clear)
      } else if store.repo.readsFromBackend {
        serverResults
      } else {
        localResults
      }
    }
    .navigationTitle(L("tabSearch"))
    .task(id: query) { await search(query) }
  }

  @ViewBuilder private var serverResults: some View {
    if let results {
      if results.events.isEmpty && results.fighters.isEmpty && others.isEmpty {
        ContentUnavailableView.search(text: query).listRowBackground(Color.clear)
      }
      if !results.fighters.isEmpty {
        Section(L("searchFightersSection")) {
          ForEach(results.fighters, id: \.url) { f in
            NavigationLink(value: FighterRoute(name: f.name, url: f.url)) {
              VStack(alignment: .leading, spacing: 2) {
                Text(f.name).font(.body.weight(.semibold))
                if let nickname = f.nickname { Text("“\(nickname)”").font(.caption).foregroundStyle(.secondary) }
              }
            }
          }
        }
      }
      ForEach(others, id: \.0) { kind, items in
        Section(kind.title) {
          ForEach(items) { item in
            NavigationLink(value: BrowseItemRoute(kind: kind, item: item)) {
              HStack {
                VStack(alignment: .leading, spacing: 2) {
                  Text(item.name)
                  if let subtitle = item.subtitle, !subtitle.isEmpty {
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                  }
                }
                Spacer(minLength: 12)
                Text("\(item.count)").monospacedDigit().foregroundStyle(.secondary).fixedSize()
              }
            }
          }
        }
      }
      EventSections(events: results.events)
    } else if failed {
      ContentUnavailableView(L("searchTabSearchFailed"), systemImage: "wifi.exclamationmark")
        .listRowBackground(Color.clear)
    } else if searching {
      ProgressView().frame(maxWidth: .infinity).listRowBackground(Color.clear)
    }
  }

  @ViewBuilder private var localResults: some View {
    let matches = filterEvents((store.upcoming.value ?? []) + store.past, query)
    if matches.isEmpty {
      ContentUnavailableView.search(text: query).listRowBackground(Color.clear)
    }
    EventSections(events: matches)
    if store.pastHasMore {
      Section {
        Button {
          Task { await store.loadNextPastPage() }
        } label: {
          HStack {
            Label(L("loadMore"), systemImage: "arrow.down.circle")
            Spacer()
            if store.pastLoading { ProgressView() }
          }
        }
        .disabled(store.pastLoading)
      } footer: {
        Text(L("searchTabPrompt"))
      }
    }
  }

  /// Waits for typing to pause, then asks Supabase; a newer query cancels this one.
  private func search(_ q: String) async {
    guard store.repo.readsFromBackend, !q.isEmpty else {
      results = nil
      others = []
      return
    }
    searching = true
    defer { searching = false }
    try? await Task.sleep(for: .milliseconds(300))
    guard !Task.isCancelled else { return }
    do {
      async let found = store.repo.search(q)
      async let matched = self.others(q)
      let (r, o) = try await (found, matched)
      guard !Task.isCancelled else { return }
      results = r
      others = o
      failed = false
    } catch {
      guard !Task.isCancelled else { return }
      results = nil
      others = []
      failed = true
    }
  }

  /// The busiest few of each kind; a kind that fails is just left out.
  private func others(_ q: String) async -> [(BrowseKind, [BrowseItem])] {
    guard let browser = store.repo.browser else { return [] }
    return await withTaskGroup(of: (BrowseKind, [BrowseItem]).self) { group in
      for kind in Self.otherKinds {
        group.addTask { (kind, (try? await browser.browse(kind, query: q, sort: .count, page: 1, limit: 5)) ?? []) }
      }
      var found: [BrowseKind: [BrowseItem]] = [:]
      for await (kind, items) in group { found[kind] = items }
      return Self.otherKinds.compactMap { k in found[k].flatMap { $0.isEmpty ? nil : (k, $0) } }
    }
  }
}
