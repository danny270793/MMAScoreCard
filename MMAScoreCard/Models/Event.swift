//
//  Event.swift
//  MMAScoreCard
//
//  Created by dvaca on 23/3/25.
//

import Foundation
import SwiftData

@Model
class Event {
    @Attribute(.unique) var id: UUID
    var name: String
    var fight: String?
    var location: String
    var date: Date
    
    init(id: UUID = UUID(), name: String, fight: String?, location: String, date: Date) {
        self.id = id
        self.name = name
        self.fight = fight
        self.location = location
        self.date = date
    }
}
