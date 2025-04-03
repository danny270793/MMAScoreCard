//
//  LastEventStatsWidgetEntryView.swift
//  MMAScoreCard
//
//  Created by dvaca on 3/4/25.
//

import SwiftUI

struct LastEventStatsWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: LastEventStatsProvider.Entry
    
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
