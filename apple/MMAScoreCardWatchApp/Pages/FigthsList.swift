//
//  FigthsList.swift
//  MMAScoreCard
//
//  Created by dvaca on 3/4/25.
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
        
        if searchText.isEmpty {
            return response!.data
        } else {
            return response!.data.filter { fight in
                fight.figther1.name.lowercased().contains(searchText.lowercased()) ||
                fight.figther2.name.lowercased().contains(searchText.lowercased()) ||
                fight.division.lowercased().contains(searchText.lowercased()) ||
                fight.result.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        List {
            Section(header: Text("Event")) {
                LabeledContent("Name", value: event.name)
                LabeledContent("Location", value: event.location)
                LabeledContent("Date", value: event.date.ISO8601Format().split(separator: "T")[0])
            }
            Section(header: Text("Fights")) {
                ForEach(filteredFights) { fight in
                    NavigationLink(destination: FigthDetails(event: event, fight: fight)) {
                        VStack {
                            Text("\(fight.figther1.name) vs \(fight.figther2.name)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            if FightStatus.done == fight.fightStatus {
                                Text("\(fight.result)")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("Round \(fight.round) at \(fight.time)")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            Text("\(fight.division)")
                                .frame(maxWidth: .infinity, alignment: .leading)
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
        .navigationTitle(event.name)
    }
}

#Preview {
    NavigationView {
        FigthsList(event: Event(name: "UFC 313", fight: "Alex Pereira vs. Ankalaev", location: "Los Angeles", date: Date(), url: "https://www.sherdog.com/events/UFC-on-ESPN-64-Moreno-vs-Erceg-105790"))
    }
}
