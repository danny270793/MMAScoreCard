//
//  Http.swift
//  MMAScoreCard
//
//  Created by dvaca on 28/3/25.
//

import SwiftUI

class SSLDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

let config = URLSessionConfiguration.default
let session = URLSession(configuration: config, delegate: SSLDelegate(), delegateQueue: nil)

class Http {
    static func getImage(url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw HttpErrors.invalidResponse
        }
        
        return data
    }
    
    static func get(url: String) async throws -> String {
        print("GET \(url)")
        guard let urlParsed = URL(string: url) else {
            throw HttpErrors.invalidURL(url: url)
        }
        
        let (data, response) = try await session.data(from: urlParsed)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw HttpErrors.invalidResponse
        }
        
        guard let htmlString = String(data: data, encoding: .utf8) else {
            throw HttpErrors.invalidData
        }
        
        return htmlString
    }
    
    static func getIfNotExists(url: URL, forceRefresh: Bool = false) async throws -> String {
        return try await getIfNotExists(url: url.absoluteString, forceRefresh: forceRefresh)
    }
    
    static func getIfNotExists(url: String, forceRefresh: Bool = false, cacheInvalidationMinutes: Int = -1) async throws -> String {
        if forceRefresh {
            let freshHtmlString = try await Http.get(url: url)
            try LocalStorage.saveToFile(content: freshHtmlString, fileName: url)
            return freshHtmlString
        }
        
        let htmlString: String? = try LocalStorage.loadFromFile(fileName: url, cacheInvalidationMinutes: cacheInvalidationMinutes)
        guard let html = htmlString else {
            let freshHtmlString = try await Http.get(url: url)
            
            try LocalStorage.saveToFile(content: freshHtmlString, fileName: url)
            return freshHtmlString
        }
        
        return html
    }
}
