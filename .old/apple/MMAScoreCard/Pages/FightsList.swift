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
            .alert("Error", isPresented: .constant(error != nil)) {
                Button("OK") {
                    error = nil
                }
            } message: {
                if let error = error {
                    Text(error.localizedDescription)
                }
            }
            .onAppear(perform: onAppear)
            .refreshable(action: onRefresh)
            .searchable(text: $searchText, prompt: "Search fighters or divisions")
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
        Section("Event Information") {
            HStack {
                Label("Location", systemImage: "location.fill")
                Spacer()
                Text(event.location)
                    .foregroundStyle(.secondary)
            }
            HStack {
                Label("Date", systemImage: "calendar")
                Spacer()
                Text(event.date.formatted(date: .abbreviated, time: .omitted))
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        ContentUnavailableView(
            "No Fights",
            systemImage: "figure.boxing",
            description: Text("No fights found for the selected search")
        )
    }
    
    @ViewBuilder
    private var fightsSection: some View {
        Section("Fight Card") {
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
        Button(action: {
            Sharing.shareText(text: "I'm viewing \"\(fight.figther1.name) vs \(fight.figther2.name)\"")
        }) {
            Label("Share", systemImage: "square.and.arrow.up")
        }
        .tint(.blue)
    }
    
    @ViewBuilder
    private func contextMenuItems(for fight: Fight) -> some View {
        Button(action: {
            Sharing.shareText(text: "I'm viewing \"\(fight.figther1.name) vs \(fight.figther2.name)\"")
        }) {
            Label("Share", systemImage: "square.and.arrow.up")
        }
    }
    
    @ViewBuilder
    private var metadataSection: some View {
        if let cachedAt = response?.cachedAt, let timeCached = response?.timeCached {
            Section {
                LabeledContent {
                    Text(cachedAt.formatted(date: .abbreviated, time: .shortened))
                        .foregroundStyle(.secondary)
                } label: {
                    Label("Cached", systemImage: "clock.arrow.circlepath")
                }
                
                LabeledContent {
                    Text(timeCached)
                        .foregroundStyle(.secondary)
                } label: {
                    Label("Cache Time", systemImage: "timer")
                }
            } header: {
                Text("Cache Info")
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            if hasCompletedFights {
                NavigationLink(destination: EventGraph(event: event)) {
                    Label("Statistics", systemImage: "chart.xyaxis.line")
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
        if isFetching && filteredFights.isEmpty {
            ContentUnavailableView {
                ProgressView()
            } description: {
                Text("Loading fights...")
            }
        }
    }
}

// MARK: - Fight Row Component
fileprivate struct FightRow: View {
    let fight: Fight
    let position: Int
    
    private var resultIcon: String {
        let result = fight.result.uppercased()
        if result.hasPrefix("KO") || result.hasPrefix("TKO") {
            return "figure.martial.arts"
        } else if result.contains("DECISION") || result.contains("DEC") {
            return "list.bullet.clipboard"
        } else if result.contains("SUBMISSION") || result.contains("SUB") {
            return "figure.fall"
        } else if result.contains("NO CONTEST") || result.contains("NC") {
            return "nosign"
        } else {
            return "clock.badge"
        }
    }
    
    private var hasResult: Bool {
        let result = fight.result.uppercased()
        if result.hasPrefix("KO") || result.hasPrefix("TKO") {
            return true
        } else if result.contains("DECISION") || result.contains("DEC") {
            return true
        } else if result.contains("SUBMISSION") || result.contains("SUB") {
            return true
        } else if result.contains("NO CONTEST") || result.contains("NC") {
            return false
        } else {
            return false
        }
    }
    
    private var resultColor: Color {
        let result = fight.result.uppercased()
        if result.hasPrefix("KO") || result.hasPrefix("TKO") {
            return .red
        } else if result.contains("DECISION") || result.contains("DEC") {
            return .blue
        } else if result.contains("SUBMISSION") || result.contains("SUB") {
            return .green
        } else if result.contains("NO CONTEST") || result.contains("NC") {
            return .primary
        } else {
            return .orange
        }
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: resultIcon)
                .font(.subheadline)
                .foregroundStyle(resultColor)
            
            VStack(alignment: .leading, spacing: 6) {
                // Fighters
                HStack(spacing: 6) {
                    Text(fight.figther1.name)
                        .font(.headline)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    Text("vs")
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
                    if hasResult {
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
