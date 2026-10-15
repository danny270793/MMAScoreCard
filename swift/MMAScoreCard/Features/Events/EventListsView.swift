import ScoreCardCore
import SwiftUI

struct UpcomingEventsView: View {
  @Environment(EventsStore.self) private var store

  var body: some View {
    Group {
      switch store.upcoming {
      case .loading:
        LoadStateView(kind: .loading)
      case .failed:
        LoadStateView(kind: .failed(L("upcomingLoadError")) { await store.loadUpcoming(refresh: true) })
      case .loaded(let events) where events.isEmpty:
        LoadStateView(kind: .empty(L("noUpcomingEvents"), systemImage: "calendar"))
      case .loaded(let events):
        List { EventSections(events: events) }
      }
    }
    .refreshable { await store.loadUpcoming(refresh: true) }
    .navigationTitle(L("eventsPageTitle"))
    .toolbarTitleDisplayMode(.inlineLarge)
  }
}

/// Every cached past page, newest first; scrolling to the end loads the next
/// page (100 events each), like the Flutter infinite scroll.
struct PastEventsView: View {
  @Environment(EventsStore.self) private var store

  var body: some View {
    Group {
      if store.past.isEmpty && (store.pastLoading || !store.pastFailed && store.pastHasMore) {
        LoadStateView(kind: .loading)
      } else if store.past.isEmpty && store.pastFailed {
        LoadStateView(kind: .failed(L("pastLoadError")) { await store.loadNextPastPage() })
      } else if store.past.isEmpty {
        LoadStateView(kind: .empty(L("noPastEvents"), systemImage: "clock"))
      } else {
        List {
          EventSections(events: store.past)
          if store.pastHasMore {
            LoadMoreRow()
          }
        }
      }
    }
    .refreshable { await store.refreshPast() }
    .navigationTitle(L("tabPast"))
    .toolbarTitleDisplayMode(.inlineLarge)
  }
}

/// Last list row: loads the next past page as soon as it scrolls into view,
/// or offers a retry if that failed.
struct LoadMoreRow: View {
  @Environment(EventsStore.self) private var store

  var body: some View {
    HStack {
      Spacer()
      if store.pastFailed && !store.pastLoading {
        Button(L("retryButton")) { Task { await store.loadNextPastPage() } }
      } else {
        ProgressView()
      }
      Spacer()
    }
    .listRowBackground(Color.clear)
    .task(id: store.past.count) {
      if !store.pastFailed { await store.loadNextPastPage() }
    }
  }
}
