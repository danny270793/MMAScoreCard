//
//  MMAScoreCardApp.swift
//  MMAScoreCard
//
//  Created by dvaca on 23/3/25.
//

import SwiftUI

@main
struct MMAScoreCardApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.modelContainer(for: [
            Event.self
        ])
    }
}
