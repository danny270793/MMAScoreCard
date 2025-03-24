//
//  Fight.swift
//  MMAScoreCard
//
//  Created by dvaca on 23/3/25.
//

import Foundation
import SwiftData

enum FightStatus: String {
    case done = "DONE"
    case pending = "PENDING"
}

@Model
class Fight {
    @Attribute(.unique) var id: UUID
    var position: Int
    var figther1: Fighter
    var figther2: Fighter
    var result: String
    var round: String
    var time: String
    var referee: String
    var division: String
    var fightStatus: String
    
    init(id: UUID = UUID(), position: Int, figther1: Fighter, figther2: Fighter, result: String, round: String, time: String, referee: String, division: String, fightStatus: FightStatus) {
        self.position = position
        self.id = id
        self.figther1 = figther1
        self.figther2 = figther2
        self.result = result
        self.round = round
        self.time = time
        self.referee = referee
        self.division = division
        self.fightStatus = fightStatus.rawValue
    }
}
