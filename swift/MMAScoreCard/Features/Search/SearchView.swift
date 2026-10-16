import ScoreCardCore
import SwiftUI

/// The system search tab: matches upcoming and every loaded past event by
/// name, matchup or location. Older pages can be pulled in from here.
struct SearchView: View {
  @Environment(EventsStore.self) private var store
  @State private var query = ""

  var body: some View {
    let all = (store.upcoming.value ?? []) + store.past
    let matches = filterEvents(all, query)
    List {
      if query.trimmingCharacters(in: .whitespaces).isEmpty {
        ContentUnavailableView(
          L("tabSearch"), systemImage: "magnifyingglass", description: Text(L("searchEmptyPrompt"))
        )
        .listRowBackground(Color.clear)
      } else {
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
    }
    .navigationTitle(L("tabSearch"))
    .searchable(text: $query, prompt: L("searchHint"))
  }
}
