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
    @State private var filter = FilterOptions.past
    
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
            .searchable(text: $searchText, prompt: "Search events")
            .navigationTitle("Events")
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
            "No Events",
            systemImage: "calendar.badge.exclamationmark",
            description: Text("No events found for the selected filter")
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
        Button(action: {
            Sharing.shareText(text: "I'm viewing \"\(event.name)\"\nSee more information at: \(event.url)")
        }) {
            Label("Share", systemImage: "square.and.arrow.up")
        }
        .tint(.blue)
    }
    
    @ViewBuilder
    private func contextMenuItems(for event: Event) -> some View {
        Button(action: {
            Sharing.shareText(text: "I'm viewing \"\(event.name)\"\nSee more information at: \(event.url)")
        }) {
            Label("Share", systemImage: "square.and.arrow.up")
        }
        
        Button(action: {
            if let url = URL(string: event.url) {
                UIApplication.shared.open(url)
            }
        }) {
            Label("Open in Safari", systemImage: "safari")
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
            Menu {
                Picker("Filter", selection: $filter) {
                    Label("Past Events", systemImage: "clock.arrow.circlepath")
                        .tag(FilterOptions.past)
                    Label("Upcoming Events", systemImage: "calendar.badge.clock")
                        .tag(FilterOptions.upcoming)
                    Label("All Events", systemImage: "list.bullet")
                        .tag(FilterOptions.all)
                }
                
                Divider()
                
                NavigationLink(destination: AboutView()) {
                    Label("About", systemImage: "info.circle")
                }
                
                Button(action: {
                    if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(appSettings)
                    }
                }) {
                    Label("Settings", systemImage: "gear")
                }
            } label: {
                Label("More", systemImage: "ellipsis.circle")
            }
        }
    }
    
    @ViewBuilder
    private var loadingOverlay: some View {
        if isFetching && filteredEvents.isEmpty {
            ContentUnavailableView {
                ProgressView()
            } description: {
                Text("Loading events...")
            }
        }
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
        HStack(alignment: .top, spacing: 12) {
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
                    
                    if let days = daysUntil, days <= 7 {
                        Text("•")
                            .foregroundStyle(.secondary)
                        
                        if days == 0 {
                            Text("Today")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.red)
                        } else if days == 1 {
                            Text("Tomorrow")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.orange)
                        } else {
                            Text("In \(days)d")
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
                        
                        VStack(alignment: .leading, spacing: 2) {
                            if let fighters = parseFighters(from: fight) {
                                Text(fighters.fighter1)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                
                                HStack(spacing: 4) {
                                    Text("vs")
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
            
            Spacer(minLength: 0)
            
            // Upcoming Badge
            if isUpcoming {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
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
