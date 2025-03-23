//
//  FightsList.swift
//  MMAScoreCard
//
//  Created by dvaca on 23/3/25.
//

import SwiftUI
import SwiftData

struct FigthsList: View {
    let event: Event
    
    var body: some View {
        List {
            Section(header: Text("Details")) {
                LabeledContent("Name", value: event.name)
                if event.fight != nil {
                    LabeledContent("Fight", value: event.fight!)
                }
                LabeledContent("Location", value: event.location)
                LabeledContent("Date", value: event.date.ISO8601Format().split(separator: "T")[0])
            }
        }
        .navigationTitle(event.name)
    }
}

#Preview {
    NavigationStack {
        FigthsList(event: Event(name: "UFC 313", fight: "Alex Pereira vs. Ankalaev", location: "Los Angeles", date: Date()))
    }
}
