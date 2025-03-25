//
//  FightsList.swift
//  MMAScoreCard
//
//  Created by dvaca on 23/3/25.
//

import SwiftUI
import SwiftData

struct FigthsList: View {
    @Environment(\.modelContext) private var context
    
    let event: Event
    
    @State private var isFetching: Bool = true
    @State private var error: Error? = nil
    @State private var searchText = ""
    @Query(sort: \Fight.position, order: .reverse) var fights: [Fight]
    
    func onRefresh() {
        Task {
            isFetching = true
            do {
                print("deleting old \(fights.count) fights")
                for fight in fights {
                    context.delete(fight)
                }
                
                let newFights = try await Sheredog.loadFights(event: event)
                
                print("inserting new \(newFights.count) fights")
                for fight in newFights {
                    context.insert(fight)
                }
                
                print("saving to database")
                try context.save()
            } catch {
                self.error = error
            }
            isFetching = false
        }
    }
    
    private var filteredFights: [Fight] {
        if searchText.isEmpty {
            return fights
        } else {
            return fights.filter { event in
                event.figther1.name.lowercased().contains(searchText.lowercased()) ||
                event.figther2.name.lowercased().contains(searchText.lowercased()) ||
                event.division.lowercased().contains(searchText.lowercased()) ||
                event.result.lowercased().contains(searchText.lowercased())
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
                            if FightStatus.done.rawValue == fight.fightStatus {
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
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Text("\(filteredFights.count) Fights")
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
        .navigationTitle(event.name)
    }
}

#Preview {
    NavigationView {
        FigthsList(event: Event(name: "UFC 313", fight: "Alex Pereira vs. Ankalaev", location: "Los Angeles", date: Date(), url: "https://www.sherdog.com/events/UFC-Fight-Night-255-Edwards-vs-Brady-105670"))
            .modelContainer(for: [
                Event.self,
                Fighter.self,
                Fight.self
            ])
    }
}
