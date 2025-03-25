//
//  LocalStorage.swift
//  MMAScoreCard
//
//  Created by dvaca on 23/3/25.
//

import Foundation

enum LocalStorageErrors: Error {
    case noHasAccess
    case encodingError
}

class LocalStorage {
    static func saveToFile(content: String, fileName: String) throws {
        guard let data = fileName.data(using: .utf8) else {
            throw LocalStorageErrors.encodingError
        }
        let fileNameBase64 = data.base64EncodedString()
        
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw LocalStorageErrors.noHasAccess
        }
        
        let fileURL = documentDirectory.appendingPathComponent(fileNameBase64)
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
    }
    
    static func loadFromFile(fileName: String) throws -> String? {
        guard let data = fileName.data(using: .utf8) else {
            throw LocalStorageErrors.encodingError
        }
        let fileNameBase64 = data.base64EncodedString()
        
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw LocalStorageErrors.noHasAccess
        }
        
        let fileURL = documentDirectory.appendingPathComponent(fileNameBase64)
        if !fileManager.fileExists(atPath: fileURL.path) {
            return nil
        }
        
        return try String(contentsOf: fileURL, encoding: .utf8)
    }
}
