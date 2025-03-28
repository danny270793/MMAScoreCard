//
//  LocalStorage.swift
//  MMAScoreCard
//
//  Created by dvaca on 23/3/25.
//

import Foundation

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
    
    static func loadFromFile(fileName: String, cacheInvalidationMinutes: Int = -1) throws -> String? {
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
        
        if cacheInvalidationMinutes == 0 {
            print("cached permanently \(fileName)")
        } else {
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            if let creationDate = attributes[.creationDate] as? Date {
                let calendar = Calendar.current
                let now = Date.now
                let components = calendar.dateComponents([.minute], from: creationDate, to: now)
                    
                if let minutes = components.minute {
                    if cacheInvalidationMinutes == -1 {
                        let defaultCacheInvalidationMinutes = UserDefaults.standard.integer(forKey: "cacheInvalidationTime")
                        print("cached \(minutes) minutes \(fileName) max allowed from settings \(defaultCacheInvalidationMinutes)")
                        if minutes > cacheInvalidationMinutes {
                            return nil
                        }
                    } else {
                        print("cached \(minutes) minutes \(fileName) max allowed specific \(cacheInvalidationMinutes)")
                        if minutes > cacheInvalidationMinutes {
                            return nil
                        }
                    }
                }
            }
        }
        
        
        
        return try String(contentsOf: fileURL, encoding: .utf8)
    }
}
