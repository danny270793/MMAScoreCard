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
    @State var events: [Event] = []
    
    func onRefresh() {
        Task {
            isFetching = true
            do {
                events = try await Sheredog.loadEvents()
            } catch {
                self.error = error
            }
            isFetching = false
        }
    }
    
    private var filteredEvents: [Event] {
        if searchText.isEmpty {
            return events
        } else {
            return events.filter { event in
                event.name.lowercased().contains(searchText.lowercased()) ||
                event.date.ISO8601Format().lowercased().contains(searchText.lowercased()) ||
                (event.fight ?? "").lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List(filteredEvents) { event in
                NavigationLink(destination: FigthsList(event: event)) {
                    VStack {
                        Text(event.name.split(separator: "-")[0])
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if event.fight != nil {
                            Text(event.fight!)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Text(event.date.ISO8601Format().split(separator: "T")[0])
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Text("\(filteredEvents.count) events")
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
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear(perform: onRefresh)
            .refreshable(action: onRefresh)
            .searchable(text: $searchText)
            .navigationTitle("Events")
        }
    }
}

#Preview {
    EventsList()
}
