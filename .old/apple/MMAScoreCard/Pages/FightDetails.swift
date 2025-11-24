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
    
    private var resultStyle: FightResultStyle {
        FightResultStyle(result: fight.result)
    }
    
    var body: some View {
        List {
            eventInfoSection
            
            if fight.fightStatus == .done {
                resultSection
            } else {
                scheduledSection
            }
            
            fightersSection
        }
        .navigationTitle("\(fight.figther1.name) vs. \(fight.figther2.name)")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    
    @ViewBuilder
    private var resultSection: some View {
        Section(String(localized: "fight.result")) {
            VStack(spacing: 12) {
                // Result with Icon
                HStack(spacing: 12) {
                    Image(systemName: resultStyle.icon)
                        .font(.title2)
                        .foregroundStyle(resultStyle.color)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(resultStyle.color.opacity(0.15))
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(fight.result)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        Text(String(localized: "fight.method"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                
                Divider()
                
                // Time and Round Info
                HStack(spacing: 20) {
                    InfoPill(
                        icon: "clock.fill",
                        label: String(localized: "fight.time", defaultValue: "Time %@"),
                        value: fight.time,
                        color: .orange
                    )
                    
                    InfoPill(
                        icon: "number.circle.fill",
                        label: String(localized: "fight.round", defaultValue: "Round %d"),
                        value: fight.round,
                        color: .blue
                    )
                }
                
                // Referee Info
                if !fight.referee.isEmpty {
                    Divider()
                    
                    HStack {
                        Label(String(format: String(localized: "fight.referee"), fight.referee), systemImage: "person.fill.checkmark")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text(fight.referee)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    @ViewBuilder
    private var scheduledSection: some View {
        Section {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .font(.title2)
                    .foregroundStyle(.orange)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(localized: "fight.scheduled"))
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text(String(localized: "fight.scheduled"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
        }
    }
    
    @ViewBuilder
    private var fightersSection: some View {
        Section(String(localized: "fight.fighters")) {
            NavigationLink(destination: FighterDetails(figther: fight.figther1)) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(fight.figther1.name)
                        .font(.headline)
                    
                    if fight.figther1Status != .pending {
                        StatusBadge(status: fight.figther1Status)
                    }
                }
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(action: {
                    Sharing.shareText(text: "Check out \(fight.figther1.name)\n\(fight.figther1.link)")
                }) {
                    Label(String(localized: "common.share"), systemImage: "square.and.arrow.up")
                }
                .tint(.blue)
            }
            
            NavigationLink(destination: FighterDetails(figther: fight.figther2)) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(fight.figther2.name)
                        .font(.headline)
                    
                    if fight.figther2Status != .pending {
                        StatusBadge(status: fight.figther2Status)
                    }
                }
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(action: {
                    Sharing.shareText(text: "Check out \(fight.figther2.name)\n\(fight.figther2.link)")
                }) {
                    Label(String(localized: "common.share"), systemImage: "square.and.arrow.up")
                }
                .tint(.blue)
            }
        }
    }
    
    @ViewBuilder
    private var eventInfoSection: some View {
        Section(String(localized: "fight.event_info")) {
            InfoRow(
                icon: "rectangle.and.pencil.and.ellipsis",
                label: "Event",
                value: event.name
            )
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
            InfoRow(
                icon: "scalemass.fill",
                label: "Division",
                value: fight.division.name
            )
        }
    }
}

#Preview {
    NavigationStack {
        FigthDetails(event: Event(name: "UFC 313", fight: "Alex Pereira vs. Ankalaev", location: "Los Angeles", date: Date(), url: "https://www.sherdog.com/events/UFC-Fight-Night-255-Edwards-vs-Brady-105670"), fight: Fight(position: 1, figther1: Fighter(name: "Alex Pereira", image: URL(string: "https://www.sherdog.com/image_crop/44/44/_images/fighter/1648844898903_20220401042811_Merab_Dvalishvili_ff.JPG")!, link: URL(string: "https://www.sherdog.com/fighter/Merab-Dvalishvili-157355")!), figther1Status: FighterStatus.win, figther2: Fighter(name: "Mokaev Ankalaev", image: URL(string: "https://www.sherdog.com/image_crop/44/44/_images/fighter/1648844898903_20220401042811_Merab_Dvalishvili_ff.JPG")!, link: URL(string: "https://www.sherdog.com/fighter/Merab-Dvalishvili-157355")!), figther2Status: FighterStatus.loss, result: "Submission (Armbar)", round: "3", time: "1:45", referee: "Marg Godard", division: "Heavyweight", fightStatus: FightStatus.done, titleFight: true))
    }
}
