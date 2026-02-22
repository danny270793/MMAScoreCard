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
    var recordWLD: String?
    var fights: [Record]
    
    init(name: String, nationality: String, age: String, height: String, weight: String, recordWLD: String? = nil, fights: [Record]) {
        self.name = name
        self.nationality = nationality
        self.age = age
        self.height = height
        self.weight = weight
        self.recordWLD = recordWLD
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

