//
//  ContentView.swift
//  MMAScoreCardVisionOS
//
//  Created by dvaca on 3/4/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    var body: some View {
        EventsList()
    }
}

#Preview(windowStyle: .automatic) {
    NavigationStack {
        ContentView()
    }
}
