//
//  LastEventStatsWidget.swift
//  LastEventStatsWidget
//
//  Created by dvaca on 2/4/25.
//

import WidgetKit
import SwiftUI

struct LastEventStatsWidget: Widget {
    let kind: String = "LastEventStatsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LastEventStatsProvider()) { entry in
            if #available(iOS 17.0, *) {
                LastEventStatsWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                LastEventStatsWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Last event stats")
        .description("Show the percentage ok KO/TKO, Submissions and Decissions on last event")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
