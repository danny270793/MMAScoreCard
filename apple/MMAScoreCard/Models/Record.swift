//
//  Record.swift
//  MMAScoreCard
//
//  Created by dvaca on 26/3/25.
//

import Foundation

class Record: Identifiable {
    var status: FighterStatus
    var figther: String
    var event: String
    var date: Date
    var method: String
    var referee: String?
    var round: String
    var time: String
    
    init(status: FighterStatus, figther: String, event: String, date: Date, method: String, referee: String?, round: String, time: String) {
        self.status = status
        self.figther = figther
        self.event = event
        self.date = date
        self.method = method
        self.referee = referee
        self.round = round
        self.time = time
    }
}
