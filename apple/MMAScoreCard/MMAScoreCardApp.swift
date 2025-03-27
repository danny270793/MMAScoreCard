//
//  MMAScoreCardApp.swift
//  MMAScoreCard
//
//  Created by dvaca on 23/3/25.
//

import SwiftUI
import LocalAuthentication

@main
struct MMAScoreCardApp: App {
    @State var authenticated = false
    @State var authenticating = false
    @State var useFaceId = UserDefaults.standard.bool(forKey: "useFaceId")
    
    var body: some Scene {
        WindowGroup {
            FaceIdUnlock(main: EventsList())
        }
    }
}
