import ScoreCardCore
import SwiftUI

/// Where a fight's long-press menu navigates to, shared by the rows of one
/// screen. Destinations can't be attached to rows inside a list, so the
/// screen attaches them once (`fightMenuDestinations()`) and rows set these.
@Observable final class FightMenuRouter {
  var fighter: FighterRoute?
  var event: MmaEvent?
  /// An event known only by its link (from a fighter's history).
  var eventRoute: EventRoute?
}

extension View {
  /// Lets this screen's fight rows open a fighter or an event from their long-press menu.
  func fightMenuDestinations() -> some View { modifier(FightMenuDestinations()) }

  /// Long press on a bout: preview it, with "See <fighter>" for each side and,
  /// unless already on it, "See event".
  func fightMenu(_ fight: EventFight, event: MmaEvent?) -> some View {
    modifier(BoutMenu(fight: fight, event: event))
  }

  /// Long press on a fighter's history row: preview it, with "See fighter"
  /// (the opponent) and "See event".
  func historyMenu(_ record: FighterFightRecord, isTitleFight: Bool) -> some View {
    modifier(HistoryMenu(record: record, isTitleFight: isTitleFight))
  }
}

private struct FightMenuDestinations: ViewModifier {
  @State private var router = FightMenuRouter()

  func body(content: Content) -> some View {
    @Bindable var router = router
    content
      .environment(router)
      .navigationDestination(item: $router.fighter) { FighterDetailView(route: $0) }
      .navigationDestination(item: $router.event) { EventDetailView(event: $0) }
      .navigationDestination(item: $router.eventRoute) { EventLoaderView(route: $0) }
  }
}

private struct BoutMenu: ViewModifier {
  @Environment(FightMenuRouter.self) private var router: FightMenuRouter?
  let fight: EventFight
  let event: MmaEvent?

  func body(content: Content) -> some View {
    content.contextMenu {
      fighterButton(fight.fighterA, fight.fighterAUrl)
      fighterButton(fight.fighterB, fight.fighterBUrl)
      if let event {
        Button(L("historySeeEvent"), systemImage: "calendar") { router?.event = event }
      }
    } preview: {
      VStack(alignment: .leading, spacing: 6) {
        FightRow(fight: fight)
        if let event {
          Text("\(event.eventName) · \(Fmt.eventDate(event.dateUtc))").font(.caption).foregroundStyle(.secondary)
            .padding(.leading, 44)
        }
      }
      .padding(16)
      .frame(width: 360, alignment: .leading)
      .background(fight.isTitleFight ? Color.yellow.opacity(0.12) : Color(.systemBackground))
    }
  }

  @ViewBuilder private func fighterButton(_ name: String, _ url: String?) -> some View {
    if let url {
      Button(L("fightSeeFighterNamed", name), systemImage: "person.fill") {
        router?.fighter = FighterRoute(name: name, url: url)
      }
    }
  }
}

private struct HistoryMenu: ViewModifier {
  @Environment(FightMenuRouter.self) private var router: FightMenuRouter?
  let record: FighterFightRecord
  let isTitleFight: Bool

  func body(content: Content) -> some View {
    content.contextMenu {
      if let url = record.opponentUrl {
        Button(L("historySeeFighter"), systemImage: "person.fill") {
          router?.fighter = FighterRoute(name: record.opponentName, url: url)
        }
      }
      if let url = record.eventUrl {
        Button(L("historySeeEvent"), systemImage: "calendar") {
          router?.eventRoute = EventRoute(url: url, name: record.eventName, dateText: record.eventDateText)
        }
      }
    } preview: {
      HistoryRow(record: record, isTitleFight: isTitleFight)
        .padding(16)
        .frame(width: 360)
        .background(isTitleFight ? Color.yellow.opacity(0.12) : Color(.systemBackground))
    }
  }
}
