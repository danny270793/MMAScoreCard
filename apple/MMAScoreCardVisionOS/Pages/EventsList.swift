//
//  ContentView.swift
//  MMAScoreCard
//
//  Created by dvaca on 23/3/25.
//

import SwiftUI
import SwiftData

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
    
    var body: some View {
        List {
            ForEach(filteredEvents) { event in
                NavigationLink(destination: FigthsList(event: event)) {
                    VStack {
                        Text(event.name)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if event.fight != nil {
                            Text(event.fight!)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Text(event.date.ISO8601Format().split(separator: "T")[0])
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .contextMenu {
                        Button(action: {
//                            Sharing.shareText(text: "I'm viewing \"\(event.name)\"\nSee more information at: \(event.url)")
                        }) {
                            Text("Share")
                            Image(systemName: "square.and.arrow.up")
                        }
                    } preview: {
                        NavigationStack {
                            FigthsList(event: event)
                        }
                    }
                }
            }
            
            if response?.data != nil || response?.timeCached != nil {
                Section("Metadata") {
                    LabeledContent("Cached at", value: response!.cachedAt!.ISO8601Format())
                    LabeledContent("Time cached", value: response!.timeCached!)
                }
            }
        }
        .toolbar {
//            ToolbarItem(placement: .secondaryAction) {
//                Menu {
//                    Picker(selection: $filter, label: Text("Filter options")) {
//                        Text("Past").tag(FilterOptions.past)
//                        Text("Upcoming").tag(FilterOptions.upcoming)
//                        Text("All").tag(FilterOptions.all)
//                    }
//                } label: {
//                    Label("Filter", systemImage: "arrow.up.arrow.down")
//                }
//            }
            ToolbarItem(placement: .secondaryAction) {
                Button(action: {
                    if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(appSettings)
                    }
                }) {
                    Label("Settings", systemImage: "gear")
                    
                }
            }
            ToolbarItem(placement: .secondaryAction) {
                NavigationLink(destination: AboutView()) {
                    Label("About", systemImage: "info")
                }
            }
            
            ToolbarItemGroup(placement: .bottomBar) {
                Menu {
                    Picker(selection: $filter, label: Text("Filter options")) {
                        Text("Past").tag(FilterOptions.past)
                        Text("Upcoming").tag(FilterOptions.upcoming)
                        Text("All").tag(FilterOptions.all)
                    }
                } label: {
                    Label("Filter", systemImage: "arrow.up.arrow.down")
                }
                Spacer()
                Text("\(filteredEvents.count) events")
                Spacer()
            }
        }
        .overlay {
            if isFetching {
                ProgressView()
            }
        }
        .alert(isPresented: .constant(error != nil)) {
            Alert(
                title: Text("Error"),
                message: Text(error!.localizedDescription),
                dismissButton: .default(Text("OK")) {
                    error = nil
                }
            )
        }
        .onAppear(perform: onAppear)
        .refreshable(action: onRefresh)
        .searchable(text: $searchText)
        .navigationTitle("Events")
    }
}

#Preview {
    NavigationStack {
        EventsList()
    }
}
