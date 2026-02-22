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

    func loadRecord(fighter: Fighter, forceRefresh: Bool) async throws -> MMADataProviderResponse<FighterRecord> {
        let html = try await Http.getIfNotExists(url: fighter.link, forceRefresh: forceRefresh)
        let document = try SwiftSoup.parse(html)

        let (nationality, age, height, weight) = parseBio(from: document)
        let records = try parseFightRecords(from: document, athleteName: fighter.name)

        let cachedAt: Date? = try LocalStorage.getCachedAt(fileName: fighter.link.absoluteString)
        let timeCached: String? = try LocalStorage.getTimeCached(fileName: fighter.link.absoluteString)
        let data = FighterRecord(
            name: fighter.name,
            nationality: nationality,
            age: age,
            height: height,
            weight: weight,
            fights: records.sorted { $0.date > $1.date }
        )
        return MMADataProviderResponse(cachedAt: cachedAt, timeCached: timeCached, data: data)
    }

    private func parseBio(from document: Document) -> (nationality: String, age: String, height: String, weight: String) {
        var nationality = "TBD"
        var age = "TBD"
        var height = "TBD"
        var weight = "TBD"

        let wrap = try? document.select("div.faq-athlete__wrap").first()
        let scope = wrap ?? document
        let labels = try? scope.select("div.c-bio__label")
        let texts = try? scope.select("div.c-bio__text")
        guard let labelArray = labels?.array(), let textArray = texts?.array(), labelArray.count == textArray.count else {
            if let ageField = try? document.select("div.field--name-age").first() {
                age = (try? ageField.text()) ?? "TBD"
            }
            return (nationality, age, height, weight)
        }

        for (labelEl, textEl) in zip(labelArray, textArray) {
            guard let label = try? labelEl.text(), let text = try? textEl.text().trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else { continue }
            switch label {
            case "Place of Birth": nationality = text
            case "Age": age = text
            case "Height": height = text
            case "Weight": weight = text
            default: break
            }
        }

        if age == "TBD", let ageField = try? scope.select("div.field--name-age").first() {
            age = (try? ageField.text()) ?? "TBD"
        }
        return (nationality, age, height, weight)
    }

    private func parseFightRecords(from document: Document, athleteName: String) throws -> [Record] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM. d, yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let altDateFormatter = DateFormatter()
        altDateFormatter.dateFormat = "MMM d, yyyy"
        altDateFormatter.locale = Locale(identifier: "en_US_POSIX")

        var records: [Record] = []
        let articles = try document.select("article.c-card-event--athlete-results")

        for article in articles.array() {
            guard let status = parseAthleteStatus(from: article),
                  let (opponent, event, date) = parseFightDetails(from: article, athleteName: athleteName, dateFormatter: dateFormatter, altDateFormatter: altDateFormatter),
                  let (round, time, method) = parseFightResult(from: article) else {
                continue
            }

            records.append(Record(
                status: status,
                figther: opponent,
                event: event,
                date: date,
                method: method,
                referee: nil,
                round: round,
                time: time
            ))
        }

        return records
    }

    private func parseAthleteStatus(from article: Element) -> FighterStatus? {
        guard let redImage = try? article.select("div.c-card-event--athlete-results__red-image").first(),
              let classes = try? redImage.className() else { return nil }
        return classes.contains("win") ? .win : (classes.contains("loss") ? .loss : .pending)
    }

    private func parseFightDetails(from article: Element, athleteName: String, dateFormatter: DateFormatter, altDateFormatter: DateFormatter) -> (opponent: String, event: String, date: Date)? {
        guard let headline = try? article.select("h3.c-card-event--athlete-results__headline").first(),
              let dateEl = try? article.select("div.c-card-event--athlete-results__date").first(),
              let dateStr = try? dateEl.text().trimmingCharacters(in: .whitespacesAndNewlines) else { return nil }
        guard let date = dateFormatter.date(from: dateStr) ?? altDateFormatter.date(from: dateStr) else { return nil }

        let links = (try? headline.select("a").array()) ?? []
        let names = links.compactMap { try? $0.text().trimmingCharacters(in: .whitespacesAndNewlines) }
        let opponent = names.first { !nameMatches($0, athleteName) } ?? (names.count > 1 ? names[1] : (names.first ?? "Unknown"))

        var event = "UFC"
        if let fightCardLink = try? article.select("a[href*='/event/']").first(),
           let href = try? fightCardLink.attr("href"),
           let url = URL(string: href.hasPrefix("http") ? href : "\(baseUrl)\(href)") {
            let path = url.path
            let slug = path.split(separator: "/").last.map(String.init) ?? ""
            event = eventNameFromPath("/event/\(slug)")
        }

        return (opponent, event, date)
    }

    private func parseFightResult(from article: Element) -> (round: String, time: String, method: String)? {
        var round = ""
        var time = ""
        var method = ""

        let resultDivs = (try? article.select("div.c-card-event--athlete-results__result").array()) ?? []
        for div in resultDivs {
            guard let label = try? div.select("div.c-card-event--athlete-results__result-label").first()?.text(),
                  let value = try? div.select("div.c-card-event--athlete-results__result-text").first()?.text() else { continue }
            switch label {
            case "Round": round = value
            case "Time": time = value
            case "Method": method = value
            default: break
            }
        }
        return method.isEmpty ? nil : (round, time, method)
    }

    func getLastEvent(forceRefresh: Bool) async throws -> Event {
        fatalError("Not implemented yet")
    }

    func getLastEventStats(forceRefresh: Bool) async throws -> MMADataProviderResponse<EventStats> {
        fatalError("Not implemented yet")
    }

    func getEventStats(event: Event, forceRefresh: Bool) async throws -> MMADataProviderResponse<EventStats> {
        fatalError("Not implemented yet")
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

            var (status1, status2) = parseOutcomes(from: fightDiv)
            let (division, titleFight) = parseDivision(from: fightDiv)
            var (result, round, time, fightStatus) = parseResult(from: fightDiv)

            // Fallback: event page loads results via JS; fetch results news pages for live/recent events
            if fightStatus == .pending {
                let resultsFromNews = await fetchResultsFromNewsPages(eventHtml: html, forceRefresh: forceRefresh)
                if let match = resultsFromNews.first(where: { matchesFight(winner: $0.winner, loser: $0.loser, fighter1: fighter1.name, fighter2: fighter2.name) }) {
                    if nameMatches(match.winner, fighter1.name) {
                        status1 = .win
                        status2 = .loss
                    } else {
                        status1 = .loss
                        status2 = .win
                    }
                    result = match.method
                    round = match.round
                    time = match.time
                    fightStatus = .done
                }
            }

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
        // Upcoming events have c-listing-fight__details without --with-results; no outcome--win/loss
        let hasResults = (try? fightDiv.select(".c-listing-fight__details--with-results").first()) != nil
        guard hasResults else {
            return (.pending, .pending)
        }

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
        // Upcoming events lack --with-results; completed fights have outcome--win/loss and result details
        let hasResults = (try? fightDiv.select(".c-listing-fight__details--with-results").first()) != nil
        guard hasResults else {
            return ("", "", "", .pending)
        }

        let method = (try? fightDiv.select(".c-listing-fight__result-text.method").first()?.text()) ?? ""
        let round = (try? fightDiv.select(".c-listing-fight__result-text.round").first()?.text()) ?? ""
        let time = (try? fightDiv.select(".c-listing-fight__result-text.time").first()?.text()) ?? ""
        return (method, round, time, .done)
    }

    /// Results news pages have "X defeated Y by Z" in raw HTML when event page loads results via JS
    private func fetchResultsFromNewsPages(eventHtml: String, forceRefresh: Bool) async -> [(winner: String, loser: String, method: String, round: String, time: String)] {
        guard let doc = try? SwiftSoup.parse(eventHtml),
              let links = try? doc.select("a[href*='results-highlights']") else {
            return []
        }
        var allResults: [(winner: String, loser: String, method: String, round: String, time: String)] = []
        for link in links.array() {
            guard let href = try? link.attr("href"), href.contains("/news/"),
                  let url = URL(string: href.hasPrefix("http") ? href : "\(baseUrl)\(href)") else {
                continue
            }
            let html: String
            do {
                html = try await Http.getIfNotExists(url: url.absoluteString, forceRefresh: forceRefresh)
            } catch {
                continue
            }
            allResults.append(contentsOf: parseResultsFromNewsHtml(html))
        }
        return allResults
    }

    private func parseResultsFromNewsHtml(_ html: String) -> [(winner: String, loser: String, method: String, round: String, time: String)] {
        var results: [(winner: String, loser: String, method: String, round: String, time: String)] = []
        // Format: "X defeated Y by Z" or "X defeated Y by Z at X:XX of Round N"
        let pattern = #"<h3><strong>([^<]+) defeated ([^<]+) by ([^<]+)</strong></h3>"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let range = NSRange(html.startIndex..., in: html)
        regex.enumerateMatches(in: html, range: range) { match, _, _ in
            guard let m = match, m.numberOfRanges >= 4,
                  let winnerRange = Range(m.range(at: 1), in: html),
                  let loserRange = Range(m.range(at: 2), in: html),
                  let methodRange = Range(m.range(at: 3), in: html) else { return }
            var winner = String(html[winnerRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            var loser = String(html[loserRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            if let p = winner.range(of: " (", options: .literal) { winner = String(winner[..<p.lowerBound]).trimmingCharacters(in: .whitespaces) }
            if let p = loser.range(of: " (", options: .literal) { loser = String(loser[..<p.lowerBound]).trimmingCharacters(in: .whitespaces) }
            var method = String(html[methodRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            var round = ""
            var time = ""
            // Parse "submission (rear-naked choke) at 2:24 of Round 2" -> method, time, round
            if let atRange = method.range(of: " at ", options: .caseInsensitive),
               let ofRange = method.range(of: " of Round ", options: .caseInsensitive) {
                time = String(method[atRange.upperBound..<ofRange.lowerBound]).trimmingCharacters(in: .whitespaces)
                let afterRound = method[ofRange.upperBound...]
                round = String(afterRound.split(separator: " ").first ?? "").trimmingCharacters(in: .whitespaces)
                method = String(method[..<atRange.lowerBound]).trimmingCharacters(in: .whitespaces)
            } else if method.lowercased().contains("decision") {
                round = "3"
                time = "5:00"
            }
            results.append((winner: winner, loser: loser, method: method, round: round, time: time))
        }
        return results
    }

    private func matchesFight(winner: String, loser: String, fighter1: String, fighter2: String) -> Bool {
        (nameMatches(winner, fighter1) && nameMatches(loser, fighter2)) || (nameMatches(winner, fighter2) && nameMatches(loser, fighter1))
    }

    private func nameMatches(_ newsName: String, _ fighterName: String) -> Bool {
        let n = newsName.lowercased()
        let f = fighterName.lowercased()
        if n.contains(f) || f.contains(n) { return true }
        if let lastName = fighterName.split(separator: " ").last.map(String.init)?.lowercased() {
            return n.contains(lastName)
        }
        return false
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
