import ScoreCardCore
import SwiftUI

/// Floating glass tab bar: the Flutter Upcoming / Past pill becomes two tabs,
/// the search button becomes the system search tab, and Settings moves out
/// of the app bar into its own tab.
struct MainTabView: View {
  @Environment(EventsStore.self) private var store
  @SceneStorage("tab") private var tab = 0

  var body: some View {
    TabView(selection: $tab) {
      Tab(L("tabUpcoming"), systemImage: "calendar", value: 0) {
        NavigationStack { UpcomingEventsView().eventDestinations() }
      }
      Tab(L("tabPast"), systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90", value: 1) {
        NavigationStack { PastEventsView().eventDestinations() }
      }
      Tab(L("settings"), systemImage: "gearshape", value: 2) {
        NavigationStack { SettingsView() }
      }
      Tab(value: 3, role: .search) {
        NavigationStack { SearchView().eventDestinations() }
      }
    }
    .tabBarMinimizeBehavior(.onScrollDown)
    .task { await store.loadUpcoming() }
    .task { await store.loadPast() }
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
  }
}
