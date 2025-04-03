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
        SimpleEntry(date: .now, eventName: "UFC 300", koTko: 3, submission: 5, decission: 8)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: .now, eventName: "UFC 308", koTko: 3, submission: 5, decission: 8)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: .now, eventName: "UFC 309", koTko: 3, submission: 5, decission: 8)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let eventName: String
    let koTko: Int
    let submission: Int
    let decission: Int
}

struct LastEventStatsWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        let fights = Double(entry.koTko + entry.decission + entry.submission)
        let kos = Double(entry.koTko)/fights
        let submissions = Double(entry.submission)/fights
        let decissions = Double(entry.decission)/fights
        let text = 0.3
        let space = 0.2
        let theRest = 1 - text - space
        
        GeometryReader { geometry in
            VStack {
                
                Text(entry.eventName)
                HStack{
                    Text("KOs")
                        .frame(width: geometry.size.width * text)
                    ZStack {
                        Rectangle()
                            .fill(Color.red)
                            .cornerRadius(10)
                            .frame(width: geometry.size.width * space + geometry.size.width * theRest * kos)
                        Text(String(entry.koTko))
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                HStack {
                    Text("Sub")
                        .frame(width: geometry.size.width * text)
                    ZStack {
                        Rectangle()
                            .fill(Color.blue)
                            .cornerRadius(10)
                            .frame(width: geometry.size.width * space + geometry.size.width * theRest * submissions)
                        Text(String(entry.submission))
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                HStack {
                    Text("Dec")
                        .frame(width: geometry.size.width * text)
                    ZStack {
                        Rectangle()
                            .fill(Color.green)
                            .cornerRadius(10)
                            .frame(width: geometry.size.width * space + geometry.size.width * theRest * decissions)
                        Text(String(entry.decission))
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
            }
            
            //        ZStack {
            //            Circle()
            //                .stroke(style: StrokeStyle(
            //                    lineWidth: 20, lineCap: .round
            //                ))
            //
            ////            Circle()
            ////                .trim(from: kos + submissions, to: kos + submissions + decissions)
            ////                .stroke(.green, style: StrokeStyle(
            ////                    lineWidth: 20, lineCap: .round
            ////                ))
            ////                .rotationEffect(.degrees(-90))
            //            Circle()
            //                .trim(from: kos, to: kos + submissions)
            //                .stroke(.blue, style: StrokeStyle(
            //                    lineWidth: 20, lineCap: .round
            //                ))
            //                .rotationEffect(.degrees(-90))
            //            Circle()
            //                .trim(from: 0, to: kos)
            //                .stroke(.red, style: StrokeStyle(
            //                    lineWidth: 20, lineCap: .round
            //                ))
            //                .rotationEffect(.degrees(-90))
            //            VStack {
            //                Text(entry.eventName)
            //            }
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
    }
}

#Preview(as: .systemSmall) {
    LastEventStatsWidget()
} timeline: {
    SimpleEntry(date: .now, eventName: "UFC 306", koTko: 5, submission: 8, decission: 2)
}
