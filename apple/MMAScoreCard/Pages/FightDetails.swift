//
//  FightDetails.swift
//  MMAScoreCard
//
//  Created by dvaca on 24/3/25.
//

import SwiftUI
import SwiftData

struct FigthDetails: View {
    let event: Event
    let fight: Fight
    
    var body: some View {
        List {
            Section(header: Text("Event")) {
                LabeledContent("Name", value: event.name)
                LabeledContent("Location", value: event.location)
                LabeledContent("Date", value: event.date.ISO8601Format().split(separator: "T")[0])
            }
            Section(header: Text("Fight")) {
                LabeledContent("Division", value: fight.division)
                if fight.fightStatus != FightStatus.pending {
                    LabeledContent("Result", value: fight.result)
                    LabeledContent("Round", value: fight.round)
                    LabeledContent("Time", value: fight.time)
                    LabeledContent("Referee", value: fight.referee)
                }
            }
            Section(header: Text("Fighter 1")) {
                NavigationLink(destination: FighterDetails(figther: fight.figther1)) {
                    LabeledContent("Name", value: fight.figther1.name)
                }
                .contextMenu {
                    Button(action: {
                        
                    }) {
                        Text("Share")
                        Image(systemName: "square.and.arrow.up")
                    }
                } preview: {
                    NavigationStack {
                        FighterDetails(figther: fight.figther1)
                    }
                }
                if fight.figther1Status != FighterStatus.pending {
                    LabeledContent("Status", value: fight.figther1Status.rawValue)
                }
            }
            Section(header: Text("Fighter 2")) {
                NavigationLink(destination: FighterDetails(figther: fight.figther2)) {
                    LabeledContent("Name", value: fight.figther2.name)
                }
                .contextMenu {
                    Button(action: {
                        
                    }) {
                        Text("Share")
                        Image(systemName: "square.and.arrow.up")
                    }
                } preview: {
                    NavigationStack {
                        FighterDetails(figther: fight.figther2)
                    }
                }
                if fight.figther2Status != FighterStatus.pending {
                    LabeledContent("Status", value: fight.figther2Status.rawValue)
                }
            }
        }
        .navigationTitle("\(fight.figther1.name) vs \(fight.figther2.name)")
    }
}

#Preview {
    NavigationStack {
        FigthDetails(event: Event(name: "UFC 313", fight: "Alex Pereira vs. Ankalaev", location: "Los Angeles", date: Date(), url: "https://www.sherdog.com/events/UFC-Fight-Night-255-Edwards-vs-Brady-105670"), fight: Fight(position: 1, figther1: Fighter(name: "Alex Pereira", image: URL(string: "https://www.sherdog.com/image_crop/44/44/_images/fighter/1648844898903_20220401042811_Merab_Dvalishvili_ff.JPG")!, link: URL(string: "https://www.sherdog.com/fighter/Merab-Dvalishvili-157355")!), figther1Status: FighterStatus.win, figther2: Fighter(name: "Mokaev Ankalaev", image: URL(string: "https://www.sherdog.com/image_crop/44/44/_images/fighter/1648844898903_20220401042811_Merab_Dvalishvili_ff.JPG")!, link: URL(string: "https://www.sherdog.com/fighter/Merab-Dvalishvili-157355")!), figther2Status: FighterStatus.loss, result: "Submission (Armbar)", round: "3", time: "1:45", referee: "Marg Godard", division: "Heavyweight", fightStatus: FightStatus.done))
    }
}
