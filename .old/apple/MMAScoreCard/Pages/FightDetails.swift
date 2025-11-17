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
    
    private var resultIcon: String {
        let result = fight.result.uppercased()
        if result.hasPrefix("KO") || result.hasPrefix("TKO") {
            return "figure.martial.arts"
        } else if result.contains("DECISION") || result.contains("DEC") {
            return "list.bullet.clipboard"
        } else if result.contains("SUBMISSION") || result.contains("SUB") {
            return "figure.fall"
        } else {
            return "checkmark.circle.fill"
        }
    }
    
    private var resultColor: Color {
        let result = fight.result.uppercased()
        if result.hasPrefix("KO") || result.hasPrefix("TKO") {
            return .red
        } else if result.contains("DECISION") || result.contains("DEC") {
            return .blue
        } else if result.contains("SUBMISSION") || result.contains("SUB") {
            return .green
        } else {
            return .primary
        }
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
        .navigationTitle("Fight Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    
    @ViewBuilder
    private var resultSection: some View {
        Section("Result") {
            VStack(spacing: 12) {
                // Result with Icon
                HStack(spacing: 12) {
                    Image(systemName: resultIcon)
                        .font(.title2)
                        .foregroundStyle(resultColor)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(resultColor.opacity(0.15))
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(fight.result)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        Text("Method of Victory")
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
                        label: "Time",
                        value: fight.time,
                        color: .orange
                    )
                    
                    InfoPill(
                        icon: "number.circle.fill",
                        label: "Round",
                        value: fight.round,
                        color: .blue
                    )
                }
                
                // Referee Info
                if !fight.referee.isEmpty {
                    Divider()
                    
                    HStack {
                        Label("Referee", systemImage: "person.fill.checkmark")
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
                    Text("Scheduled")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text("This fight has not yet taken place")
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
        Section("Fighters") {
            NavigationLink(destination: FighterDetails(figther: fight.figther1)) {
                HStack(spacing: 12) {
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                        .foregroundStyle(fight.figther1Status == .win ? .green : .secondary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(fight.figther1.name)
                            .font(.headline)
                        
                        if fight.figther1Status != .pending {
                            StatusBadge(status: fight.figther1Status)
                        }
                    }
                }
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(action: {
                    Sharing.shareText(text: "Check out \(fight.figther1.name)\n\(fight.figther1.link)")
                }) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .tint(.blue)
            }
            
            NavigationLink(destination: FighterDetails(figther: fight.figther2)) {
                HStack(spacing: 12) {
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                        .foregroundStyle(fight.figther2Status == .win ? .green : .secondary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(fight.figther2.name)
                            .font(.headline)
                        
                        if fight.figther2Status != .pending {
                            StatusBadge(status: fight.figther2Status)
                        }
                    }
                }
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(action: {
                    Sharing.shareText(text: "Check out \(fight.figther2.name)\n\(fight.figther2.link)")
                }) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .tint(.blue)
            }
        }
    }
    
    @ViewBuilder
    private var eventInfoSection: some View {
        Section("Event Information") {
            LabeledContent {
                Text(event.name)
                    .foregroundStyle(.secondary)
            } label: {
                Label("Event", systemImage: "calendar")
            }
            
            LabeledContent {
                Text(event.location)
                    .foregroundStyle(.secondary)
            } label: {
                Label("Location", systemImage: "location.fill")
            }
            
            LabeledContent {
                Text(event.date.formatted(date: .abbreviated, time: .omitted))
                    .foregroundStyle(.secondary)
            } label: {
                Label("Date", systemImage: "calendar")
            }
            
            LabeledContent {
                Text(fight.division)
                    .foregroundStyle(.secondary)
            } label: {
                Label("Division", systemImage: "gauge")
            }
        }
    }
}

// MARK: - Supporting Views

fileprivate struct FighterCard: View {
    let fighter: Fighter
    let status: FighterStatus
    let isWinner: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isWinner ? "crown.fill" : "person.circle.fill")
                .font(.title)
                .foregroundStyle(isWinner ? .yellow : .secondary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(fighter.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                if status != .pending {
                    StatusBadge(status: status)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

fileprivate struct StatusBadge: View {
    let status: FighterStatus
    
    var badgeColor: Color {
        switch status {
        case .win: return .green
        case .loss: return .red
        case .draw: return .orange
        case .nc: return .gray
        case .pending: return .gray
        }
    }
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(badgeColor)
            )
    }
}

fileprivate struct InfoPill: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            
            Text(value)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(.primary)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

#Preview {
    NavigationStack {
        FigthDetails(event: Event(name: "UFC 313", fight: "Alex Pereira vs. Ankalaev", location: "Los Angeles", date: Date(), url: "https://www.sherdog.com/events/UFC-Fight-Night-255-Edwards-vs-Brady-105670"), fight: Fight(position: 1, figther1: Fighter(name: "Alex Pereira", image: URL(string: "https://www.sherdog.com/image_crop/44/44/_images/fighter/1648844898903_20220401042811_Merab_Dvalishvili_ff.JPG")!, link: URL(string: "https://www.sherdog.com/fighter/Merab-Dvalishvili-157355")!), figther1Status: FighterStatus.win, figther2: Fighter(name: "Mokaev Ankalaev", image: URL(string: "https://www.sherdog.com/image_crop/44/44/_images/fighter/1648844898903_20220401042811_Merab_Dvalishvili_ff.JPG")!, link: URL(string: "https://www.sherdog.com/fighter/Merab-Dvalishvili-157355")!), figther2Status: FighterStatus.loss, result: "Submission (Armbar)", round: "3", time: "1:45", referee: "Marg Godard", division: "Heavyweight", fightStatus: FightStatus.done))
    }
}
