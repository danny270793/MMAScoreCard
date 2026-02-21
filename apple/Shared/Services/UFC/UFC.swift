//
//  UFC.swift
//  MMAScoreCard
//
//  Created by dvaca on 21/2/26.
//

import Foundation
import SwiftSoup

/// UFC.com data provider. Fetches events from https://www.ufc.com/events
final class UFC: MMADataProvider {
    static let shared = UFC()

    private let placeholderImageUrl = URL(string: "https://example.com/placeholder.png")!
    private let baseUrl = "https://www.ufc.com"
    private var eventsUrl: String { "\(baseUrl)/events" }

    private init() {}

    func loadImage(url: URL) async throws -> Data {
        Data()
    }

    func getLastEvent(forceRefresh: Bool) async throws -> Event {
        let events = try await loadEvents(forceRefresh: forceRefresh)
        
        // Filter for past events (events that have already happened)
        let pastEvents = events.data.filter { event in event.date <= Date.now}
        
        // Ensure we have at least one past event
        guard let lastEvent = pastEvents.first else {
            throw SherdogErrors.noEventsFound
        }
        
        return lastEvent;
    }

    func getLastEventStats(forceRefresh: Bool) async throws -> MMADataProviderResponse<EventStats> {
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
        
        return MMADataProviderResponse(cachedAt: cachedAt, timeCached: timeCached, data: EventStats(name: name, mainFight: mainFight, kos: kos, submissions: submissions, decisions: decisions))
    }

    func getEventStats(event: Event, forceRefresh: Bool) async throws -> MMADataProviderResponse<EventStats> {
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
        
        return MMADataProviderResponse(cachedAt: cachedAt, timeCached: timeCached, data: EventStats(name: name, mainFight: mainFight, kos: kos, submissions: submissions, decisions: decisions))
    }

    func loadRecord(fighter: Fighter, forceRefresh: Bool) async throws -> MMADataProviderResponse<FighterRecord> {
        let html = try await Http.getIfNotExists(url: fighter.link, forceRefresh: forceRefresh)
        let document = try SwiftSoup.parse(html)

        var nationality = "—"
        var age = "—"
        var height = "—"
        var weight = "—"

        let bioFields = try document.select(".c-bio__field")
        for field in bioFields.array() {
            guard let label = try? field.select(".c-bio__label").first()?.text().trimmingCharacters(in: .whitespacesAndNewlines),
                  let text = try? field.select(".c-bio__text").first()?.text().trimmingCharacters(in: .whitespacesAndNewlines) else {
                continue
            }
            switch label {
            case "Place of Birth": nationality = text
            case "Age": age = text.isEmpty ? ((try? field.select(".field__item").first()?.text()) ?? "—") : text
            case "Height": height = text
            case "Weight": weight = text
            default: break
            }
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM. d, yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        var records: [Record] = []
        let fighterPath = fighter.link.path
        let resultCards = try document.select("article.c-card-event--athlete-results")

        for card in resultCards.array() {
            let status: FighterStatus
            if (try? card.select(".c-card-event--athlete-results__plaque.win").first()) != nil {
                status = .win
            } else if (try? card.select(".c-card-event--athlete-results__plaque.loss").first()) != nil {
                status = .loss
            } else {
                continue
            }

            var opponent = "TBD"
            if let headline = try? card.select(".c-card-event--athlete-results__headline").first() {
                for anchor in try headline.select("a").array() {
                    let href = (try? anchor.attr("href")) ?? ""
                    if !href.contains(fighterPath) && !fighterPath.contains(href) {
                        opponent = (try? anchor.text())?.trimmingCharacters(in: .whitespacesAndNewlines) ?? opponent
                        break
                    }
                }
            }

            var eventName = "UFC Event"
            if let actions = try? card.select(".c-card-event--athlete-results__actions a").first(),
               let href = try? actions.attr("href"), href.contains("/event/") {
                let slug = href.split(separator: "/").last?.split(separator: "#").first.map(String.init) ?? ""
                eventName = slug.replacingOccurrences(of: "-", with: " ").capitalized
            }

            guard let dateEl = try? card.select(".c-card-event--athlete-results__date").first(),
                  let dateStr = try? dateEl.text().trimmingCharacters(in: .whitespacesAndNewlines),
                  let date = dateFormatter.date(from: dateStr) else {
                continue
            }

            var round = ""
            var time = ""
            var method = ""
            for resultEl in (try? card.select(".c-card-event--athlete-results__result").array()) ?? [] {
                let label = (try? resultEl.select(".c-card-event--athlete-results__result-label").first()?.text()) ?? ""
                let value = (try? resultEl.select(".c-card-event--athlete-results__result-text").first()?.text()) ?? ""
                switch label {
                case "Round": round = value
                case "Time": time = value
                case "Method": method = value
                default: break
                }
            }

            records.append(Record(status: status, figther: opponent, event: eventName, date: date, method: method, referee: nil, round: round, time: time))
        }

        let cachedAt: Date? = try LocalStorage.getCachedAt(fileName: fighter.link.absoluteString)
        let timeCached: String? = try LocalStorage.getTimeCached(fileName: fighter.link.absoluteString)
        let data = FighterRecord(name: fighter.name, nationality: nationality, age: age, height: height, weight: weight, fights: records.sorted { $0.date > $1.date })
        return MMADataProviderResponse(cachedAt: cachedAt, timeCached: timeCached, data: data)
    }

    func loadFights(event: Event, forceRefresh: Bool) async throws -> MMADataProviderResponse<[Fight]> {
        let html = try await Http.getIfNotExists(url: event.url, forceRefresh: forceRefresh)
        let document = try SwiftSoup.parse(html)
        let fightDivs = try document.select("div.c-listing-fight")

        var fights: [Fight] = []
        for (index, fightDiv) in fightDivs.array().enumerated() {
            let position = index + 1

            guard let fighter1 = parseFighter(from: fightDiv, corner: "red"),
                  let fighter2 = parseFighter(from: fightDiv, corner: "blue") else {
                continue
            }

            let (status1, status2) = parseOutcomes(from: fightDiv)
            let (division, titleFight) = parseDivision(from: fightDiv)
            let (result, round, time, fightStatus) = parseResult(from: fightDiv)

            let fight = Fight(
                position: position,
                figther1: fighter1,
                figther1Status: status1,
                figther2: fighter2,
                figther2Status: status2,
                result: result,
                round: round,
                time: time,
                referee: nil,
                division: division,
                fightStatus: fightStatus,
                titleFight: titleFight
            )
            fights.append(fight)
        }

        let cachedAt: Date? = try LocalStorage.getCachedAt(fileName: event.url)
        let timeCached: String? = try LocalStorage.getTimeCached(fileName: event.url)
        return MMADataProviderResponse(cachedAt: cachedAt, timeCached: timeCached, data: fights)
    }

    private func parseFighter(from fightDiv: Element, corner: String) -> Fighter? {
        guard let nameEl = try? fightDiv.select(".c-listing-fight__corner-name--\(corner)").first(),
              let linkEl = try? nameEl.select("a").first(),
              let href = try? linkEl.attr("href").trimmingCharacters(in: .whitespaces),
              !href.isEmpty else {
            return nil
        }

        var name: String
        if let given = try? fightDiv.select(".c-listing-fight__corner-name--\(corner) .c-listing-fight__corner-given-name").first()?.text(),
           let family = try? fightDiv.select(".c-listing-fight__corner-name--\(corner) .c-listing-fight__corner-family-name").first()?.text(),
           !given.isEmpty || !family.isEmpty {
            name = "\(given) \(family)".trimmingCharacters(in: .whitespaces)
        } else {
            name = (try? linkEl.text())?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "TBD"
        }

        var imageUrl = placeholderImageUrl
        if let img = try? fightDiv.select(".c-listing-fight__corner-image--\(corner) img").first(),
           let src = try? img.attr("src").trimmingCharacters(in: .whitespaces),
           !src.isEmpty,
           let url = URL(string: src.hasPrefix("//") ? "https:\(src)" : src) {
            imageUrl = url
        }

        let absoluteHref = href.hasPrefix("http") ? href : "\(baseUrl)\(href.hasPrefix("/") ? href : "/athlete/unknown")"
        guard let linkUrl = URL(string: absoluteHref) else { return nil }
        return Fighter(name: name, image: imageUrl, link: linkUrl)
    }

    private func parseOutcomes(from fightDiv: Element) -> (FighterStatus, FighterStatus) {
        let redWin = (try? fightDiv.select(".c-listing-fight__corner--red .c-listing-fight__outcome--win").first()) != nil
        let redLoss = (try? fightDiv.select(".c-listing-fight__corner--red .c-listing-fight__outcome--loss").first()) != nil
        let blueWin = (try? fightDiv.select(".c-listing-fight__corner--blue .c-listing-fight__outcome--win").first()) != nil
        let blueLoss = (try? fightDiv.select(".c-listing-fight__corner--blue .c-listing-fight__outcome--loss").first()) != nil

        let status1: FighterStatus = redWin ? .win : (redLoss ? .loss : .pending)
        let status2: FighterStatus = blueWin ? .win : (blueLoss ? .loss : .pending)
        return (status1, status2)
    }

    private func parseDivision(from fightDiv: Element) -> (String, Bool) {
        let text = (try? fightDiv.select(".c-listing-fight__class-text").first()?.text()) ?? ""
        let titleFight = text.lowercased().contains("title")
        let division = text
            .replacingOccurrences(of: " Title Bout", with: "")
            .replacingOccurrences(of: " Bout", with: "")
            .trimmingCharacters(in: .whitespaces)
        return (division.isEmpty ? "TBD" : division, titleFight)
    }

    private func parseResult(from fightDiv: Element) -> (result: String, round: String, time: String, fightStatus: FightStatus) {
        let hasOutcome = (try? fightDiv.select(".c-listing-fight__outcome--win, .c-listing-fight__outcome--loss").first()) != nil
        guard hasOutcome else {
            return ("", "", "", .pending)
        }

        let method = (try? fightDiv.select(".c-listing-fight__result-text.method").first()?.text()) ?? ""
        let round = (try? fightDiv.select(".c-listing-fight__result-text.round").first()?.text()) ?? ""
        let time = (try? fightDiv.select(".c-listing-fight__result-text.time").first()?.text()) ?? ""
        return (method, round, time, .done)
    }

    func loadEvents(forceRefresh: Bool) async throws -> MMADataProviderResponse<[Event]> {
        let html = try await Http.getIfNotExists(url: eventsUrl, forceRefresh: forceRefresh)
        let document = try SwiftSoup.parse(html)
        let articles = try document.select("article.c-card-event--result")

        var events: [Event] = []
        for article in articles.array() {
            guard let headlineAnchor = try? article.select("h3.c-card-event--result__headline a").first(),
                  let fightTitle = try? headlineAnchor.text().trimmingCharacters(in: .whitespacesAndNewlines),
                  let relativeHref = try? headlineAnchor.attr("href"),
                  let dateDiv = try? article.select(".c-card-event--result__date").first(),
                  let timestampStr = try? dateDiv.attr("data-main-card-timestamp"),
                  let timestamp = Double(timestampStr) else {
                continue
            }

            let eventUrl = relativeHref.hasPrefix("http") ? relativeHref : "\(baseUrl)\(relativeHref)"
            let eventDate = Date(timeIntervalSince1970: timestamp)

            var eventName = eventNameFromPath(relativeHref)
            var location = "TBD"

            if let locationDiv = try? article.select(".c-card-event--result__location").first() {
                if let venueH5 = try? locationDiv.select(".taxonomy-term--type-venue h5").first(),
                   let venue = try? venueH5.text().trimmingCharacters(in: .whitespacesAndNewlines), !venue.isEmpty {
                    location = venue
                    if let addrP = try? locationDiv.select(".field--name-location p.address").first(),
                       let addrText = try? addrP.text().trimmingCharacters(in: .whitespacesAndNewlines), !addrText.isEmpty {
                        let lines = addrText.split(separator: "\n").map { $0.trimmingCharacters(in: .whitespaces) }
                        if let first = lines.first {
                            location = "\(venue), \(first)"
                        }
                    }
                } else if let addrP = try? locationDiv.select(".field--name-location p.address").first(),
                          let addrText = try? addrP.text().trimmingCharacters(in: .whitespacesAndNewlines), !addrText.isEmpty {
                    location = addrText.replacingOccurrences(of: "\n", with: ", ")
                }
            }

            let fight = fightTitle.lowercased().contains("vs") ? fightTitle : nil
            events.append(Event(name: eventName, fight: fight, location: location, date: eventDate, url: eventUrl))
        }

        let cachedAt: Date? = try LocalStorage.getCachedAt(fileName: eventsUrl)
        let timeCached: String? = try LocalStorage.getTimeCached(fileName: eventsUrl)
        let data = events.sorted { $0.date > $1.date }
        return MMADataProviderResponse(cachedAt: cachedAt, timeCached: timeCached, data: data)
    }

    private func eventNameFromPath(_ path: String) -> String {
        let slug = path.split(separator: "/").last.map(String.init) ?? path
        var name = slug.replacingOccurrences(of: "-", with: " ").capitalized
        let months = "January|February|March|April|May|June|July|August|September|October|November|December"
        if let range = name.range(of: "\\s(\(months))\\s\\d{1,2}\\s\\d{4}$", options: .regularExpression) {
            name.removeSubrange(range)
        }
        return name.trimmingCharacters(in: .whitespaces)
    }
}
