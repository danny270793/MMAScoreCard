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

class Division: Identifiable {
    var id: String { name }
    var weight: Int
    var name: String
    
    static let weights: [String: Int] = [
        "Strawweight": 115,
        "Flyweight": 125,
        "Bantamweight": 135,
        "Featherweight": 145,
        "Lightweight": 155,
        "Welterweight": 170,
        "Middleweight": 185,
        "Light Heavyweight": 205,
        "Heavyweight": 225
    ]
    
    init(name: String) {
        self.name = name
        self.weight = Division.weights[name] ?? 0
    }
    
    init(weight: Int, name: String) {
        self.weight = weight
        self.name = name
    }
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
    var division: Division
    var titleFight: Bool
    var fightStatus: FightStatus
    
    init(position: Int, figther1: Fighter, figther1Status: FighterStatus, figther2: Fighter, figther2Status: FighterStatus, result: String, round: String, time: String, referee: String, division: String, fightStatus: FightStatus, titleFight: Bool) {
        self.position = position
        self.figther1 = figther1
        self.figther1Status = figther1Status
        self.figther2 = figther2
        self.figther2Status = figther2Status
        self.result = result
        self.round = round
        self.time = time
        self.referee = referee
        self.division = Division(name: division)
        self.fightStatus = fightStatus
        self.titleFight = titleFight
    }
}
