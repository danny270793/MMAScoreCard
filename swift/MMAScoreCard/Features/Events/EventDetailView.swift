import ScoreCardCore
import SwiftUI

/// Where and when, KO / submission / decision totals, and the fight card,
/// main event first. Search filters the card by fighter or division.
struct EventDetailView: View {
  @Environment(EventsStore.self) private var store
  let event: MmaEvent
  @State private var fights: Loadable<[EventFight]> = .loading
  @State private var query = ""

  var body: some View {
    List {
      Section {
        LabeledContent {
          Text(event.location).multilineTextAlignment(.trailing)
        } label: {
          Label(L("eventDetailLocationLabel"), systemImage: "mappin.and.ellipse")
        }
        LabeledContent {
          Text(Fmt.eventDate(event.dateUtc))
        } label: {
          Label(L("eventDetailDateLabel"), systemImage: "calendar")
        }
      } header: {
        if let matchup = event.matchup { Text(matchup).font(.title3.bold()).foregroundStyle(.primary).textCase(nil) }
      }

      if let all = fights.value {
        let stats = CardStatistics(all)
        if !stats.isEmpty && query.isEmpty {
          Section(L("eventDetailStatisticsLabel")) {
            HStack {
              StatTile(symbol: FightMethodKind.koTko.symbol, color: .red, value: "\(stats.koTko)", label: L("statKoTko"))
              Divider()
              StatTile(
                symbol: FightMethodKind.submission.symbol, color: .purple, value: "\(stats.submissions)",
                label: L("statSubmissions"))
              Divider()
              StatTile(
                symbol: FightMethodKind.other.symbol, color: .blue, value: "\(stats.decisions)",
                label: L("statDecisions"))
            }
            .padding(.vertical, 6)
          }
        }
      }

      Section(L("eventDetailFightCardLabel")) {
        switch fights {
        case .loading:
          ProgressView().frame(maxWidth: .infinity)
        case .failed:
          Text(L("eventDetailLoadError")).foregroundStyle(.secondary)
        case .loaded(let all) where all.isEmpty:
          Text(L("eventDetailEmpty")).foregroundStyle(.secondary)
        case .loaded(let all):
          let matches = filterFights(all, query)
          if matches.isEmpty { Text(L("searchNoResults")).foregroundStyle(.secondary) }
          ForEach(Array(matches.enumerated()), id: \.offset) { _, fight in
            NavigationLink(value: FightRoute(event: event, fight: fight)) { FightRow(fight: fight) }
              .listRowBackground(fight.isTitleFight ? Color.yellow.opacity(0.12) : nil)
          }
        }
      }
    }
    .navigationTitle(event.eventName)
    .toolbarTitleDisplayMode(.inline)
    .searchable(text: $query, prompt: L("searchFightsHint"))
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        if let url = URL(string: event.url) {
          ShareLink(item: url) { Label(L("share"), systemImage: "square.and.arrow.up") }
        }
      }
    }
    .refreshable { await load(refresh: true) }
    .task { if fights.value == nil { await load(refresh: false) } }
  }

  private func load(refresh: Bool) async {
    fights = await fights.reloaded { try await store.repo.eventFights(event.url, refresh: refresh) }
  }
}

/// "A vs B", division, round and time, and how it ended.
struct FightRow: View {
  let fight: EventFight

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      MethodIcon(method: fight.isCompleted ? fight.method : nil)
      VStack(alignment: .leading, spacing: 4) {
        if fight.isTitleFight { Tag(text: L("eventDetailTitleFightLabel"), color: .orange) }
        HStack(spacing: 6) {
          fighter(fight.fighterA)
          Text("vs").font(.caption).foregroundStyle(.secondary)
          fighter(fight.fighterB)
        }
        let timing = fight.round.flatMap { r in fight.time.map { "R\(r) · \($0)" } }
        Text([fight.weightClass, timing].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: "  ·  "))
          .font(.caption).foregroundStyle(.secondary)
        if let method = fight.method { Text(method).font(.caption) }
      }
    }
    .padding(.vertical, 2)
  }

  private func fighter(_ name: String) -> some View {
    Text(name).font(.subheadline.bold()).lineLimit(1)
  }
}
