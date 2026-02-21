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
        let records = [
            Record(status: .win, figther: "John Doe", event: "UFC 310", date: Date().addingTimeInterval(-86400 * 30), method: "KO/TKO", referee: "Herb Dean", round: "2", time: "4:32"),
            Record(status: .loss, figther: "Jane Smith", event: "UFC 309", date: Date().addingTimeInterval(-86400 * 60), method: "Decision (Unanimous)", referee: "Marc Goddard", round: "3", time: "5:00"),
            Record(status: .win, figther: "Bob Johnson", event: "UFC 308", date: Date().addingTimeInterval(-86400 * 90), method: "Submission (RNC)", referee: nil, round: "1", time: "3:15"),
        ]
        let record = FighterRecord(
            name: fighter.name,
            nationality: "United States",
            age: "28",
            height: "5'10\"",
            weight: "170 lbs",
            fights: records
        )
        return MMADataProviderResponse(cachedAt: Date(), timeCached: "Mock", data: record)
    }

    func getLastEvent(forceRefresh: Bool) async throws -> Event {
        throw NotImplementedError()
    }

    func getLastEventStats(forceRefresh: Bool) async throws -> MMADataProviderResponse<EventStats> {
        throw NotImplementedError()
    }

    func getEventStats(event: Event, forceRefresh: Bool) async throws -> MMADataProviderResponse<EventStats> {
        throw NotImplementedError()
    }

    func loadFights(event: Event, forceRefresh: Bool) async throws -> MMADataProviderResponse<[Fight]> {
        let html = try await Http.getIfNotExists(url: event.url, forceRefresh: forceRefresh)
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
