//
//  FightsList.swift
//  MMAScoreCard
//
//  Created by dvaca on 23/3/25.
//

import SwiftUI
import SwiftData

struct FigthsList: View {
    let event: Event
    
    @State private var isFetching: Bool = true
    @State private var error: Error? = nil
    @State private var searchText = ""
    @State var response: SherdogResponse<[Fight]>? = nil
    
    func onAppear() {
        Task {
            await loadFights(forceRefresh: false)
        }
    }
    
    func onRefresh() {
        Task {
            await loadFights(forceRefresh: true)
        }
    }
    
    func loadFights(forceRefresh: Bool) async {
        Task {
            isFetching = true
            do {
                response = try await Sheredog.loadFights(event: event, forceRefresh: forceRefresh)
            } catch {
                self.error = error
            }
            isFetching = false
        }
    }
    
    private var filteredFights: [Fight] {
        if response == nil {
            return []
        }
        
        let fights: [Fight]
        if searchText.isEmpty {
            fights = response!.data
        } else {
            fights = response!.data.filter { fight in
                fight.figther1.name.lowercased().contains(searchText.lowercased()) ||
                fight.figther2.name.lowercased().contains(searchText.lowercased()) ||
                fight.division.lowercased().contains(searchText.lowercased()) ||
                
                fight.result.lowercased().contains(searchText.lowercased())
            }
        }
        
        // Sort by position (original order from API represents fight card order)
        // Fights appear in order from main event (1) to prelims (higher numbers)
        return fights
    }
    
    private var sortedFights: [(Int, Fight)] {
        // Create tuples with position and fight, maintaining the original order
        // Position 1 = main event, higher positions = prelims
        return filteredFights.enumerated().map { ($0.offset + 1, $0.element) }
    }
    
    private var hasCompletedFights: Bool {
        response?.data.filter { $0.fightStatus == .done }.isEmpty == false
    }
    
    var body: some View {
        listContent
            .toolbar {
                toolbarContent
            }
            .overlay {
                loadingOverlay
            }
            .alert(String(localized: "common.error"), isPresented: .constant(error != nil)) {
                Button(String(localized: "common.ok")) {
                    error = nil
                }
            } message: {
                if let error = error {
                    Text(error.localizedDescription)
                }
            }
            .onAppear(perform: onAppear)
            .refreshable(action: onRefresh)
            .searchable(text: $searchText, prompt: String(localized: "fights.search_prompt"))
            .navigationTitle(event.name)
            .navigationBarTitleDisplayMode(.large)
    }
    
    @ViewBuilder
    private var listContent: some View {
        List {
            eventHeaderSection
            
            if filteredFights.isEmpty && !isFetching {
                emptyStateView
            } else {
                fightsSection
            }
            
            metadataSection
        }
    }
    
    @ViewBuilder
    private var eventHeaderSection: some View {
        Section(String(localized: "fights.event_info")) {
            HStack {
                Label(String(localized: "fights.location"), systemImage: "location.fill")
                Spacer()
                Text(event.location)
                    .foregroundStyle(.secondary)
            }
            HStack {
                Label(String(localized: "fights.date"), systemImage: "calendar")
                Spacer()
                Text(event.date.formatted(date: .abbreviated, time: .omitted))
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        ContentUnavailableView(
            String(localized: "fights.no_fights_title"),
            systemImage: "figure.boxing",
            description: Text(String(localized: "fights.no_fights_description"))
        )
    }
    
    @ViewBuilder
    private var fightsSection: some View {
        Section(String(localized: "fights.fight_card")) {
            ForEach(sortedFights, id: \.1.id) { positionedFight in
                fightRow(for: positionedFight.1, position: positionedFight.0)
            }
        }
    }
    
    @ViewBuilder
    private func fightRow(for fight: Fight, position: Int) -> some View {
        NavigationLink(destination: FigthDetails(event: event, fight: fight)) {
            FightRow(fight: fight, position: position)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            shareButton(for: fight)
        }
        .contextMenu {
            contextMenuItems(for: fight)
        } preview: {
            NavigationStack {
                FigthDetails(event: event, fight: fight)
            }
        }
    }
    
    @ViewBuilder
    private func shareButton(for fight: Fight) -> some View {
        ShareSwipeButton(text: "I'm viewing \"\(fight.figther1.name) vs \(fight.figther2.name)\"")
    }
    
    @ViewBuilder
    private func contextMenuItems(for fight: Fight) -> some View {
        ShareContextMenuItem(text: "I'm viewing \"\(fight.figther1.name) vs \(fight.figther2.name)\"")
    }
    
    @ViewBuilder
    private var metadataSection: some View {
        CacheMetadataSection(
            cachedAt: response?.cachedAt,
            timeCached: response?.timeCached
        )
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            if hasCompletedFights {
                NavigationLink(destination: EventGraph(event: event)) {
                    Label(String(localized: "nav.statistics"), systemImage: "chart.xyaxis.line")
                }
            }
        }

        let version = ProcessInfo.processInfo.operatingSystemVersion
        if version.majorVersion < 26 {
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Label("\(filteredFights.count)", systemImage: "figure.boxing")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Spacer()

                    
                    let completed = response?.data.filter { $0.fightStatus == .done }.count ?? 0
                    let total = response?.data.count ?? 0
                    
                    Text("\(completed)/\(total) completed")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        
    }
    
    @ViewBuilder
    private var loadingOverlay: some View {
        LoadingOverlay(
            isLoading: isFetching,
            isEmpty: filteredFights.isEmpty,
            message: String(localized: "common.loading")
        )
    }
}

// MARK: - Fight Row Component
fileprivate struct FightRow: View {
    let fight: Fight
    let position: Int
    
    private var resultStyle: FightResultStyle {
        FightResultStyle(result: fight.result)
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: resultStyle.icon)
                .font(.subheadline)
                .foregroundStyle(resultStyle.color)
            
            VStack(alignment: .leading, spacing: 6) {
                // Fighters
                HStack(spacing: 6) {
                    Text(fight.figther1.name)
                        .font(.headline)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    Text(String(localized: "fights.vs"))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Spacer(minLength: 0)
                    Text(fight.figther2.name)
                        .font(.headline)
                        .lineLimit(1)
                }
                
                HStack(spacing: 8) {
                    // Division
                    Text(fight.division)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if resultStyle.hasResult {
                        Text("R\(fight.round) • \(fight.time)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                }
                
                // Result (if completed)
                if fight.fightStatus == .done {
                    HStack(spacing: 8) {
                        Text(fight.result)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
    }
}

#Preview("Done") {
    NavigationView {
        FigthsList(event: Event(name: "UFC 313", fight: "Alex Pereira vs. Ankalaev", location: "Los Angeles", date: Date(), url: "https://www.sherdog.com/events/UFC-on-ESPN-64-Moreno-vs-Erceg-105790"))
    }
}

#Preview("Pending") {
    NavigationView {
        FigthsList(event: Event(name: "UFC 323", fight: "Dvalishvili vs. Yan", location: "T-MOBILE ARENA, LAS VEGAS, NEVADA, UNITED STATES", date: Date(), url: "https://www.sherdog.com/events/UFC-323-Dvalishvili-vs-Yan-2-109392"))
    }
}
