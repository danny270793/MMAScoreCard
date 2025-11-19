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
            do {
                let stats = try await Sheredog.getLastEventStats()
                let entry = Entry(date: date, stats: stats.data)
                completion(entry)
            } catch {
                // If fetching fails, return nil stats to show loading state
                print("Widget error fetching stats: \(error.localizedDescription)")
                let entry = Entry(date: date, stats: nil)
                completion(entry)
            }
        }
    }
    
    func createTimeline(date: Date, completion: @escaping (Timeline<Entry>) -> ()) {
        createTimelineEntry(date: date) { entry in
            // Refresh widget every hour to check for new events
            let refreshDate = Calendar.current.date(byAdding: .hour, value: 1, to: date) ?? date
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
        }
    }
}
