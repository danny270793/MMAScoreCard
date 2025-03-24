//
//  Sherdog.swift
//  MMAScoreCard
//
//  Created by dvaca on 23/3/25.
//

import SwiftUI
import SwiftSoup

enum SheredogError: Error {
    case invalidURL(url: String)
    case invalidResponse
    case invalidData
    case invalidEvent
    case invalidFigther
    case invalidColumn(position: Int, value: String)
    
    var description: String {
        switch self {
        case .invalidURL(let url):
            return "Invalid URL: \(url)"
        case .invalidResponse:
            return "Invalid response with invalid status code"
        case .invalidData:
            return "Invalid data received"
        case .invalidEvent:
            return "Invalid event"
        case .invalidFigther:
            return "Invalid fighter"
        case .invalidColumn(let position, let value):
            return "Invalid column at position \(position) with value \(value)"
        }
    }
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
            return htmlString!
        }
        guard let urlParsed = URL(string: url) else {
            throw SheredogError.invalidURL(url: url)
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
    
    static func loadFights(event: Event) async throws -> [Fight] {
        print("looking for event \(event.url)")
        let html = try await requestIfNotExists(url: event.url)
        
        let document = try SwiftSoup.parse(html)
        let fightCard = try document.select("div.fight_card")
        let division = try fightCard.select("span.weight_class").text()
        
        let leftSide = try fightCard.select("div.left_side")
        let figther1StatusText = (try leftSide.select("span.final_result").text()).lowercased().trim()
        print("figther1StatusText \(figther1StatusText)")
        let figther1Status = figther1StatusText == "loss" ? FighterStatus.loss : figther1StatusText == "win" ? FighterStatus.win : FighterStatus.pending
        print("figther1Status \(figther1Status)")
        let figther1Name = try leftSide.select("h3").text()
        
        let rightSide = try fightCard.select("div.right_side")
        let figther2StatusText = (try rightSide.select("span.final_result").text()).lowercased().trim()
        print("figther2StatusText \(figther2StatusText)")
        let figther2Status = figther2StatusText == "loss" ? FighterStatus.loss : figther2StatusText == "win" ? FighterStatus.win : FighterStatus.pending
        print("figther2Status \(figther2Status)")
        let figther2Name = try rightSide.select("h3").text()
        
        var position: Int = 1000
        var result: String = ""
        var round: String = ""
        var time: String = ""
        var referee: String = ""
        var fightStatus = FightStatus.pending
        
        let resumeTables = try document.select("table.fight_card_resume")
        print("\(resumeTables.count) resumeTables found")
        for table in resumeTables.array() {
            let rows = try table.select("tr")
            print("\(rows.count) rows found")
            for row in rows.array() {
                let columns = try row.select("td")
                print("\(columns.count) columns found")
                var columnNumber = -1
                for column in columns.array() {
                    fightStatus = FightStatus.done
                    columnNumber += 1
                    let columnText = try column.text()
                    print("columnNumber=\(columnNumber) columnText=\(columnText)")
                    switch columnNumber {
                    case 0: {
                        let parts = columnText.split(separator: " ")
                        let positionText = String(parts[parts.count - 1])
                        position = Int(positionText) ?? -2
                    }()
                    case 1: result = columnText.replacingOccurrences(of: "Method ", with: "")
                    case 2: referee = columnText
                    case 3: round = columnText.replacingOccurrences(of: "Round ", with: "")
                    case 4: time = columnText.replacingOccurrences(of: "Time ", with: "")
                    default: throw SheredogError.invalidColumn(position: columnNumber, value: columnText)
                    }
                }
            }
        }
        
        var fights: [Fight] = []
        let fight = Fight(position: position, figther1: Fighter(name: figther1Name, image: "", link: ""), figther1Status: figther1Status, figther2: Fighter(name: figther2Name, image: "", link: ""), figther2Status: figther2Status, result: result, round: round, time: time, referee: referee, division: division, fightStatus: fightStatus)
        fights.append(fight)
        
        let tables = try document.select("table.new_table")
        for table in tables.array() {
            let rows = try table.select("tr")
            var rowNumber = -1
            for row in rows.array() {
                rowNumber += 1
                if rowNumber == 0 {
                    continue
                }
                
                var position: Int? = nil
                var result: String? = nil
                var round: String? = nil
                var time: String? = nil
                var referee: String? = nil
                var division: String? = nil
                var fighter1Name: String? = nil
                var fighter1Status: FighterStatus = FighterStatus.pending
                var fighter2Name: String? = nil
                var fighter2Status: FighterStatus = FighterStatus.pending
                var fightStatus: FightStatus? = nil
                
                let columns = try row.select("td")
                var columnNumber = -1
                for column in columns.array() {
                    columnNumber += 1
                    let columnText = try column.text()
                    if columns.count == 5 {
                        switch columnNumber {
                        case 0: position = Int(columnText)
                        case 1: {
                            let components = columnText.split(separator: " ")
                            fighter1Name = components.dropLast().joined(separator: " ")
                        }()
                        case 2: division = columnText
                        case 3: {
                            let components = columnText.split(separator: " ")
                            fighter2Name = components.dropLast().joined(separator: " ")
                        }()
                        case 4: {
                            result = ""
                            referee = ""
                            round = ""
                            time = ""
                            fighter1Status = FighterStatus.pending
                            fighter2Status = FighterStatus.pending
                            fightStatus = FightStatus.pending
                        }()
                        default: throw SheredogError.invalidColumn(position: columnNumber, value: columnText)
                        }
                    } else {
                        switch columnNumber {
                        case 0: position = Int(columnText)
                        case 1: {
                            fighter1Status = columnText.hasSuffix("win") ? FighterStatus.win : FighterStatus.loss
                            
                            let components = columnText.split(separator: " ")
                            fighter1Name = components.dropLast().joined(separator: " ")
                        }()
                        case 2: division = columnText
                        case 3: {
                            fighter2Status = columnText.hasSuffix("win") ? FighterStatus.win : FighterStatus.loss
                            
                            let components = columnText.split(separator: " ")
                            fighter2Name = components.dropLast().joined(separator: " ")
                        }()
                        case 4: {
                            let parts = columnText.split(separator: ")")
                            
                            result = String(parts[0]).trim() + ")"
                            referee = String(parts[1]).trim()
                            fightStatus = FightStatus.done
                        }()
                        case 5: round = columnText
                        case 6: time = columnText
                        default: throw SheredogError.invalidColumn(position: columnNumber, value: columnText)
                        }
                    }
                }
                
                guard position != nil && result != nil && round != nil && time != nil && referee != nil && fightStatus != nil else {
                    throw SheredogError.invalidFigther
                }
                
                let figther1: Fighter = Fighter(name: fighter1Name!, image: "", link: "")
                let figther2: Fighter = Fighter(name: fighter2Name!, image: "", link: "")
                let fight = Fight(position: position!, figther1: figther1, figther1Status: fighter1Status, figther2: figther2, figther2Status: fighter2Status, result: result!, round: round!, time: time!, referee: referee!, division: division!, fightStatus: fightStatus!)
                fights.append(fight)
            }
        }
        return fights
    }
    
    static func loadEvents() async throws -> [Event] {
        let baseUrl: String = "https://www.sherdog.com"
        let html = try await requestIfNotExists(url: "\(baseUrl)/organizations/Ultimate-Fighting-Championship-UFC-2")
        
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
                var url: String? = nil
                
                let onclick = try row.attr("onclick")
                if !onclick.isEmpty {
                    let parts = onclick.split(separator: "=")
                    let onClickUrl = String(parts[1])
                    
                    let startIndex = onClickUrl.index(onClickUrl.startIndex, offsetBy: 2)
                    let endIndex = onClickUrl.index(onClickUrl.endIndex, offsetBy: -2)
                    url = "\(baseUrl)/\(String(onClickUrl[startIndex..<endIndex]))"
                }
                
                let columns = try row.select("td")
                var columnNumber = -1
                for column in columns.array() {
                    columnNumber += 1
                    let columnText = try column.text()
                    switch columnNumber {
                    case 0: date = dateFormatter.date(from: columnText)
                    case 1: nameAndFight = columnText
                    case 2: location = columnText
                    default: throw SheredogError.invalidColumn(position: columnNumber, value: columnText)
                    }
                }
                
                guard nameAndFight != nil && location != nil && date != nil && url != nil else {
                    throw SheredogError.invalidEvent
                }
                
                let parts = nameAndFight!.split(separator: "-")
                let name: String = String(parts[0]).trim()
                let fight: String = String(parts[1]).trim()
                let event = Event(name: name, fight: fight.lowercased().contains("vs") ? fight : nil, location: location!, date: date!, url: url!)
                events.append(event)
            }
        }
        return events
    }
}
