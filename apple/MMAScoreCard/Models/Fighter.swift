//
//  Fighter.swift
//  MMAScoreCard
//
//  Created by dvaca on 23/3/25.
//

import Foundation
import SwiftData

@Model
class Fighter {
    @Attribute(.unique) var id: UUID
    var name: String
    var image: String
    var link: String
    
    init(id: UUID = UUID(), name: String, image: String, link: String) {
        self.id = id
        self.name = name
        self.image = image
        self.link = link
    }
}

