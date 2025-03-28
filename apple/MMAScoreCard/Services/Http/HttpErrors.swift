//
//  Errors.swift
//  MMAScoreCard
//
//  Created by dvaca on 28/3/25.
//

import Foundation

enum HttpErrors: Error, LocalizedError {
    case invalidURL(url: String)
    case invalidResponse
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL(let url):
            return NSLocalizedString("Invalid URL: \(url)", comment: "Invalid url")
        case .invalidResponse:
            return NSLocalizedString("Invalid response with invalid status code", comment: "Invalid response")
        case .invalidData:
            return NSLocalizedString("Invalid data received", comment: "Invalid data")
        }
    }
}
