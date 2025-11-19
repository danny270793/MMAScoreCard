//
//  ContentView.swift
//  MMAScoreCard
//
//  Created by dvaca on 23/3/25.
//

import SwiftUI
import SwiftData
import WidgetKit

struct EventsList: View {
    @State private var isFetching: Bool = true
    @State private var error: Error? = nil
    @State private var searchText = ""
    @State var response: SherdogResponse<[Event]>? = nil
    @State private var filter = FilterOptions.all
    
    func onAppear() {
        Task {
            await loadEvents(forceRefresh: false)
        }
    }
    
    func onRefresh() {
        Task {
            await loadEvents(forceRefresh: true)
        }
    }
    
    func loadEvents(forceRefresh: Bool) async {
        isFetching = true
        do {
            response = try await Sheredog.loadEvents(forceRefresh: forceRefresh)
            WidgetCenter.shared.reloadTimelines(ofKind: "LastEventStatsWidget")
        } catch {
            self.error = error
        }
        isFetching = false
    }
    
    private var filteredEvents: [Event] {
        if response == nil {
            return []
        }
        
        var preFilteredEvents: [Event] = []
        switch filter {
        case FilterOptions.all: preFilteredEvents = response!.data
        case FilterOptions.upcoming: preFilteredEvents = response!.data.filter { event in event.date > Date.now}
        case FilterOptions.past: preFilteredEvents = response!.data.filter { event in event.date <= Date.now}
        }
            
        if searchText.isEmpty {
            return preFilteredEvents
        } else {
            return preFilteredEvents.filter { event in
                event.name.lowercased().contains(searchText.lowercased()) ||
                event.date.ISO8601Format().lowercased().contains(searchText.lowercased()) ||
                (event.fight ?? "").lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    private var groupedEvents: [(String, [Event])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredEvents) { event -> String in
            let components = calendar.dateComponents([.year, .month], from: event.date)
            let monthDate = calendar.date(from: components) ?? event.date
            return monthDate.formatted(.dateTime.year().month(.wide))
        }
        
        // Create tuples with both the string key and actual date for proper sorting
        let groupedWithDates = grouped.map { (key, events) -> (String, Date, [Event]) in
            let components = calendar.dateComponents([.year, .month], from: events.first!.date)
            let monthDate = calendar.date(from: components) ?? events.first!.date
            // Sort events within each group by newest first
            let sortedEvents = events.sorted { $0.date > $1.date }
            return (key, monthDate, sortedEvents)
        }
        
        // Always sort by newest first (descending order)
        let sorted = groupedWithDates.sorted { $0.1 > $1.1 }
        
        // Return without the date, just the string key and events
        return sorted.map { ($0.0, $0.2) }
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
            .searchable(text: $searchText, prompt: String(localized: "events.search_prompt"))
            .navigationTitle(String(localized: "events.title"))
    }
    
    @ViewBuilder
    private var listContent: some View {
        List {
            if filteredEvents.isEmpty && !isFetching {
                emptyStateView
            } else {
                eventSections
                metadataSection
            }
        }
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        ContentUnavailableView(
            String(localized: "events.no_events_title"),
            systemImage: "calendar.badge.exclamationmark",
            description: Text(String(localized: "events.no_events_description"))
        )
    }
    
    @ViewBuilder
    private var eventSections: some View {
        ForEach(groupedEvents, id: \.0) { month, events in
            Section(month) {
                ForEach(events) { event in
                    eventRow(for: event)
                }
            }
        }
    }
    
    @ViewBuilder
    private func eventRow(for event: Event) -> some View {
                NavigationLink(destination: FigthsList(event: event)) {
            EventRow(event: event)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            shareButton(for: event)
                    }
                    .contextMenu {
            contextMenuItems(for: event)
                    } preview: {
                        NavigationStack {
                            FigthsList(event: event)
                        }
                    }
                }
    
    @ViewBuilder
    private func shareButton(for event: Event) -> some View {
        ShareSwipeButton(text: "I'm viewing \"\(event.name)\"\nSee more information at: \(event.url)")
    }
    
    @ViewBuilder
    private func contextMenuItems(for event: Event) -> some View {
        ShareContextMenuItem(text: "I'm viewing \"\(event.name)\"\nSee more information at: \(event.url)")
        
        Button(action: { openURL(event.url) }) {
            Label(String(localized: "common.open_safari"), systemImage: "safari")
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
            Menu {
                Menu {
                    Button(action: { filter = .all }) {
                        Label(String(localized: "filter.all"), systemImage: filter == .all ? "checkmark" : "list.bullet")
                    }
                    
                    Button(action: { filter = .upcoming }) {
                        Label(String(localized: "filter.upcoming"), systemImage: filter == .upcoming ? "checkmark" : "calendar.badge.clock")
                    }
                    
                    Button(action: { filter = .past }) {
                        Label(String(localized: "filter.past"), systemImage: filter == .past ? "checkmark" : "clock.arrow.circlepath")
                    }
                } label: {
                    Label(String(localized: "filter.title"), systemImage: "line.3.horizontal.decrease.circle")
                }
                
                Divider()
                
                NavigationLink(destination: AboutView()) {
                    Label(String(localized: "nav.about"), systemImage: "info.circle")
                }
                
                Button(action: openAppSettings) {
                    Label(String(localized: "nav.settings"), systemImage: "gear")
                }
            } label: {
                Label("More", systemImage: "ellipsis.circle")
            }
        }
    }
    
    @ViewBuilder
    private var loadingOverlay: some View {
        LoadingOverlay(
            isLoading: isFetching,
            isEmpty: filteredEvents.isEmpty,
            message: String(localized: "common.loading")
        )
    }
}

// MARK: - Event Row Component
fileprivate struct EventRow: View {
    let event: Event
    
    private var isUpcoming: Bool {
        event.date > Date.now
    }
    
    private var daysUntil: Int? {
        guard isUpcoming else { return nil }
        return Calendar.current.dateComponents([.day], from: Date.now, to: event.date).day
    }
    
    private func parseFighters(from fight: String) -> (fighter1: String, fighter2: String)? {
        let separators = [" vs. ", " vs ", " VS ", " VS. "]
        for separator in separators {
            let components = fight.components(separatedBy: separator)
            if components.count == 2 {
                return (components[0].trimmingCharacters(in: .whitespaces),
                        components[1].trimmingCharacters(in: .whitespaces))
            }
        }
        return nil
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Date Badge
            VStack(spacing: 2) {
                Text(event.date.formatted(.dateTime.day()))
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(isUpcoming ? .red : .primary)
                
                Text(event.date.formatted(.dateTime.month(.abbreviated)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
            }
            .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                // Event Name
                Text(event.name)
                    .font(.headline)
                    .lineLimit(2)
                
                // Location and Status
                HStack(spacing: 8) {
                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    
                    Text(event.location)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    
                    if let days = daysUntil {
                        Text("•")
                            .foregroundStyle(.secondary)
                        
                        if days == 0 {
                            Text(String(localized: "events.status.today"))
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.red)
                        } else if days == 1 {
                            Text(String(localized: "events.status.tomorrow"))
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.orange)
                        } else {
                            Text(String(format: String(localized: "events.status.in_days"), days))
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.orange)
                        }
                    }
                }

                // Main Fight
                if let fight = event.fight {
                    HStack(alignment: .top, spacing: 6) {
                        Image(systemName: "figure.boxing")
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.top, 2)
                        
                            if let fighters = parseFighters(from: fight) {
                                Text(fighters.fighter1)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                
                                HStack(spacing: 4) {
                                    Text(String(localized: "fights.vs"))
                                        .font(.caption2)
                                        .foregroundStyle(.tertiary)
                                    
                                    Text(fighters.fighter2)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            } else {
                                Text(fight)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        EventsList()
    }
}
