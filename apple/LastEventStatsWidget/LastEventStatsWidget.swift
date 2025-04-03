//
//  LastEventStatsWidget.swift
//  LastEventStatsWidget
//
//  Created by dvaca on 2/4/25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: .now, stats: EventStats(name: "UFC 300", kos: 5, submissions: 8, decisions: 2))
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: .now, stats: EventStats(name: "UFC 308", kos: 5, submissions: 8, decisions: 2))
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        createTimeline(date: Date(), completion: completion)
    }
    
    func createTimelineEntry(date: Date, completion: @escaping (Entry) -> ()) {
        Task {
            let stats = try await Sheredog.getLastEventStats()
            let entry = Entry(date: date, stats: stats.data)
            completion(entry)
        }
    }
    
    func createTimeline(date: Date, completion: @escaping (Timeline<Entry>) -> ()) {
        createTimelineEntry(date: date) { entry in
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let stats: EventStats?
}

struct LastEventStatsWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry
    
    var body: some View {
        if entry.stats == nil {
            ZStack {
                ProgressView()
                Text("Loading...")
            }
        } else {
            let fights = Double(entry.stats!.kos + entry.stats!.decisions + entry.stats!.submissions)
            let kos = Double(entry.stats!.kos)/fights
            let submissions = Double(entry.stats!.submissions)/fights
            let decissions = Double(entry.stats!.decisions)/fights
            let text = family == .systemSmall ? 0.3 : 0.2
            let space = 0.2
            let theRest = 1 - text - space
            
            GeometryReader { geometry in
                let labelWidth = geometry.size.width * text
                let barMinWidht = geometry.size.width * space
                VStack {
                    if family == .systemSmall {
                        Text(entry.stats!.name)
                            .font(.system(size: 13))
                    } else {
                        Text(entry.stats!.name)
                    }
                    HStack{
                        Text("KOs")
                            .frame(width: labelWidth)
                        ZStack {
                            Rectangle()
                                .fill(Color.red)
                                .cornerRadius(10)
                                .frame(width: barMinWidht + geometry.size.width * theRest * kos)
                            Text(String(entry.stats!.kos))
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    HStack {
                        Text("Sub")
                            .frame(width: labelWidth)
                        ZStack {
                            Rectangle()
                                .fill(Color.blue)
                                .cornerRadius(10)
                                .frame(width: barMinWidht + geometry.size.width * theRest * submissions)
                            Text(String(entry.stats!.submissions))
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    HStack {
                        Text("Dec")
                            .frame(width: labelWidth)
                        ZStack {
                            Rectangle()
                                .fill(Color.green)
                                .cornerRadius(10)
                                .frame(width: barMinWidht + geometry.size.width * theRest * decissions)
                            Text(String(entry.stats!.decisions))
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                }
            }
        }
    }
}

struct LastEventStatsWidget: Widget {
    let kind: String = "LastEventStatsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
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
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
}

#Preview(as: .systemSmall) {
    LastEventStatsWidget()
} timeline: {
    SimpleEntry(date: .now, stats: EventStats(name: "UFC Fight Night 255", kos: 5, submissions: 8, decisions: 2))
    SimpleEntry(date: .now, stats: nil)
}
