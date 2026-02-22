//
//  Mock.swift
//  MMAScoreCard
//
//  Created by dvaca on 21/2/26.
//

import Foundation

/// Mock MMA data provider for previews and testing.
/// Returns fake data without network requests.
final class Mock: MMADataProvider {
    static let shared = Mock()

    private let placeholderImageUrl = URL(string: "https://example.com/placeholder.png")!
    private let baseUrl = "https://mock.example.com"

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
            wins: 2,
            losses: 1,
            draws: 0,
            noContests: 0,
            fights: records
        )
        return MMADataProviderResponse(cachedAt: Date(), timeCached: "Mock", data: record)
    }

    func loadFights(event: Event, forceRefresh: Bool) async throws -> MMADataProviderResponse<[Fight]> {
        let fighter1 = Fighter(name: "Alex Pereira", image: placeholderImageUrl, link: URL(string: "\(baseUrl)/fighter/1")!)
        let fighter2 = Fighter(name: "Magomed Ankalaev", image: placeholderImageUrl, link: URL(string: "\(baseUrl)/fighter/2")!)
        let fighter3 = Fighter(name: "Islam Makhachev", image: placeholderImageUrl, link: URL(string: "\(baseUrl)/fighter/3")!)
        let fighter4 = Fighter(name: "Dustin Poirier", image: placeholderImageUrl, link: URL(string: "\(baseUrl)/fighter/4")!)

        let fights = [
            Fight(position: 1, figther1: fighter1, figther1Status: .win, figther2: fighter2, figther2Status: .loss, result: "KO/TKO", round: "2", time: "1:04", referee: "Herb Dean", division: "Light Heavyweight", fightStatus: .done, titleFight: true),
            Fight(position: 2, figther1: fighter3, figther1Status: .win, figther2: fighter4, figther2Status: .loss, result: "Submission (D'Arce)", round: "5", time: "2:42", referee: "Marc Goddard", division: "Lightweight", fightStatus: .done, titleFight: true),
        ]
        return MMADataProviderResponse(cachedAt: Date(), timeCached: "Mock", data: fights)
    }

    func getLastEvent(forceRefresh: Bool) async throws -> Event {
        try await loadEvents(forceRefresh: forceRefresh).data.first!
    }

    func getLastEventStats(forceRefresh: Bool) async throws -> MMADataProviderResponse<EventStats> {
        let lastEvent = try await getLastEvent(forceRefresh: forceRefresh)
        let stats = EventStats(name: lastEvent.name, mainFight: "Pereira vs. Ankalaev", kos: 5, submissions: 3, decisions: 4)
        return MMADataProviderResponse(cachedAt: Date(), timeCached: "Mock", data: stats)
    }

    func getEventStats(event: Event, forceRefresh: Bool) async throws -> MMADataProviderResponse<EventStats> {
        let mainFight = event.fight ?? "Main Event"
        let stats = EventStats(name: event.name, mainFight: mainFight, kos: 4, submissions: 2, decisions: 6)
        return MMADataProviderResponse(cachedAt: Date(), timeCached: "Mock", data: stats)
    }

    func loadEvents(forceRefresh: Bool) async throws -> MMADataProviderResponse<[Event]> {
        let calendar = Calendar.current
        let events = [
            Event(name: "UFC 311", fight: "Pereira vs. Hill", location: "Las Vegas, NV", date: calendar.date(byAdding: .day, value: 14, to: Date())!, url: "\(baseUrl)/event/311"),
            Event(name: "UFC 310", fight: "Pereira vs. Ankalaev", location: "Miami, FL", date: Date(), url: "\(baseUrl)/event/310"),
            Event(name: "UFC 309", fight: "Makhachev vs. Poirier", location: "Newark, NJ", date: calendar.date(byAdding: .day, value: -7, to: Date())!, url: "\(baseUrl)/event/309"),
            Event(name: "UFC 308", fight: "Topuria vs. Holloway", location: "Anaheim, CA", date: calendar.date(byAdding: .day, value: -30, to: Date())!, url: "\(baseUrl)/event/308"),
        ]
        return MMADataProviderResponse(cachedAt: Date(), timeCached: "Mock", data: events)
    }
}
