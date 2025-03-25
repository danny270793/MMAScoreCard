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
                if fight.fightStatus != FightStatus.pending.rawValue {
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
                if fight.figther1Status != FightStatus.pending.rawValue {
                    LabeledContent("Status", value: fight.figther1Status)
                }
                
            }
            Section(header: Text("Fighter 2")) {
                NavigationLink(destination: FighterDetails(figther: fight.figther2)) {
                    LabeledContent("Name", value: fight.figther2.name)
                }
                if fight.figther2Status != FightStatus.pending.rawValue {
                    LabeledContent("Status", value: fight.figther2Status)
                }
            }
        }
        .navigationTitle("\(fight.figther1.name) vs \(fight.figther2.name)")
    }
}

#Preview {
    NavigationStack {
        FigthDetails(event: Event(name: "UFC 313", fight: "Alex Pereira vs. Ankalaev", location: "Los Angeles", date: Date(), url: "https://www.sherdog.com/events/UFC-Fight-Night-255-Edwards-vs-Brady-105670"), fight: Fight(position: 1, figther1: Fighter(name: "Alex Pereira", image: "", link: ""), figther1Status: FighterStatus.win, figther2: Fighter(name: "Mokaev Ankalaev", image: "", link: ""), figther2Status: FighterStatus.loss, result: "Submission (Armbar)", round: "3", time: "1:45", referee: "Marg Godard", division: "Heavyweight", fightStatus: FightStatus.done))
            .modelContainer(for: [
                Event.self,
                Fighter.self,
                Fight.self
            ])
    }
}
