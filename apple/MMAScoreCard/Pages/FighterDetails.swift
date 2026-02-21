//
//  FighterDetails.swift
//  MMAScoreCard
//
//  Created by dvaca on 24/3/25.
//

import SwiftUI
import SwiftData

struct FighterDetails: View {
    @Environment(\.mmaDataProvider) private var dataProvider
    let figther: Fighter
    @State private var isFetching: Bool = true
    @State private var error: Error? = nil
    @State private var searchText = ""
    @State private var response: SherdogResponse<FighterRecord>? = nil
    
    func onAppear() {
        Task {
            await loadRecord(forceRefresh: false)
        }
    }
    
    func onRefresh() {
        Task {
            await loadRecord(forceRefresh: true)
        }
    }
    
    func loadRecord(forceRefresh: Bool) async {
        Task {
            isFetching = true
            do {
                response = try await dataProvider.loadRecord(fighter: figther, forceRefresh: forceRefresh)
            } catch {
                self.error = error
            }
            isFetching = false
        }
    }
    
    private var filteredFights: [Record] {
        if response == nil {
            return []
        }
        
        if searchText.isEmpty {
            return response!.data.fights
        } else {
            return response!.data.fights.filter { fight in
                fight.figther.lowercased().contains(searchText.lowercased()) ||
                fight.status.rawValue.lowercased().contains(searchText.lowercased()) ||
                fight.method.lowercased().contains(searchText.lowercased()) ||
                fight.round.lowercased().contains(searchText.lowercased()) ||
                fight.time.lowercased().contains(searchText.lowercased()) ||
                (fight.referee != nil && fight.referee!.lowercased().contains(searchText.lowercased()))
            }
        }
    }
    
    private var wins: Int {
        response?.data.fights.filter { $0.status == .win }.count ?? 0
    }
    
    private var losses: Int {
        response?.data.fights.filter { $0.status == .loss }.count ?? 0
    }
    
    private var draws: Int {
        response?.data.fights.filter { $0.status == .draw }.count ?? 0
    }
    
    private var ncs: Int {
        response?.data.fights.filter { $0.status == .nc }.count ?? 0
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
            .searchable(text: $searchText, prompt: "Search fights")
            .navigationTitle(figther.name)
            .navigationBarTitleDisplayMode(.large)
    }
    
    @ViewBuilder
    private var listContent: some View {
        List {
            if let data = response?.data {
                fighterInfoSection(data: data)
                Section("Record") {
                    HStack {
                        Spacer()
                        RecordBadge(label: "W", value: wins, color: .green)
                        RecordBadge(label: "L", value: losses, color: .red)
                        RecordBadge(label: "D", value: draws, color: .orange)
                        if ncs > 0 {
                            RecordBadge(label: "NC", value: ncs, color: .gray)
                        }
                        Spacer()
                    }
                }
                fightHistorySection
            }
            
            metadataSection
        }
    }
    
    @ViewBuilder
    private func fighterInfoSection(data: FighterRecord) -> some View {
        Section("Resume"){
            // Fighter Details
            InfoRow(icon: "flag.fill", label: "Nationality", value: data.nationality)
            InfoRow(icon: "calendar", label: "Age", value: data.age)
            InfoRow(icon: "ruler.fill", label: "Height", value: data.height)
            InfoRow(icon: "scalemass.fill", label: "Weight", value: data.weight)
        }
    }
    
    @ViewBuilder
    private var fightHistorySection: some View {
        if !filteredFights.isEmpty {
            Section("Fight History") {
                ForEach(filteredFights) { fight in
                    FightHistoryRow(fight: fight)
                }
            }
        }
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
            if !filteredFights.isEmpty {
                NavigationLink(destination: FighterCareer(fighter: figther, fights: response?.data.fights ?? [])) {
                    Label("Statistics", systemImage: "chart.xyaxis.line")
                }
            }
        }
        
//        ToolbarItem(placement: .bottomBar) {
//            HStack {
//                Label("\(filteredFights.count)", systemImage: "figure.boxing")
//                    .font(.subheadline)
//                    .foregroundStyle(.secondary)
//                
//                Spacer()
//                
//                if wins + losses + draws > 0 {
//                    Text("Record: \(wins)-\(losses)-\(draws)")
//                        .font(.caption)
//                        .foregroundStyle(.tertiary)
//                }
//            }
//        }
    }
    
    @ViewBuilder
    private var loadingOverlay: some View {
        LoadingOverlay(
            isLoading: isFetching,
            isEmpty: response == nil,
            message: "Loading fighter record..."
        )
    }
}

// MARK: - Supporting Views

fileprivate struct FightHistoryRow: View {
    let fight: Record
    
    private var resultStyle: FightResultStyle {
        FightResultStyle(result: fight.method)
    }
    
    private var statusColor: Color {
        switch fight.status {
        case .win: return .green
        case .loss: return .red
        case .draw: return .orange
        case .nc: return .gray
        case .pending: return .gray
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Status Badge
                Image(systemName: resultStyle.icon)
                    .font(.title3)
                    .foregroundStyle(statusColor)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    // Opponent
                    Text("vs \(fight.figther)")
                        .font(.headline)
                    
                    // Result
                    HStack(spacing: 4) {
                        Text(fight.status.rawValue)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(statusColor)
                            )
                        
                        Text("by \(fight.method)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
            }
            
            // Referee if available
            if let referee = fight.referee {
                Label("Ref: \(referee) R\(fight.round) • \(fight.time)", systemImage: "person.fill.checkmark")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            
            // Event and Date
            HStack {
                Text(fight.event)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text(fight.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationView {
        FighterDetails(figther: Fighter(name: "Merab Dvalishvili", image: URL(string: "https://www.sherdog.com/image_crop/44/44/_images/fighter/1648844898903_20220401042811_Merab_Dvalishvili_ff.JPG")!, link: URL(string: "https://www.sherdog.com/fighter/Islam-Makhachev-76836")!))
    }
}
