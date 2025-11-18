//
//  EventGraph.swift
//  MMAScoreCard
//
//  Created by dvaca on 6/4/25.
//

import SwiftUI

struct EventGraph : View {
    let event: Event
    @State private var isFetching: Bool = true
    @State private var error: Error? = nil
    @State var response: SherdogResponse<EventStats>? = nil
    
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
                response = try await Sheredog.getEventStats(event: event, forceRefresh: forceRefresh)
            } catch {
                self.error = error
            }
            isFetching = false
        }
    }
    
    private var totalFights: Int {
        guard let stats = response?.data else { return 0 }
        return stats.kos + stats.decisions + stats.submissions
    }
    
    var body: some View {
        listContent
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
            .navigationTitle(ProcessInfo.processInfo.operatingSystemVersion.majorVersion < 26 ? "Statistics" : event.name)
            .navigationBarTitleDisplayMode(.large)
    }
    
    @ViewBuilder
    private var listContent: some View {
        List {
            eventHeaderSection
            
            if let stats = response?.data {
                summarySection(stats: stats)
                finishTypesSection(stats: stats)
                percentageCardsSection(stats: stats)
            }
            
            metadataSection
        }
    }
    
    @ViewBuilder
    private var eventHeaderSection: some View {
        Section {
            VStack(spacing: 12) {
                Section {
                    VStack(spacing: 12) {
                        let version = ProcessInfo.processInfo.operatingSystemVersion
                        if version.majorVersion > 26 {
                            HStack {
                                Label("Event", systemImage: "rectangle.and.pencil.and.ellipsis")
                                Spacer()
                                Text(event.name)
                            }
                        }
                        HStack {
                            Label("Location", systemImage: "location.fill")
                            Spacer()
                            Text(event.location)
                        }
                        HStack {
                            Label("Date", systemImage: "calendar")
                            Spacer()
                            Text(event.date.formatted(date: .abbreviated, time: .omitted))
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func summarySection(stats: EventStats) -> some View {
        Section("Summary") {
            HStack(spacing: 20) {
                StatCard(
                    title: "Total Fights",
                    value: "\(totalFights)",
                    icon: "figure.boxing",
                    color: .orange
                )
                
                Divider()
                
                StatCard(
                    title: "Finishes",
                    value: "\(stats.kos + stats.submissions)",
                    icon: "bolt.fill",
                    color: .red
                )
            }
            .padding(.vertical, 8)
        }
    }
    
    @ViewBuilder
    private func finishTypesSection(stats: EventStats) -> some View {
        Section("Finish Types") {
            StatBar(
                title: "KO/TKO",
                value: stats.kos,
                total: totalFights,
                icon: "figure.martial.arts",
                color: .red
            )
            
            StatBar(
                title: "Submission",
                value: stats.submissions,
                total: totalFights,
                icon: "figure.fall",
                color: .green
            )
            
            StatBar(
                title: "Decision",
                value: stats.decisions,
                total: totalFights,
                icon: "list.bullet.clipboard",
                color: .blue
            )
        }
    }
    
    @ViewBuilder
    private func percentageCardsSection(stats: EventStats) -> some View {
        Section("Breakdown") {
            VStack(spacing: 12) {
                PercentageRow(
                    title: "KO/TKO",
                    value: stats.kos,
                    total: totalFights,
                    color: .red
                )
                
                PercentageRow(
                    title: "Submission",
                    value: stats.submissions,
                    total: totalFights,
                    color: .green
                )
                
                PercentageRow(
                    title: "Decision",
                    value: stats.decisions,
                    total: totalFights,
                    color: .blue
                )
            }
            .padding(.vertical, 4)
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
    
    @ViewBuilder
    private var loadingOverlay: some View {
        if isFetching && response == nil {
            ContentUnavailableView {
                ProgressView()
            } description: {
                Text("Loading statistics...")
            }
        }
    }
}

// MARK: - Supporting Views

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

fileprivate struct StatBar: View {
    let title: String
    let value: Int
    let total: Int
    let icon: String
    let color: Color
    
    private var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(value) / Double(total)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text("\(value)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(color)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * percentage, height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding(.vertical, 4)
    }
}

fileprivate struct PercentageRow: View {
    let title: String
    let value: Int
    let total: Int
    let color: Color
    
    private var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(value) / Double(total)
    }
    
    private var percentageString: String {
        String(format: "%.1f%%", percentage * 100)
    }
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.primary)
            
            Spacer()
            
            Text(percentageString)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(color)
                .frame(minWidth: 50, alignment: .trailing)
        }
    }
}

#Preview {
    NavigationView {
        EventGraph(event: Event(name: "UFC 313", fight: "Alex Pereira vs. Ankalaev", location: "Los Angeles", date: Date(), url: "https://www.sherdog.com/events/UFC-on-ESPN-64-Moreno-vs-Erceg-105790"))
    }
}
