//
//  Fighter.swift
//  MMAScoreCard
//
//  Created by dvaca on 23/3/25.
//

import Foundation

class FighterRecord: Identifiable {
    var name: String
    var nationality: String
    var age: String
    var height: String
    var weight: String
    var wins: Int
    var losses: Int
    var draws: Int
    var noContests: Int
    var fights: [Record]
    
    init(name: String, nationality: String, age: String, height: String, weight: String, wins: Int = 0, losses: Int = 0, draws: Int = 0, noContests: Int = 0, fights: [Record] = []) {
        self.name = name
        self.nationality = nationality
        self.age = age
        self.height = height
        self.weight = weight
        self.wins = wins
        self.losses = losses
        self.draws = draws
        self.noContests = noContests
        self.fights = fights
    }
}

class Fighter: Identifiable {
    var name: String
    var image: URL
    var link: URL
    
    init(name: String, image: URL, link: URL) {
        self.name = name
        self.image = image
        self.link = link
    }
}

