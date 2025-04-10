//
//  Errors.swift
//  MMAScoreCard
//
//  Created by dvaca on 28/3/25.
//

import Foundation

enum LocalStorageErrors: Error, LocalizedError {
    case noHasAccess
    case encodingError
    
    var errorDescription: String? {
        switch self {
        case .noHasAccess:
            return NSLocalizedString("Do not have access", comment: "No has access")
        case .encodingError:
            return NSLocalizedString("Error encoding texr", comment: "Encoding error")
        }
    }
}

