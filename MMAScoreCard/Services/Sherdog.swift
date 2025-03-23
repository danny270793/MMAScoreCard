//
//  Sherdog.swift
//  MMAScoreCard
//
//  Created by dvaca on 23/3/25.
//

import SwiftUI
import SwiftSoup

enum SheredogError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    case invalidEvent
    case invalidColumn
}

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


class Sheredog {
    static func requestIfNotExists(url: String) async throws -> String {
        let htmlString: String? = try LocalStorage.loadFromFile(fileName: url)
        if htmlString != nil {
            print("already exists, so load it")
            return htmlString!
        }
        print("do not exists, so request it")
        guard let urlParsed = URL(string: url) else {
            throw SheredogError.invalidURL
        }
        
        let (data, response) = try await session.data(from: urlParsed)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw SheredogError.invalidResponse
        }
        
        guard let htmlString = String(data: data, encoding: .utf8) else {
            throw SheredogError.invalidData
        }
        
        try LocalStorage.saveToFile(content: htmlString, fileName: url)
        return htmlString
    }
    
    static func loadEvents() async throws -> [Event] {
        let html = try await requestIfNotExists(url: "https://www.sherdog.com/organizations/Ultimate-Fighting-Championship-UFC-2")
        
        let document = try SwiftSoup.parse(html)
        let tables = try document.select("table.new_table")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd yyyy"
        
        var events: [Event] = []
        for table in tables.array() {
            let rows = try table.select("tr")
            var rowNumber = -1
            for row in rows.array() {
                rowNumber += 1
                if rowNumber == 0 {
                    continue
                }
                
                var nameAndFight: String? = nil
                var location: String? = nil
                var date: Date? = nil
                
                let columns = try row.select("td")
                var columnNumber = -1
                for column in columns.array() {
                    columnNumber += 1
                    let columnText = try column.text()
                    switch columnNumber {
                    case 0: date = dateFormatter.date(from: columnText)
                    case 1: nameAndFight = columnText
                    case 2: location = columnText
                    default: throw SheredogError.invalidColumn
                    }
                }
                
                guard nameAndFight != nil && location != nil && date != nil else {
                    throw SheredogError.invalidEvent
                }
                
                let parts = nameAndFight!.split(separator: "-")
                let name: String = String(parts[0]).trim()
                let fight: String = String(parts[1]).trim()
                let event = Event(name: name, fight: fight.lowercased().contains("vs") ? fight : nil, location: location!, date: date!)
                events.append(event)
            }
        }
        return events
    }
}
