//
//  Fight.swift
//  MMAScoreCard
//
//  Created by dvaca on 23/3/25.
//

import Foundation

enum FightStatus: String {
    case done = "DONE"
    case pending = "PENDING"
}

enum FighterStatus: String {
    case win = "WIN"
    case loss = "LOSS"
    case nc = "NC"
    case draw = "DRAW"
    case pending = "PENDING"
}

class Fight: Identifiable {
    var position: Int
    var figther1: Fighter
    var figther2: Fighter
    var figther1Status: FighterStatus
    var figther2Status: FighterStatus
    var result: String
    var round: String
    var time: String
    var referee: String
    var division: String
    var fightStatus: FightStatus
    
    init(position: Int, figther1: Fighter, figther1Status: FighterStatus, figther2: Fighter, figther2Status: FighterStatus, result: String, round: String, time: String, referee: String, division: String, fightStatus: FightStatus) {
        self.position = position
        self.figther1 = figther1
        self.figther1Status = figther1Status
        self.figther2 = figther2
        self.figther2Status = figther2Status
        self.result = result
        self.round = round
        self.time = time
        self.referee = referee
        self.division = division
        self.fightStatus = fightStatus
    }
}
