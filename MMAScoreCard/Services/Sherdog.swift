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
    static func loadEvents() async throws -> [Event] {
        guard let url = URL(string: "https://www.sherdog.com/organizations/Ultimate-Fighting-Championship-UFC-2") else {
            throw SheredogError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw SheredogError.invalidResponse
        }
        
        guard let htmlString = String(data: data, encoding: .utf8) else {
            throw SheredogError.invalidData
        }
        
        let document = try SwiftSoup.parse(htmlString)
        let tables = try document.select("table.new_table")
        print("\(tables.size()) tables")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd yyyy"
        
        var events: [Event] = []
        for table in tables.array() {
            let rows = try table.select("tr")
            print("\(rows.size()) rows")
            var rowNumber = -1
            for row in rows.array() {
                rowNumber += 1
                if rowNumber == 0 {
                    continue
                }
                
                var name: String? = nil
                var location: String? = nil
                var date: Date? = nil
                
                let columns = try row.select("td")
                print("\(columns.size()) columns")
                var columnNumber = -1
                for column in columns.array() {
                    columnNumber += 1
                    let columnText = try column.text()
                    switch columnNumber {
                    case 0: {
                        print("columnText \(columnText)")
                        date = dateFormatter.date(from: columnText)
                    }()
                    case 1: name = columnText
                    case 2: location = columnText
                    default: throw SheredogError.invalidColumn
                    }
                }
                
                guard name != nil && location != nil && date != nil else {
                    throw SheredogError.invalidEvent
                }
                
                events.append(Event(name: name!, location: location!, date: date!))
            }
        }
        print("\(events.count) events created")
        return events
    }
}
