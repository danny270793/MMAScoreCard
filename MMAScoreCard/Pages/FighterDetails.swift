//
//  FighterDetails.swift
//  MMAScoreCard
//
//  Created by dvaca on 24/3/25.
//

import SwiftUI
import SwiftData

struct FighterDetails: View {
    let figther: Fighter
    
    var body: some View {
        List {
            Section(header: Text("Fighter")) {
                LabeledContent("Name", value: figther.name)
            }
        }
        .navigationTitle(figther.name)
    }
}

#Preview {
    NavigationView {
        FighterDetails(figther: Fighter(name: "Alex Pereira", image: "", link: ""))
            .modelContainer(for: [
                Event.self,
                Fighter.self,
                Fight.self
            ])
    }
}
