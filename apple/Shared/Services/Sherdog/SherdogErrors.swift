//
//  Errors.swift
//  MMAScoreCard
//
//  Created by dvaca on 28/3/25.
//

import Foundation

enum SheredogErrors: Error, LocalizedError {
    case invalidEvent
    case invalidFigther
    case invalidColumn(position: Int, value: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidEvent:
            return NSLocalizedString("Invalid event", comment: "Invalid event")
        case .invalidFigther:
            return NSLocalizedString("Invalid fighter", comment: "Invalid figther")
        case .invalidColumn(let position, let value):
            return NSLocalizedString("Invalid column at position \(position) with value \(value)", comment: "Invalid column")
        }
    }
}
