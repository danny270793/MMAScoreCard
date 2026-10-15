import ScoreCardCore
import SwiftUI

/// One bout: event, division, result (method, round, time, octagon time,
/// referee) and both fighters, each opening their profile.
struct FightDetailView: View {
  let event: MmaEvent
  let fight: EventFight

  var body: some View {
    List {
      Section(L("fightDetailFightersLabel")) {
        fighter(fight.fighterA, fight.fighterAUrl, fight.outcomeA)
        fighter(fight.fighterB, fight.fighterBUrl, fight.outcomeB)
      }

      Section(L("fightDetailResultLabel")) {
        if !fight.isCompleted {
          Label(L("fightDetailNotYetContested"), systemImage: "clock").foregroundStyle(.secondary)
        } else {
          if let method = fight.method {
            HStack(spacing: 14) {
              MethodIcon(method: method, size: 44)
              VStack(alignment: .leading) {
                Text(method).font(.headline)
                Text(L("fightDetailMethodOfVictoryLabel")).font(.caption).foregroundStyle(.secondary)
              }
            }
          }
          if fight.round != nil || fight.time != nil {
            HStack {
              if let time = fight.time {
                StatTile(symbol: "timer", color: .purple, value: time, label: L("fightDetailTimeLabel"))
              }
              if fight.round != nil && fight.time != nil { Divider() }
              if let round = fight.round {
                StatTile(symbol: "number", color: .blue, value: round, label: L("fightDetailRoundLabel"))
              }
            }
            .padding(.vertical, 6)
          }
          if let total = fight.octagonTime {
            LabeledContent {
              Text(Fmt.octagonTime(total))
            } label: {
              Label(L("fightDetailOctagonTimeLabel"), systemImage: "hourglass")
            }
          }
          if let referee = fight.referee {
            LabeledContent {
              Text(referee)
            } label: {
              Label(L("fightDetailRefereeLabel"), systemImage: "person")
            }
          }
        }
      }

      Section(L("fightDetailEventInfoLabel")) {
        info(L("fightDetailEventLabel"), "ticket", event.eventName)
        info(L("eventDetailLocationLabel"), "mappin.and.ellipse", event.location)
        info(L("eventDetailDateLabel"), "calendar", Fmt.eventDate(event.dateUtc))
        if !fight.weightClass.isEmpty { info(L("fightDetailDivisionLabel"), "scalemass", fight.weightClass) }
      }
    }
    .navigationTitle("\(fight.fighterA) vs. \(fight.fighterB)")
    .toolbarTitleDisplayMode(.inline)
  }

  @ViewBuilder
  private func fighter(_ name: String, _ url: String?, _ outcome: FightOutcome) -> some View {
    let row = HStack {
      Text(name).font(.headline)
      Spacer()
      OutcomeTag(outcome: outcome)
    }
    if let url {
      NavigationLink(
        value: FighterRoute(
          name: name, url: url, currentEventUrl: event.url, currentEventIsTitleFight: fight.isTitleFight)
      ) { row }
    } else {
      row
    }
  }

  private func info(_ label: String, _ symbol: String, _ value: String) -> some View {
    LabeledContent {
      Text(value).multilineTextAlignment(.trailing)
    } label: {
      Label(label, systemImage: symbol)
    }
  }
}
