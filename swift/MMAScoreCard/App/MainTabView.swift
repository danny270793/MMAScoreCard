import ScoreCardCore
import SwiftUI

/// Floating glass tab bar: the Flutter Upcoming / Past pill becomes two tabs,
/// Browse (cities, countries, fighters, locations, referees; needs Supabase),
/// the search button becomes the system search tab, and Settings moves out
/// of the app bar into its own tab.
struct MainTabView: View {
  @Environment(EventsStore.self) private var store
  @SceneStorage("tab") private var tab = 0
  @State private var chrome = TabChrome()
  @State private var searchPath = NavigationPath()

  /// Opening the search tab from an event, a fighter or a Browse list scopes
  /// it to that screen; from anywhere else it searches everything.
  private var selection: Binding<Int> {
    Binding(
      get: { tab },
      set: { new in
        if new == 3 && tab != 3 && chrome.beginSearch(from: tab) { searchPath = NavigationPath() }
        tab = new
      })
  }

  var body: some View {
    TabView(selection: selection) {
      Tab(L("tabUpcoming"), systemImage: "calendar", value: 0) {
        NavigationStack { UpcomingEventsView().eventDestinations() }.environment(\.tabID, 0)
      }
      Tab(L("tabPast"), systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90", value: 1) {
        NavigationStack { PastEventsView().eventDestinations() }.environment(\.tabID, 1)
      }
      if store.repo.readsFromBackend {
        Tab(L("tabBrowse"), systemImage: "square.grid.2x2", value: 4) {
          NavigationStack { BrowseView().eventDestinations() }.environment(\.tabID, 4)
        }
      }
      Tab(L("settings"), systemImage: "gearshape", value: 2) {
        NavigationStack { SettingsView() }.environment(\.tabID, 2)
      }
      Tab(value: 3, role: .search) {
        NavigationStack(path: $searchPath) { SearchView().eventDestinations() }.environment(\.tabID, 3)
      }
      // A single bout has nothing to search: its screen hides the search tab,
      // unless it was opened from it.
      .hidden(chrome.hidesSearch && tab != 3)
    }
    .environment(chrome)
    .tabBarMinimizeBehavior(.onScrollDown)
    .task { await store.loadUpcoming() }
    .task { await store.loadPast() }
  }
}

/// Tab bar state that pushed screens can change.
@Observable final class TabChrome {
  /// Screens on display that hide the search tab. A count, not a flag: when
  /// one such screen pushes another, the new one can appear before the old
  /// one disappears.
  private(set) var searchHiders = 0
  var hidesSearch: Bool { searchHiders > 0 }

  func hideSearch() { searchHiders += 1 }
  func showSearch() { searchHiders = max(0, searchHiders - 1) }

  /// What the search tab searches; nil = everything.
  private(set) var scope: SearchScope?
  /// Scopes of the screens on display, latest last, with their tab.
  @ObservationIgnored private var scopes: [(id: UUID, tab: Int, scope: SearchScope)] = []

  func setScope(_ scope: SearchScope?, id: UUID, tab: Int) {
    removeScope(id)
    if let scope { scopes.append((id, tab, scope)) }
  }

  func removeScope(_ id: UUID) { scopes.removeAll { $0.id == id } }

  /// Scopes the search tab to the top screen of `tab`. True when the scope
  /// changed (so the search tab starts over).
  func beginSearch(from tab: Int) -> Bool {
    let next = scopes.last { $0.tab == tab }?.scope
    defer { scope = next }
    return next?.key != scope?.key
  }
}

/// What the search tab searches when opened from a screen.
enum SearchScope: Hashable {
  /// The fights on an event's card.
  case event(MmaEvent, [EventFight])
  /// A fighter's bouts, by opponent.
  case fighter(FighterRoute, [FighterFightRecord])
  /// A Browse list, by name.
  case browse(BrowseKind)

  var key: String {
    switch self {
    case .event(let e, _): "event:\(e.url)"
    case .fighter(let f, _): "fighter:\(f.url)"
    case .browse(let k): "browse:\(k.rawValue)"
    }
  }
}

extension EnvironmentValues {
  /// The tab a screen is in.
  @Entry var tabID = 0
}

extension View {
  /// Hides the search tab while this screen shows (nothing to search).
  func hidesSearchTab() -> some View { modifier(HidesSearchTab()) }

  /// The bottom search button searches `scope` while this screen shows.
  func searchScope(_ scope: SearchScope?) -> some View { modifier(ScopesSearch(scope: scope)) }
}

private struct HidesSearchTab: ViewModifier {
  @Environment(TabChrome.self) private var chrome

  func body(content: Content) -> some View {
    content
      .onAppear { chrome.hideSearch() }
      .onDisappear { chrome.showSearch() }
  }
}

private struct ScopesSearch: ViewModifier {
  @Environment(TabChrome.self) private var chrome
  @Environment(\.tabID) private var tab
  @State private var id = UUID()
  @State private var visible = false
  let scope: SearchScope?

  func body(content: Content) -> some View {
    content
      .onAppear {
        visible = true
        chrome.setScope(scope, id: id, tab: tab)
      }
      .onDisappear {
        visible = false
        chrome.removeScope(id)
      }
      // The card or history loaded after the screen appeared.
      .onChange(of: scope) { if visible { chrome.setScope(scope, id: id, tab: tab) } }
  }
}

/// Pushes an event's card, one bout, or a fighter's profile.
struct FightRoute: Hashable {
  let event: MmaEvent
  let fight: EventFight
}

struct FighterRoute: Hashable {
  let name: String
  let url: String
  /// The bout this profile was opened from, to highlight it in the history.
  var currentEventUrl: String?
  var currentEventIsTitleFight = false
}

extension View {
  func eventDestinations() -> some View {
    navigationDestination(for: MmaEvent.self) { EventDetailView(event: $0) }
      .navigationDestination(for: FightRoute.self) { FightDetailView(event: $0.event, fight: $0.fight) }
      .navigationDestination(for: FighterRoute.self) { FighterDetailView(route: $0) }
      .navigationDestination(for: BrowseItemRoute.self) { BrowseItemView(route: $0) }
  }
}
