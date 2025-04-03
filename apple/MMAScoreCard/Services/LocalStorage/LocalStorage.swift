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
    
    static func getCachedAt(fileName: String) throws -> Date? {
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
        
        let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
        if let creationDate = attributes[.creationDate] as? Date {
            return creationDate
        }
        return nil
    }
    
    static func getTimeCached(fileName: String) throws -> String? {
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
        
        let minutesCached: Int = try getMinutesCached(fileURL: fileURL)
        return minutesToText(minutes: minutesCached)
    }
    
    static func getMinutesCached(fileURL: URL) throws -> Int {
        let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
        if let creationDate = attributes[.creationDate] as? Date {
            let calendar = Calendar.current
            let now = Date.now
            let components = calendar.dateComponents([.minute], from: creationDate, to: now)
            if let minutes = components.minute {
                return minutes
            }
            return 0
        }
        return 0
    }
    
    static func minutesToText(minutes: Int) -> String {
        let days = minutes / (24 * 60)
        let hours = (minutes % (24 * 60)) / 60
        let remainingMinutes = minutes % 60
        
        return String(format: "%02dd %02dh%02dm", days, hours, remainingMinutes)
    }
    
    static func loadFromFile(fileName: String, cacheInvalidationMinutes: Int = 0) throws -> String? {
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
        
        let minutesCached = try getMinutesCached(fileURL: fileURL)
        let minutesCachedInText = minutesToText(minutes: minutesCached)
        
        if cacheInvalidationMinutes == 0 {
            print("cached permanently for \(minutesCachedInText) \(fileName)")
        } else {
            if cacheInvalidationMinutes == -1 {
                let cacheInvalidationTime = UserDefaults.standard.integer(forKey: "cacheInvalidationTime")
                let defaultCacheInvalidationTime = 360
                let actualCacheInvalidationTime = cacheInvalidationTime != 0 ? cacheInvalidationTime : defaultCacheInvalidationTime
                
                print("cached for \(minutesCachedInText), max allowed from settings \(minutesToText(minutes: actualCacheInvalidationTime)) \(fileName)")
                if minutesCached > actualCacheInvalidationTime {
                    return nil
                }
            } else {
                print("cached for \(minutesCachedInText), max allowed specific \(minutesToText(minutes: cacheInvalidationMinutes)) \(fileName)")
                if minutesCached > cacheInvalidationMinutes {
                    return nil
                }
            }
        }
        
        
        
        return try String(contentsOf: fileURL, encoding: .utf8)
    }
}
