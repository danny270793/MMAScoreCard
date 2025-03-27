//
//  Event.swift
//  MMAScoreCard
//
//  Created by dvaca on 23/3/25.
//

import Foundation

class Event: Identifiable {
    var name: String
    var fight: String?
    var location: String
    var date: Date
    var url: String
    
    init(name: String, fight: String?, location: String, date: Date, url: String) {
        self.name = name
        self.fight = fight
        self.location = location
        self.date = date
        self.url = url
    }
}
