//
//  LastEventStatsWidgetEntryView.swift
//  MMAScoreCard
//
//  Created by dvaca on 3/4/25.
//

import WidgetKit
import SwiftUI

struct LastEventStatsWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: LastEventStatsProvider.Entry
    
    func map(x: Double, inMin: Double, inMax: Double, outMin: Double, outMax: Double) -> Double {
      return (x - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
    }

    
    var body: some View {
        if entry.stats == nil {
            VStack(spacing: 8) {
                Image(systemName: "figure.boxing")
                    .font(.system(size: 40))
                    .foregroundStyle(.secondary)
                Text("Loading Event Stats...")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ProgressView()
            }
        } else {
            let fights = Double(entry.stats!.kos + entry.stats!.decisions + entry.stats!.submissions)
            let kos = Double(entry.stats!.kos)/fights
            let submissions = Double(entry.stats!.submissions)/fights
            let decissions = Double(entry.stats!.decisions)/fights
            GeometryReader { geometry in
                if family == .systemLarge || family == .systemExtraLarge {
                    VStack {
                        Text(entry.stats!.name)
                            .font(.title)
                        HStack {
                            ZStack {
                                Rectangle()
                                    .fill(Color.red)
                                    .cornerRadius(10)
                                    .frame(width: geometry.size.width/3.1, height: 20)
                                Text("KO")
                                    .foregroundColor(.white)
                            }
                            ZStack {
                                Rectangle()
                                    .fill(Color.blue)
                                    .cornerRadius(10)
                                    .frame(width: geometry.size.width/3.1, height: 20)
                                Text("Submission")
                                    .foregroundColor(.white)
                            }
                            ZStack {
                                Rectangle()
                                    .fill(Color.green)
                                    .cornerRadius(10)
                                    .frame(width: geometry.size.width/3.1, height: 20)
                                Text("Decision")
                                    .foregroundColor(.white)
                            }
                        }
                        HStack {
                            Text(String(entry.stats!.kos))
                                .frame(width: geometry.size.width/3.1, height: 20)
                            Text(String(entry.stats!.submissions))
                                .frame(width: geometry.size.width/3.1, height: 20)
                            Text(String(entry.stats!.decisions))
                                .frame(width: geometry.size.width/3.1, height: 20)
                        }
                        Text("")
                        Text("")
//                        ZStack {
//                            Circle()
//                                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round))
//                            Circle()
//                                .trim(from: 0, to: kos)
//                                .stroke(.red, style: StrokeStyle(lineWidth: 30))
//                                .rotationEffect(.degrees(-90))
//                            Circle()
//                                .trim(from: kos, to: kos + submissions)
//                                .stroke(.blue, style: StrokeStyle(lineWidth: 30))
//                                .rotationEffect(.degrees(-90))
//                            Circle()
//                                .trim(from: kos + submissions, to: kos + submissions + decissions)
//                                .stroke(.green, style: StrokeStyle(lineWidth: 30))
//                                .rotationEffect(.degrees(-90))
//                        }
                        let maxNumber = [kos, submissions, decissions].max()!
                        ZStack {
                            Circle()
                                .trim(from: 0, to: map(x: kos, inMin: 0, inMax: maxNumber, outMin: 0, outMax: 0.96))
                                .stroke(.red, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                                .frame(width: 100)
                                .rotationEffect(.degrees(-90))
                            Circle()
                                .trim(from: 0, to: map(x: submissions, inMin: 0, inMax: maxNumber, outMin: 0, outMax: 0.96))
                                .stroke(.blue, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                                .frame(width: 140)
                                .rotationEffect(.degrees(-90))
                            Circle()
                                .trim(from: 0, to: map(x: decissions, inMin: 0, inMax: maxNumber, outMin: 0, outMax: 0.96))
                                .stroke(.green, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                                .frame(width: 180)
                                .rotationEffect(.degrees(-90))
                        }
                    }
                } else {
                    let text = family == .systemSmall ? 0.3 : 0.2
                    let space = 0.2
                    let theRest = 1 - text - space
                    
                    
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
}

#Preview(as: .systemSmall) {
    LastEventStatsWidget()
} timeline: {
    LastEventStatsEntry(date: .now, stats: EventStats(name: "UFC Fight Night 255", kos: 5, submissions: 8, decisions: 2))
    LastEventStatsEntry(date: .now, stats: nil)
}

#Preview(as: .systemMedium) {
    LastEventStatsWidget()
} timeline: {
    LastEventStatsEntry(date: .now, stats: EventStats(name: "UFC Fight Night 255", kos: 5, submissions: 8, decisions: 2))
    LastEventStatsEntry(date: .now, stats: nil)
}

#Preview(as: .systemLarge) {
    LastEventStatsWidget()
} timeline: {
    LastEventStatsEntry(date: .now, stats: EventStats(name: "UFC Fight Night 255", kos: 5, submissions: 8, decisions: 2))
    LastEventStatsEntry(date: .now, stats: nil)
}

#Preview(as: .systemExtraLarge) {
    LastEventStatsWidget()
} timeline: {
    LastEventStatsEntry(date: .now, stats: EventStats(name: "UFC Fight Night 255", kos: 5, submissions: 8, decisions: 2))
    LastEventStatsEntry(date: .now, stats: nil)
}
