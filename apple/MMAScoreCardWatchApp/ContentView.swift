//
//  ContentView.swift
//  MMAScoreCardWatch Watch App
//
//  Created by dvaca on 3/4/25.
//

import SwiftUI

struct ContentView: View {
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
            }
            
            if response?.data != nil || response?.timeCached != nil {
                Section("Metadata") {
                    LabeledContent("Cached at", value: response!.cachedAt!.ISO8601Format())
                    LabeledContent("Time cached", value: response!.timeCached!)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink(destination: AboutView()) {
                    Label("About", systemImage: "info")
                }
            }
//            ToolbarItemGroup(placement: .bottomBar) {
//                Spacer()
//                Text("\(filteredEvents.count) events")
//                Spacer()
//            }
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
        .overlay {
            if isFetching {
                ProgressView()
            }
        }
        .onAppear(perform: onAppear)
        .refreshable(action: onRefresh)
        .searchable(text: $searchText)
        .navigationTitle("Events")
    }
}

#Preview {
    NavigationStack {
        ContentView()
    }
}
