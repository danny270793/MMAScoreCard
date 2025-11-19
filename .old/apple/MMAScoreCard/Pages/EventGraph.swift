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
        Section("Event") {
            let version = ProcessInfo.processInfo.operatingSystemVersion
            if version.majorVersion > 26 {
                InfoRow(
                    icon: "rectangle.and.pencil.and.ellipsis",
                    label: "Event",
                    value: event.name
                )
            }
            InfoRow(
                icon: "location.fill",
                label: "Location",
                value: event.location
            )
            InfoRow(
                icon: "calendar",
                label: "Date",
                value: event.date.formatted(date: .abbreviated, time: .omitted)
            )
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
        CacheMetadataSection(
            cachedAt: response?.cachedAt,
            timeCached: response?.timeCached
        )
    }
    
    @ViewBuilder
    private var loadingOverlay: some View {
        LoadingOverlay(
            isLoading: isFetching,
            isEmpty: response == nil,
            message: "Loading statistics..."
        )
    }
}

#Preview {
    NavigationView {
        EventGraph(event: Event(name: "UFC 313", fight: "Alex Pereira vs. Ankalaev", location: "Los Angeles", date: Date(), url: "https://www.sherdog.com/events/UFC-on-ESPN-64-Moreno-vs-Erceg-105790"))
    }
}
