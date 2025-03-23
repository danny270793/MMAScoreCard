//
//  ContentView.swift
//  MMAScoreCard
//
//  Created by dvaca on 23/3/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query var events: [Event]
    
    var body: some View {
        List(events) { event in
            Text(event.name)
        }.onAppear {
            
        }
    }
}

#Preview {
    ContentView()
}
