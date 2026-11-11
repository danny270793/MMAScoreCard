import ScoreCardCore
import ScoreCardData
import SwiftUI

extension BrowseKind {
  var title: String {
    switch self {
    case .cities: L("browseCities")
    case .countries: L("browseCountries")
    case .fighters: L("browseFighters")
    case .locations: L("browseLocations")
    case .referees: L("browseReferees")
    }
  }

  var symbol: String {
    switch self {
    case .cities: "building.2"
    case .countries: "globe.americas"
    case .fighters: "figure.martial.arts"
    case .locations: "mappin.and.ellipse"
    case .referees: "person.badge.shield.checkmark"
    }
  }

  var color: Color {
    switch self {
    case .cities: .indigo
    case .countries: .teal
    case .fighters: .red
    case .locations: .orange
    case .referees: .gray
    }
  }
}

/// One Browse item opened from its list.
struct BrowseItemRoute: Hashable {
  let kind: BrowseKind
  let item: BrowseItem
}

/// The Browse tab: cities, countries, fighters, locations and referees.
struct BrowseView: View {
  var body: some View {
    List {
      ForEach(BrowseKind.allCases, id: \.self) { kind in
        NavigationLink(value: kind) {
          Label {
            Text(kind.title)
          } icon: {
            Image(systemName: kind.symbol).foregroundStyle(.white)
              .frame(width: 30, height: 30)
              .background(kind.color.gradient, in: .rect(cornerRadius: 7))
          }
        }
      }
    }
    .navigationTitle(L("tabBrowse"))
    .navigationDestination(for: BrowseKind.self) { BrowseListView(kind: $0) }
  }
}

/// A Browse list, 100 at a time, sorted by name or by most events / bouts
/// (remembered per list). The search button opens it in the search tab,
/// filtered on the server by `query`.
struct BrowseListView: View {
  @Environment(EventsStore.self) private var store
  let kind: BrowseKind
  let query: String
  @AppStorage private var sortRaw: String
  @State private var items: [BrowseItem] = []
  @State private var page = 0
  @State private var hasMore = true
  @State private var loading = false
  @State private var failed = false

  init(kind: BrowseKind, query: String = "") {
    self.kind = kind
    self.query = query
    _sortRaw = AppStorage(wrappedValue: BrowseSort.name.rawValue, "browseSort.\(kind.rawValue)")
  }

  private var sort: BrowseSort { BrowseSort(rawValue: sortRaw) ?? .name }

  var body: some View {
    let trimmed = query.trimmingCharacters(in: .whitespaces)
    List {
      if items.isEmpty {
        if loading {
          ProgressView().frame(maxWidth: .infinity).listRowBackground(Color.clear)
        } else if failed {
          LoadStateView(kind: .failed(L("searchTabSearchFailed")) { await reload(trimmed) })
            .listRowBackground(Color.clear)
        } else if !trimmed.isEmpty {
          ContentUnavailableView.search(text: trimmed).listRowBackground(Color.clear)
        } else {
          ContentUnavailableView(L("browseEmpty"), systemImage: kind.symbol).listRowBackground(Color.clear)
        }
      }
      ForEach(items) { item in
        NavigationLink(value: BrowseItemRoute(kind: kind, item: item)) {
          HStack {
            VStack(alignment: .leading, spacing: 2) {
              Text(item.name)
              if let subtitle = item.subtitle, !subtitle.isEmpty {
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
              }
            }
            Spacer(minLength: 12)
            // Fixed size so a long name wraps instead of pushing the count down.
            Text("\(item.count)").monospacedDigit().foregroundStyle(.secondary).fixedSize()
          }
        }
      }
      if hasMore && !items.isEmpty {
        ProgressView().frame(maxWidth: .infinity)
          .task { await loadPage(page + 1, trimmed) }
      }
    }
    .navigationTitle(kind.title)
    .searchScope(query.isEmpty ? .browse(kind) : nil)
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Menu {
          Picker(L("browseSortBy"), selection: $sortRaw) {
            Label(L("browseSortName"), systemImage: "textformat").tag(BrowseSort.name.rawValue)
            Label(L(kind.listsEvents ? "browseSortMostEvents" : "browseSortMostFights"), systemImage: "number")
              .tag(BrowseSort.count.rawValue)
          }
        } label: {
          Label(L("browseSortBy"), systemImage: "arrow.up.arrow.down")
        }
      }
    }
    .refreshable { await reload(trimmed) }
    .onChange(of: sortRaw) { Task { await reload(trimmed) } }
    .task(id: trimmed) {
      // Waits for typing to pause; a newer query cancels this one.
      if !items.isEmpty || !trimmed.isEmpty { try? await Task.sleep(for: .milliseconds(300)) }
      guard !Task.isCancelled else { return }
      await reload(trimmed)
    }
  }

  private func reload(_ q: String) async {
    page = 0
    hasMore = true
    await loadPage(1, q, replacing: true)
  }

  private func loadPage(_ next: Int, _ q: String, replacing: Bool = false) async {
    guard let browser = store.repo.browser, !loading || replacing else { return }
    loading = true
    defer { loading = false }
    do {
      let rows = try await browser.browse(kind, query: q, sort: sort, page: next)
      guard !Task.isCancelled else { return }
      items = replacing ? rows : items + rows
      page = next
      hasMore = rows.count == SupabaseEventsSource.browsePageSize
      failed = false
    } catch {
      guard !Task.isCancelled else { return }
      if replacing { items = [] }
      hasMore = false
      failed = true
    }
  }
}

/// What a Browse item was involved in: the events held in a place, or a
/// person's bouts (each opening the fight, with its event).
struct BrowseItemView: View {
  @Environment(EventsStore.self) private var store
  let route: BrowseItemRoute
  @State private var events: [MmaEvent] = []
  @State private var fights: [FightOnCard] = []
  @State private var page = 0
  @State private var hasMore = true
  @State private var loading = false
  @State private var failed = false

  var body: some View {
    List {
      if events.isEmpty && fights.isEmpty {
        if loading || page == 0 {
          ProgressView().frame(maxWidth: .infinity).listRowBackground(Color.clear)
        } else if failed {
          LoadStateView(kind: .failed(L("searchTabSearchFailed")) { await loadPage(1) })
            .listRowBackground(Color.clear)
        } else {
          ContentUnavailableView(L("browseEmpty"), systemImage: route.kind.symbol).listRowBackground(Color.clear)
        }
      }
      if route.kind.listsEvents {
        EventSections(events: events)
      } else if !fights.isEmpty {
        Section(L("browseFightsSection")) {
          ForEach(Array(fights.enumerated()), id: \.offset) { _, f in
            NavigationLink(value: FightRoute(event: f.event, fight: f.fight)) {
              VStack(alignment: .leading, spacing: 4) {
                FightRow(fight: f.fight)
                Text("\(f.event.eventName) · \(Fmt.eventDate(f.event.dateUtc))")
                  .font(.caption).foregroundStyle(.secondary).padding(.leading, 44)
              }
            }
            .fightMenu(f.fight, event: f.event)
            .listRowBackground(f.fight.isTitleFight ? Color.yellow.opacity(0.12) : nil)
          }
        }
      }
      if hasMore && page > 0 && !(events.isEmpty && fights.isEmpty) {
        ProgressView().frame(maxWidth: .infinity).task { await loadPage(page + 1) }
      }
    }
    .fightMenuDestinations()
    .navigationTitle(route.item.name)
    .toolbarTitleDisplayMode(.inline)
    .toolbar {
      if route.kind == .fighters, let link = route.item.link {
        ToolbarItem(placement: .primaryAction) {
          NavigationLink(value: FighterRoute(name: route.item.name, url: link)) {
            Label(L("browseProfile"), systemImage: "person.crop.circle")
          }
        }
      }
    }
    .refreshable { await loadPage(1) }
    .task { if page == 0 { await loadPage(1) } }
  }

  private func loadPage(_ next: Int) async {
    guard let browser = store.repo.browser, !loading else { return }
    loading = true
    defer { loading = false }
    do {
      let count: Int
      if route.kind.listsEvents {
        let rows = try await browser.browseEvents(route.kind, id: route.item.id, page: next)
        events = next == 1 ? rows : events + rows
        count = rows.count
      } else {
        let rows = try await browser.browseFights(route.kind, id: route.item.id, page: next)
        fights = next == 1 ? rows : fights + rows
        count = rows.count
      }
      page = next
      hasMore = count == SupabaseEventsSource.browsePageSize
      failed = false
    } catch {
      page = max(page, 1)
      hasMore = false
      failed = true
    }
  }
}
