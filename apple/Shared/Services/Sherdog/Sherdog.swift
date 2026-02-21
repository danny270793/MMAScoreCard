//
//  Sherdog.swift
//  MMAScoreCard
//
//  Created by dvaca on 23/3/25.
//

import SwiftUI
import SwiftSoup

/// Sherdog-specific implementation of MMADataProviderResponse.
typealias SherdogResponse<T> = MMADataProviderResponse<T>

struct EventStats {
    let name: String
    let mainFight: String
    let kos: Int
    let submissions: Int
    let decisions: Int
}

final class Sherdog: MMADataProvider {
    static let shared = Sherdog()
    
    private let baseUrl: String = "https://www.sherdog.com"
    private var eventsUrl: String { "\(baseUrl)/organizations/Ultimate-Fighting-Championship-UFC-2" }
    
    private init() {}
    
    func loadImage(url: URL) async throws -> Data {
        return try await Http.getImage(url: url)
    }
    
    func loadRecord(fighter: Fighter, forceRefresh: Bool = false) async throws -> SherdogResponse<FighterRecord> {
        let html = try await Http.getIfNotExists(url: fighter.link, forceRefresh: forceRefresh)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM / dd / yyyy"
        
        var records: [Record] = []
        
        let document = try SwiftSoup.parse(html)
        
        var nationality: String? = nil
        var age: String? = nil
        var height: String? = nil
        var weight: String? = nil
        
        let birthplaces = try document.select("span.birthplace")
        for birthplace in birthplaces.array() {
            nationality = try birthplace.text()
        }
        
        let bios = try document.select("div.bio-holder")
        for bio in bios.array() {
            let tables = try bio.select("table")
            for table in tables.array() {
                let rows = try table.select("tr")
                var rowNumber = -1
                for row in rows.array() {
                    rowNumber += 1
                    
                    let columns = try row.select("td")
                    var columnNumber = -1
                    for column in columns.array() {
                        columnNumber += 1
                        let columnText = try column.text()
                        switch columnNumber {
                        case 1: {
                            switch rowNumber {
                            case 0: age = columnText
                            case 1: height = columnText
                            case 2: weight = columnText
                            default:{}()
                            }
                        }()
                        default:{}()
                        }
                    }
                }
            }
        }
        
        
        let tables = try document.select("table.new_table")
        var tableNumber = -1
        for table in tables.array() {
            tableNumber += 1
            if tableNumber != 0 {
                continue
            }
            let rows = try table.select("tr")
            var rowNumber = -1
            for row in rows.array() {
                rowNumber += 1
                if rowNumber == 0 {
                    continue
                }
                
                var fighterStatus: FighterStatus? = nil
                var fighter: String? = nil
                var event: String? = nil
                var date: Date? = nil
                var referee: String? = nil
                var method: String? = nil
                var round: String? = nil
                var time: String? = nil
                
                let columns = try row.select("td")
                var columnNumber = -1
                for column in columns.array() {
                    columnNumber += 1
                    let columnText = try column.text()
                    switch columnNumber {
                    case 0: {
                        let status = columnText.lowercased()
                        fighterStatus = status == "win" ? FighterStatus.win :
                        status == "loss" ? FighterStatus.loss :
                        status == "nc" ? FighterStatus.nc :
                        status == "draw" ? FighterStatus.draw :
                        FighterStatus.pending
                    }()
                    case 1:
                        fighter = columnText
                    case 2: {
                        let range = columnText.range(of: " - ", options: .backwards)!
                        event = String(columnText[..<range.lowerBound])
                        let dateString = String(columnText[range.upperBound...])
                        
                        let dateParts = dateString.split(separator: " ")
                        let year = dateParts[dateParts.count - 1]
                        let day = dateParts[dateParts.count - 3]
                        let month = dateParts[dateParts.count - 5]
                        date = dateFormatter.date(from: "\(month) / \(day) / \(year)")
                    }()
                    case 3: {
                        let parts = columnText.split(separator: ")")
                        
                        method = "\(parts[0]))"
                        if parts.count > 1 {
                            referee = String(parts[1].replacing("VIEW PLAY-BY-PLAY", with: "")).trim()
                        }
                    }()
                    case 4:
                        round = columnText
                    case 5:
                        time = columnText
                    default: throw SherdogErrors.invalidColumn(position: columnNumber, value: columnText)
                    }
                }
                
                guard fighterStatus != nil && fighter != nil && event != nil && date != nil && method != nil && round != nil && time != nil else {
                    throw SherdogErrors.invalidFigther
                }
                
                let record: Record = Record(status: fighterStatus!, figther: fighter!, event: event!, date: date!, method: method!, referee: referee, round: round!, time: time!)
                records.append(record)
            }
        }
        
        guard age != nil && height != nil && weight != nil && nationality != nil else {
            throw SherdogErrors.invalidFigther
        }
        
        let cachedAt: Date? = try LocalStorage.getCachedAt(fileName: fighter.link.absoluteString)
        let timeCached: String? = try LocalStorage.getTimeCached(fileName: fighter.link.absoluteString)
        let data: FighterRecord = FighterRecord(name: fighter.name, nationality: nationality!, age: age!, height: height!, weight: weight!, fights: records.sorted { fight1, fight2 in
            fight1.date > fight2.date
        })
        return SherdogResponse(cachedAt: cachedAt, timeCached: timeCached, data: data)
    }
    
    func loadFights(event: Event, forceRefresh: Bool = false) async throws -> SherdogResponse<[Fight]> {
        let html = try await Http.getIfNotExists(url: event.url, forceRefresh: forceRefresh)
        
        let document = try SwiftSoup.parse(html)
        let fightCard = try document.select("div.fight_card")
        var division = try fightCard.select("span.weight_class").text()
        var titleFight = false
        if division.starts(with: "TITLE FIGHT") {
            titleFight = true
            division.replace("TITLE FIGHT ", with: "")
        }
        
        let leftSide = try fightCard.select("div.left_side")
        let figther1StatusText = (try leftSide.select("span.final_result").text()).lowercased().trim()
        let figther1Status = figther1StatusText == "loss" ? FighterStatus.loss : figther1StatusText == "win" ? FighterStatus.win : FighterStatus.pending
        var figther1Name = try leftSide.select("h3").text()
        var fighter1Image: URL? = nil
        var fighter1Url: URL? = nil
        for image in try leftSide.select("img").array() {
            let src = try image.attr("src")
            fighter1Image = URL(string: "\(self.baseUrl)\(src)")
        }
        for a in try leftSide.select("a").array() {
            let href = try a.attr("href")
            fighter1Url = URL(string: "\(self.baseUrl)\(href)")
        }
        
        let rightSide = try fightCard.select("div.right_side")
        let figther2StatusText = (try rightSide.select("span.final_result").text()).lowercased().trim()
        let figther2Status = figther2StatusText == "loss" ? FighterStatus.loss : figther2StatusText == "win" ? FighterStatus.win : FighterStatus.pending
        var figther2Name = try rightSide.select("h3").text()
        var fighter2Image: URL? = nil
        var fighter2Url: URL? = nil
        for image in try rightSide.select("img").array() {
            let src = try image.attr("src")
            fighter2Image = URL(string: "\(self.baseUrl)\(src)")
        }
        for a in try rightSide.select("a").array() {
            let href = try a.attr("href")
            fighter2Url = URL(string: "\(self.baseUrl)\(href)")
        }
        
        var fightStatus = FightStatus.done
        print("figther1StatusText=\(figther1StatusText)")
        if figther1StatusText.contains("yet to come") {
            figther1Name = figther1Name.replacingOccurrences(of: "yet to come", with: "")
            fightStatus = FightStatus.pending
        }
        print("figther2StatusText=\(figther2StatusText)")
        if figther2StatusText.contains("yet to come") {
            figther2Name = figther2Name.replacingOccurrences(of: "yet to come", with: "")
            fightStatus = FightStatus.pending
        }
        print("fightStatus=\(fightStatus)")
        
        var position: Int = 1000
        var result: String = ""
        var round: String = ""
        var time: String = ""
        var referee: String = ""
        
        
        let resumeTables = try document.select("table.fight_card_resume")
        for table in resumeTables.array() {
            let rows = try table.select("tr")
            var rowNumber = -1
            for row in rows.array() {
                rowNumber += 1
                let columns = try row.select("td")
                var columnNumber = -1
                for column in columns.array() {
                    columnNumber += 1
                    let columnText = try column.text()
                    switch columnNumber {
                    case 0: {
                        let parts = columnText.split(separator: " ")
                        let positionText = String(parts[parts.count - 1])
                        position = Int(positionText) ?? -2
                    }()
                    case 1: result = columnText.replacingOccurrences(of: "Method ", with: "")
                    case 2: referee = columnText.replacingOccurrences(of: "Referee ", with: "")
                    case 3: round = columnText.replacingOccurrences(of: "Round ", with: "")
                    case 4: time = columnText.replacingOccurrences(of: "Time ", with: "")
                    default: throw SherdogErrors.invalidColumn(position: columnNumber, value: columnText)
                    }
                }
            }
        }
        
        var fights: [Fight] = []
        let fight = Fight(position: position, figther1: Fighter(name: figther1Name, image: fighter1Image!, link: fighter1Url!), figther1Status: figther1Status, figther2: Fighter(name: figther2Name, image: fighter2Image!, link: fighter2Url!), figther2Status: figther2Status, result: result, round: round, time: time, referee: referee, division: division, fightStatus: fightStatus, titleFight: titleFight)
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
                var fighter1Image: URL? = nil
                var fighter1Url: URL? = nil
                var fighter1Status: FighterStatus = FighterStatus.pending
                var fighter2Name: String? = nil
                var fighter2Image: URL? = nil
                var fighter2Url: URL? = nil
                var fighter2Status: FighterStatus = FighterStatus.pending
                var fightStatus: FightStatus? = nil
                
                let columns = try row.select("td")
                var columnNumber = -1
                for column in columns.array() {
                    columnNumber += 1
                    let columnText = try column.text()
                    //print("rowNumber=\(rowNumber) columnNumber=\(columnNumber) columnText=\(columnText)")
                    
                    if columns.count == 5 {
                        fighter1Status = FighterStatus.pending
                        fighter2Status = FighterStatus.pending
                        fightStatus = FightStatus.pending
                        
                        switch columnNumber {
                        case 0: position = Int(columnText)
                        case 1: try {
                            let components = columnText.replacingOccurrences(of: "yet to come", with: "").split(separator: " ")
                            fighter1Name = components.dropLast().joined(separator: " ")
                            
                            for image in try column.select("img").array() {
                                let src = try image.attr("src")
                                fighter1Image = URL(string: "\(self.baseUrl)\(src)")
                            }
                            for a in try column.select("a").array() {
                                let href = try a.attr("href")
                                fighter1Url = URL(string: "\(self.baseUrl)\(href)")
                            }
                        }()
                        case 2: division = columnText
                        case 3: try {
                            let components = columnText.split(separator: " ")
                            fighter2Name = components.dropLast().joined(separator: " ")
                            
                            for image in try column.select("img").array() {
                                let src = try image.attr("src")
                                fighter2Image = URL(string: "\(self.baseUrl)\(src)")
                            }
                            for a in try column.select("a").array() {
                                let href = try a.attr("href")
                                fighter2Url = URL(string: "\(self.baseUrl)\(href)")
                            }
                        }()
                        case 4: {
                            result = ""
                            referee = ""
                            round = ""
                            time = ""
                        }()
                        default: throw SherdogErrors.invalidColumn(position: columnNumber, value: columnText)
                        }
                    } else {
                        switch columnNumber {
                        case 0: position = Int(columnText)
                        case 1: try {
                            fighter1Status = columnText.hasSuffix("win") ? FighterStatus.win : FighterStatus.loss
                            
                            let components = columnText.replacingOccurrences(of: "yet to come", with: "").split(separator: " ")
                            fighter1Name = components.dropLast().joined(separator: " ")
                            
                            for image in try column.select("img").array() {
                                let src = try image.attr("src")
                                fighter1Image = URL(string: "\(self.baseUrl)\(src)")
                            }
                            for a in try column.select("a").array() {
                                let href = try a.attr("href")
                                fighter1Url = URL(string: "\(self.baseUrl)\(href)")
                            }
                        }()
                        case 2: division = columnText
                        case 3: try {
                            fighter2Status = columnText.hasSuffix("win") ? FighterStatus.win : FighterStatus.loss
                            
                            let components = columnText.replacingOccurrences(of: "yet to come", with: "").split(separator: " ")
                            fighter2Name = components.dropLast().joined(separator: " ")
                            
                            for image in try column.select("img").array() {
                                let src = try image.attr("src")
                                fighter2Image = URL(string: "\(self.baseUrl)\(src)")
                            }
                            for a in try column.select("a").array() {
                                let href = try a.attr("href")
                                fighter2Url = URL(string: "\(self.baseUrl)\(href)")
                            }
                        }()
                        case 4: {
                            let parts = columnText.split(separator: ")")
                            if parts.count == 2 {
                                result = String(parts[0]).trim() + ")"
                                referee = String(parts[1]).trim()
                                fightStatus = FightStatus.done
                            } else {
                                result = ""
                                referee = ""
                                fightStatus = FightStatus.pending
                            }
                        }()
                        case 5: round = columnText
                        case 6: time = columnText
                        default: throw SherdogErrors.invalidColumn(position: columnNumber, value: columnText)
                        }
                    }
                }
                
                guard position != nil && result != nil && round != nil && time != nil && referee != nil && fightStatus != nil && fighter1Image != nil && fighter1Url != nil && fighter2Image != nil && fighter2Url != nil else {
                    throw SherdogErrors.invalidFigther
                }
                
                var titleFight = false
                if division != nil {
                    if division!.starts(with: "TITLE FIGHT") {
                        division!.replace("TITLE FIGHT ", with: "")
                        titleFight = true
                    }
                }
                
                let figther1: Fighter = Fighter(name: fighter1Name!, image: fighter1Image!, link: fighter1Url!)
                let figther2: Fighter = Fighter(name: fighter2Name!, image: fighter2Image!, link: fighter2Url!)
                let fight = Fight(position: position!, figther1: figther1, figther1Status: fighter1Status, figther2: figther2, figther2Status: fighter2Status, result: result!, round: round!, time: time!, referee: referee!, division: division!, fightStatus: fightStatus!, titleFight: titleFight)
                fights.append(fight)
            }
        }
        
        let cachedAt: Date? = try LocalStorage.getCachedAt(fileName: event.url)
        let timeCached: String? = try LocalStorage.getTimeCached(fileName: event.url)
        let data: [Fight] = fights.sorted { fight1, fight2 in
            fight1.position > fight2.position
        }
        return SherdogResponse(cachedAt: cachedAt, timeCached: timeCached, data: data)
    }
    
    func getLastEvent(forceRefresh: Bool = false) async throws -> Event {
        let events = try await loadEvents(forceRefresh: forceRefresh)
        
        // Filter for past events (events that have already happened)
        let pastEvents = events.data.filter { event in event.date <= Date.now}
        
        // Ensure we have at least one past event
        guard let lastEvent = pastEvents.first else {
            throw SherdogErrors.noEventsFound
        }
        
        return lastEvent;
    }
    
    func getLastEventStats(forceRefresh: Bool = false) async throws -> SherdogResponse<EventStats> {
        let lastEvent = try await getLastEvent(forceRefresh: forceRefresh)
        let fights = try await loadFights(event: lastEvent, forceRefresh: forceRefresh)
        
        var kos = 0
        var submissions = 0
        var decisions = 0
        
        for fight in fights.data {
            let result = fight.result.uppercased()
            
            if result.hasPrefix("KO") || result.hasPrefix("TKO") || result.contains("KO/TKO") {
                kos += 1
            } else if result.contains("SUBMISSION") || result.hasPrefix("SUB") {
                submissions += 1
            } else if result.contains("DECISION") || result.contains("DEC") {
                decisions += 1
            }
        }
        let cachedAt: Date? = try LocalStorage.getCachedAt(fileName:lastEvent.url)
        let timeCached: String? = try LocalStorage.getTimeCached(fileName: lastEvent.url)
        
        let name = lastEvent.name;
        let mainFight = lastEvent.fight ?? "";
        
        return SherdogResponse(cachedAt: cachedAt, timeCached: timeCached, data: EventStats(name: name, mainFight: mainFight, kos: kos, submissions: submissions, decisions: decisions))
    }
    
    func getEventStats(event: Event, forceRefresh: Bool = false) async throws -> SherdogResponse<EventStats> {
        let fights = try await loadFights(event: event, forceRefresh: forceRefresh)
        
        var kos = 0
        var submissions = 0
        var decisions = 0
        
        for fight in fights.data {
            let result = fight.result.uppercased()
            
            if result.hasPrefix("KO") || result.hasPrefix("TKO") || result.contains("KO/TKO") {
                kos += 1
            } else if result.contains("SUBMISSION") || result.hasPrefix("SUB") {
                submissions += 1
            } else if result.contains("DECISION") || result.contains("DEC") {
                decisions += 1
            }
        }
        
        let cachedAt: Date? = try LocalStorage.getCachedAt(fileName: event.url)
        let timeCached: String? = try LocalStorage.getTimeCached(fileName: event.url)
        
        let name = event.name.split(separator: ":", maxSplits: 1)
            .first?
            .trimmingCharacters(in: .whitespaces) ?? ""
        let mainFight = event.name.split(separator: ":", maxSplits: 1)
            .last?
            .trimmingCharacters(in: .whitespaces) ?? ""
        
        return SherdogResponse(cachedAt: cachedAt, timeCached: timeCached, data: EventStats(name: name, mainFight: mainFight, kos: kos, submissions: submissions, decisions: decisions))
    }
    
    func loadEvents(forceRefresh: Bool = false) async throws -> SherdogResponse<[Event]> {
        let html = try await Http.getIfNotExists(url: eventsUrl, forceRefresh: forceRefresh)
        
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
                    url = "\(self.baseUrl)/\(String(onClickUrl[startIndex..<endIndex]))"
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
                    default: throw SherdogErrors.invalidColumn(position: columnNumber, value: columnText)
                    }
                }
                
                guard nameAndFight != nil && location != nil && date != nil && url != nil else {
                    throw SherdogErrors.invalidEvent
                }
                
                let parts = nameAndFight!.split(separator: "-")
                let name: String = String(parts[0]).trim()
                let fight: String = String(parts[1]).trim()
                let event = Event(name: name, fight: fight.lowercased().contains("vs") ? fight : nil, location: location!, date: date!, url: url!)
                events.append(event)
            }
        }
        
        let cachedAt: Date? = try LocalStorage.getCachedAt(fileName: eventsUrl)
        let timeCached: String? = try LocalStorage.getTimeCached(fileName: eventsUrl)
        let data: [Event] = events.sorted { event1, event2 in
            event1.date > event2.date
        }
        return SherdogResponse(cachedAt: cachedAt, timeCached: timeCached, data: data)
    }
}
