//
//  QuickActionzManager.swift
//  MMAScoreCard
//
//  Created by dvaca on 31/3/25.
//

import SwiftUI

enum Shortcut: String, Hashable {
    case showLastEvent
    case none
}

class ShortcutsManager: ObservableObject {
    static let instance = ShortcutsManager()
    
    @Published var shortcut: Shortcut = Shortcut.none

    func handle(_ item: UIApplicationShortcutItem) {
        if item.type == "showLastEvent" {
            shortcut = .showLastEvent
        }
    }
}
