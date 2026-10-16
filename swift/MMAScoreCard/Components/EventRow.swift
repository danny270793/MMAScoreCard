import ScoreCardCore
import SwiftUI

/// Calendar-style day, event name, location and the headline matchup.
struct EventRow: View {
  let event: MmaEvent

  var body: some View {
    HStack(spacing: 14) {
      VStack(spacing: 0) {
        Text(Fmt.date(event.dateUtc, .dateTime.month(.abbreviated)).uppercased())
          .font(.caption2.weight(.semibold))
          .foregroundStyle(event.isUpcoming ? Color.red : Color.secondary)
        Text(Fmt.date(event.dateUtc, .dateTime.day()))
          .font(.title2.weight(.semibold)).monospacedDigit()
      }
      .frame(width: 44)

      VStack(alignment: .leading, spacing: 3) {
        HStack(alignment: .firstTextBaseline) {
          Text(event.eventName).font(.headline).lineLimit(1)
          Spacer(minLength: 4)
          if event.isUpcoming {
            let days = event.daysUntil(.now)
            Text(days <= 0 ? L("todayLabel") : L("inDaysLabel", days))
              .font(.caption.weight(.semibold)).foregroundStyle(.orange)
          }
        }
        if let matchup = event.matchup {
          Text(matchup).font(.subheadline).lineLimit(1)
        }
        Label(event.location, systemImage: "mappin.and.ellipse")
          .labelStyle(.titleAndIcon)
          .font(.caption).foregroundStyle(.secondary).lineLimit(1)
      }
    }
    .padding(.vertical, 2)
  }
}

/// Month sections of event rows, each pushing the event's fight card.
struct EventSections: View {
  let events: [MmaEvent]

  var body: some View {
    ForEach(groupEventsByMonth(events)) { group in
      Section(Fmt.month(group.month)) {
        ForEach(group.events) { event in
          NavigationLink(value: event) { EventRow(event: event) }
        }
      }
    }
  }
}
