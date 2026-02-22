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
        
        
        
        recordCacheAccess(url: fileName)
        return try String(contentsOf: fileURL, encoding: .utf8)
    }
    
    private static let cacheAccessCountsKey = "LocalStorage.cacheAccessCounts"
    
    static func recordCacheAccess(url: String) {
        var counts = UserDefaults.standard.dictionary(forKey: cacheAccessCountsKey) as? [String: Int] ?? [:]
        counts[url, default: 0] += 1
        UserDefaults.standard.set(counts, forKey: cacheAccessCountsKey)
    }
    
    static func getCacheAccessCount(url: String) -> Int {
        let counts = UserDefaults.standard.dictionary(forKey: cacheAccessCountsKey) as? [String: Int] ?? [:]
        return counts[url] ?? 0
    }
    
    struct CachedURLInfo {
        let url: String
        let cachedAt: Date
        let accessCount: Int
    }
    
    static func listAllCachedURLs() throws -> [CachedURLInfo] {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw LocalStorageErrors.noHasAccess
        }
        
        let counts = UserDefaults.standard.dictionary(forKey: cacheAccessCountsKey) as? [String: Int] ?? [:]
        var result: [CachedURLInfo] = []
        
        let contents = try fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles)
        
        for fileURL in contents {
            let base64Name = fileURL.lastPathComponent
            guard let data = Data(base64Encoded: base64Name),
                  let url = String(data: data, encoding: .utf8),
                  url.hasPrefix("http") else { continue }
            
            let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
            let cachedAt = attributes[.creationDate] as? Date ?? Date()
            let accessCount = counts[url] ?? 0
            result.append(CachedURLInfo(url: url, cachedAt: cachedAt, accessCount: accessCount))
        }
        
        return result.sorted { $0.cachedAt > $1.cachedAt }
    }
}
