//
//  Provider.swift
//  MMAScoreCard
//
//  Created by dvaca on 3/4/25.
//

import WidgetKit

struct LastEventStatsProvider: TimelineProvider {
    func placeholder(in context: Context) -> LastEventStatsEntry {
        LastEventStatsEntry(date: .now, stats: EventStats(name: "UFC 300", kos: 5, submissions: 8, decisions: 2))
    }

    func getSnapshot(in context: Context, completion: @escaping (LastEventStatsEntry) -> ()) {
        let entry = LastEventStatsEntry(date: .now, stats: EventStats(name: "UFC 308", kos: 5, submissions: 8, decisions: 2))
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
