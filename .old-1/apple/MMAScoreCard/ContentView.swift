//
//  ContentView.swift
//  MMAScoreCard
//
//  Created by dvaca on 31/3/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var shortcutsManager = ShortcutsManager.instance
    
    var body: some View {
        NavigationStack {
            FaceIdUnlock(main: EventsList())
                .navigationDestination(isPresented: .constant(shortcutsManager.shortcut == Shortcut.showLastEvent)) {
                    LastEventView()
                }
        }
        
    }
}
