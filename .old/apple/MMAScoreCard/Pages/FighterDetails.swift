//
//  FighterDetails.swift
//  MMAScoreCard
//
//  Created by dvaca on 24/3/25.
//

import SwiftUI
import SwiftData

struct FighterDetails: View {
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
                response = try await Sheredog.loadRecord(fighter: figther, forceRefresh: forceRefresh)
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
                recordSection
                fightHistorySection
            }
            
            metadataSection
        }
    }
    
    @ViewBuilder
    private func fighterInfoSection(data: FighterRecord) -> some View {
        Section("Resume"){
            // Fighter Details
            VStack(spacing: 12) {
                InfoRow(icon: "flag.fill", label: "Nationality", value: data.nationality)
                InfoRow(icon: "calendar", label: "Age", value: data.age)
                InfoRow(icon: "ruler.fill", label: "Height", value: data.height)
                InfoRow(icon: "scalemass.fill", label: "Weight", value: data.weight)
            }
        }
    }
    
    @ViewBuilder
    private var recordSection: some View {
        Section("Career Statistics") {
            VStack {
                // Record Display
                HStack(spacing: 16) {
                    RecordBadge(label: "W", value: wins, color: .green)
                    RecordBadge(label: "L", value: losses, color: .red)
                    RecordBadge(label: "D", value: draws, color: .orange)
                    if ncs > 0 {
                        RecordBadge(label: "NC", value: ncs, color: .gray)
                    }
                }
                .padding(.bottom, 8)
                
                HStack(spacing: 20) {
                    StatCard(
                        title: "Total Fights",
                        value: "\(filteredFights.count)",
                        icon: "figure.boxing",
                        color: .blue
                    )
                    
                    Divider()
                    
                    StatCard(
                        title: "Win Rate",
                        value: winRateString,
                        icon: "trophy.fill",
                        color: .green
                    )
                }
                .padding(.vertical, 8)
            }.padding(.top, 8)
        }
    }
    
    private var winRateString: String {
        let total = wins + losses + draws
        guard total > 0 else { return "0%" }
        let rate = Double(wins) / Double(total) * 100
        return String(format: "%.0f%%", rate)
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
        ToolbarItem(placement: .bottomBar) {
            HStack {
                Label("\(filteredFights.count)", systemImage: "figure.boxing")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                if wins + losses + draws > 0 {
                    Text("Record: \(wins)-\(losses)-\(draws)")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }
    
    @ViewBuilder
    private var loadingOverlay: some View {
        if isFetching && response == nil {
            ContentUnavailableView {
                ProgressView()
            } description: {
                Text("Loading fighter record...")
            }
        }
    }
}

// MARK: - Supporting Views

fileprivate struct RecordBadge: View {
    let label: String
    let value: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundStyle(color)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(minWidth: 50)
    }
}

fileprivate struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.blue)
                .frame(width: 24)
            
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
        }
    }
}

fileprivate struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundStyle(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

fileprivate struct FightHistoryRow: View {
    let fight: Record
    
    private var resultColor: Color {
        switch fight.status {
        case .win: return .green
        case .loss: return .red
        case .draw: return .orange
        case .nc: return .gray
        case .pending: return .gray
        }
    }
    
    private var methodIcon: String {
        let method = fight.method.uppercased()
        if method.contains("KO") || method.contains("TKO") {
            return "figure.martial.arts"
        } else if method.contains("DECISION") || method.contains("DEC") {
            return "list.bullet.clipboard"
        } else if method.contains("SUBMISSION") || method.contains("SUB") {
            return "figure.fall"
        } else {
            return "checkmark.circle.fill"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Status Badge
                Image(systemName: methodIcon)
                    .font(.title3)
                    .foregroundStyle(resultColor)
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
                                    .fill(resultColor)
                            )
                        
                        Text("by \(fight.method)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
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
            
            // Fight Details
            HStack(spacing: 16) {
                Label("R\(fight.round)", systemImage: "number.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Label(fight.time, systemImage: "clock.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Referee if available
            if let referee = fight.referee {
                Label("Ref: \(referee)", systemImage: "person.fill.checkmark")
                    .font(.caption2)
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
