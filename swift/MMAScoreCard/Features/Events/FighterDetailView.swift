import ScoreCardCore
import ScoreCardData
import SwiftUI

/// Bio, record with KO / submission / decision breakdowns, streaks and the
/// fight history by year. The search button searches the history by opponent.
struct FighterDetailView: View {
  @Environment(EventsStore.self) private var store
  let route: FighterRoute
  @State private var profile: Loadable<FighterProfile> = .loading

  var body: some View {
    Group {
      switch profile {
      case .loading:
        LoadStateView(kind: .loading)
      case .failed:
        LoadStateView(kind: .failed(L("fighterDetailLoadError")) { await load(refresh: true) })
      case .loaded(let p):
        content(p)
      }
    }
    .navigationTitle(route.name)
    .toolbarTitleDisplayMode(.inline)
    .searchScope(.fighter(route, profile.value?.fightHistory ?? []))
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        if let url = URL(string: route.url) {
          ShareLink(item: url) { Label(L("share"), systemImage: "square.and.arrow.up") }
        }
      }
    }
    .refreshable { await load(refresh: true) }
    .task { if profile.value == nil { await load(refresh: false) } }
  }

  private func content(_ p: FighterProfile) -> some View {
    List {
      overview(p)
      history(p)
    }
    .fightMenuDestinations()
  }

  /// Record, bio and streaks.
  @ViewBuilder
  private func overview(_ p: FighterProfile) -> some View {
    // Record headline over wins and losses side by side, then the bio.
    Section {
      HStack(alignment: .top, spacing: 16) {
        RecordColumn(title: L("fighterDetailWinsLabel"), count: p.wins, color: .green, breakdown: p.winsBreakdown)
        Divider()
        RecordColumn(
          title: L("fighterDetailLossesLabel"), count: p.losses, color: .red, breakdown: p.lossesBreakdown)
      }
      .padding(.vertical, 6)
    } header: {
      VStack(spacing: 2) {
        Text(p.recordSummary).font(.system(size: 40, weight: .bold, design: .rounded)).monospacedDigit()
          .foregroundColor(Color(.label))
        Text(L("fighterDetailRecordLabel")).font(.caption)
      }
      .textCase(nil)
      .frame(maxWidth: .infinity)
      .padding(.bottom, 8)
    }

    Section { bio(p) }

    if let streak = p.currentStreak {
      Section(L("fighterDetailStreaksLabel")) {
        info(
          L("fighterDetailCurrentStreakLabel"), "flame", Fmt.streak(streak.outcome, streak.count) ?? L("streakNone"),
          color: streak.outcome == .win || streak.outcome == .loss ? streak.outcome.color : nil)
        if p.bestWinStreak > 0 {
          info(L("fighterDetailBestStreakLabel"), "chart.line.uptrend.xyaxis", L("streakWins", p.bestWinStreak),
               color: .green)
        }
        if p.worstLossStreak > 0 {
          info(L("fighterDetailWorstStreakLabel"), "chart.line.downtrend.xyaxis", L("streakLosses", p.worstLossStreak),
               color: .red)
        }
      }
    }

  }

  @ViewBuilder
  private func bio(_ p: FighterProfile) -> some View {
      info(L("fighterDetailNationalityLabel"), "flag", p.nationality)
      info(L("fighterDetailHometownLabel"), "house", p.hometown)
      info(L("fighterDetailAgeLabel"), "birthday.cake", p.age.map { a in p.birthDate.map { "\(a) (\($0))" } ?? "\(a)" })
      info(L("fighterDetailHeightLabel"), "ruler", p.height)
      info(L("fighterDetailWeightLabel"), "scalemass", p.weight)
      info(L("fighterDetailAssociationLabel"), "shield", p.association)
      info(L("fighterDetailClassLabel"), "dumbbell", p.weightClass)
      if p.totalOctagonTime > 0 {
        info(L("fighterDetailOctagonTimeLabel"), "timer", Fmt.octagonTime(p.totalOctagonTime))
      }
  }

  @ViewBuilder
  private func history(_ p: FighterProfile) -> some View {
    if p.fightHistory.isEmpty {
      Section(L("fighterDetailFightHistoryLabel")) {
        Text(L("fighterDetailEmpty")).foregroundStyle(.secondary)
      }
    }
    ForEach(Array(groupFightsByYear(p.fightHistory).enumerated()), id: \.offset) { i, group in
      Section {
        ForEach(Array(group.fights.enumerated()), id: \.offset) { _, record in
          let isTitle = route.currentEventIsTitleFight && record.eventUrl == route.currentEventUrl
          historyRow(record, isTitle: isTitle)
            .listRowBackground(
              isTitle ? Color.yellow.opacity(0.12) : record.isAmateur ? Color.purple.opacity(0.07) : nil)
        }
      } header: {
        if i == 0 {
          VStack(alignment: .leading, spacing: 6) {
            Text(L("fighterDetailFightHistoryLabel")).font(.headline).foregroundStyle(.primary).textCase(nil)
            Text(group.year)
          }
        } else {
          Text(group.year)
        }
      }
    }
  }

  /// Tap opens the opponent; long press previews the fight with "See fighter"
  /// and "See event".
  @ViewBuilder
  private func historyRow(_ record: FighterFightRecord, isTitle: Bool) -> some View {
    let row = HistoryRow(record: record, isTitleFight: isTitle)
    Group {
      if let url = record.opponentUrl {
        NavigationLink(value: FighterRoute(name: record.opponentName, url: url)) { row }
      } else {
        row
      }
    }
    .historyMenu(record, isTitleFight: isTitle)
  }

  @ViewBuilder
  private func info(_ label: String, _ symbol: String, _ value: String?, color: Color? = nil) -> some View {
    if let value, !value.isEmpty {
      LabeledContent {
        Text(value).multilineTextAlignment(.trailing).foregroundStyle(color ?? .secondary)
      } label: {
        Label(label, systemImage: symbol)
      }
    }
  }

  private func load(refresh: Bool) async {
    profile = await profile.reloaded { try await store.repo.fighterProfile(route.url, refresh: refresh) }
  }
}

/// Wins or losses with their KO/TKO, submission and decision split.
struct RecordColumn: View {
  let title: String
  let count: Int
  let color: Color
  let breakdown: RecordBreakdown

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack(alignment: .firstTextBaseline) {
        Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(color)
        Spacer()
        Text("\(count)").font(.title2.bold()).monospacedDigit()
      }
      meter(L("statKoTko"), .koTko, breakdown.koTko)
      meter(L("statSubmissions"), .submission, breakdown.submissions)
      meter(L("statDecisions"), .other, breakdown.decisions)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private func meter(_ label: String, _ kind: FightMethodKind, _ meter: RecordMeter) -> some View {
    VStack(alignment: .leading, spacing: 3) {
      ViewThatFits {
        HStack {
          Text(label)
          Spacer()
          Text("\(meter.count) (\(meter.percent)%)").bold().monospacedDigit()
        }
        VStack(alignment: .leading) {
          Text(label)
          Text("\(meter.count) (\(meter.percent)%)").bold().monospacedDigit()
        }
      }
      .font(.caption)
      ProgressView(value: Double(meter.percent), total: 100).tint(kind.color)
    }
    .accessibilityElement(children: .combine)
  }
}

/// Opponent, method, event and date, with the result on the trailing side.
struct HistoryRow: View {
  let record: FighterFightRecord
  let isTitleFight: Bool

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      MethodIcon(method: record.method)
      VStack(alignment: .leading, spacing: 2) {
        if isTitleFight || record.isAmateur {
          HStack(spacing: 6) {
            if isTitleFight { Tag(text: L("eventDetailTitleFightLabel"), color: .orange) }
            if record.isAmateur { Tag(text: L("fighterDetailAmateurLabel"), color: .purple, prominent: false) }
          }
          .padding(.bottom, 2)
        }
        Text(record.opponentName).font(.headline)
        if let method = record.method { Text(method).font(.caption.weight(.semibold)) }
        Text(record.eventName).font(.caption).foregroundStyle(.tint).lineLimit(1)
        if let date = record.eventDateText { Text(date).font(.caption).foregroundStyle(.secondary) }
      }
      Spacer(minLength: 4)
      VStack(alignment: .trailing, spacing: 4) {
        OutcomeTag(outcome: record.outcome)
        if let round = record.round, let time = record.time, !round.isEmpty {
          Text("R\(round) · \(time)").font(.caption).foregroundStyle(.secondary).monospacedDigit()
        }
      }
    }
    .padding(.vertical, 2)
  }
}

/// An event reached from a fighter's history: only its link, name and date are known.
struct EventRoute: Hashable {
  let url: String
  let name: String
  let dateText: String?
}

/// Looks the event up in Supabase, then shows its card. Events of other
/// promotions aren't stored, so those say so instead.
struct EventLoaderView: View {
  @Environment(EventsStore.self) private var store
  let route: EventRoute
  @State private var event: Loadable<MmaEvent?> = .loading

  var body: some View {
    switch event {
    case .loading:
      ProgressView().task { await load() }
    case .failed:
      ContentUnavailableView(L("eventNotAvailableTitle"), systemImage: "calendar.badge.exclamationmark")
    case .loaded(let found?):
      EventDetailView(event: found)
    case .loaded(nil):
      ContentUnavailableView(
        L("eventNotAvailableTitle"), systemImage: "calendar.badge.exclamationmark",
        description: Text(L("eventNotAvailableMessage")))
    }
  }

  private func load() async {
    event = await event.reloaded {
      if let found = try await store.repo.event(route.url) { return found }
      // Scraping Sherdog directly: any event page works, built from the history row.
      return store.repo.readsFromBackend ? nil : fallbackEvent()
    }
  }

  /// "UFC 333 - Volkanovski vs. Evloev" and "Oct / 24 / 2026" as an event.
  private func fallbackEvent() -> MmaEvent {
    let parts = route.name.components(separatedBy: " - ")
    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = TimeZone(identifier: "UTC")!
    let date = SherdogParser.historyDate(route.dateText).flatMap {
      cal.date(from: DateComponents(year: $0 / 10_000, month: $0 / 100 % 100, day: $0 % 100))
    }
    return MmaEvent(
      id: route.url.firstMatch(of: /-(\d+)$/).map { String($0.1) } ?? route.url, eventName: parts[0],
      matchup: parts.count > 1 ? parts.dropFirst().joined(separator: " - ") : nil, dateUtc: date ?? .now,
      location: "", url: route.url, isUpcoming: false)
  }
}
