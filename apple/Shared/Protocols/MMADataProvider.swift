//
//  MMADataProvider.swift
//  MMAScoreCard
//
//  Created by dvaca on 21/2/25.
//

import Foundation
import SwiftUI

/// Protocol defining the interface for MMA data providers.
/// Implementations (e.g. Sherdog) fetch fight data from external sources.
protocol MMADataProvider {
    func loadImage(url: URL) async throws -> Data
    func loadRecord(fighter: Fighter, forceRefresh: Bool) async throws -> SherdogResponse<FighterRecord>
    func loadFights(event: Event, forceRefresh: Bool) async throws -> SherdogResponse<[Fight]>
    func getLastEvent(forceRefresh: Bool) async throws -> Event
    func getLastEventStats(forceRefresh: Bool) async throws -> SherdogResponse<EventStats>
    func getEventStats(event: Event, forceRefresh: Bool) async throws -> SherdogResponse<EventStats>
    func loadEvents(forceRefresh: Bool) async throws -> SherdogResponse<[Event]>
}

// MARK: - Environment Key

private struct MMADataProviderKey: EnvironmentKey {
    static let defaultValue: MMADataProvider = Sherdog.shared
}

extension EnvironmentValues {
    var mmaDataProvider: MMADataProvider {
        get { self[MMADataProviderKey.self] }
        set { self[MMADataProviderKey.self] = newValue }
    }
}
