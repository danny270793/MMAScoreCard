//
//  FighterCareer.swift
//  MMAScoreCard
//
//  Created by dvaca on 24/3/25.
//

import SwiftUI

struct FighterCareer: View {
    let fighter: Fighter
    let record: FighterRecord
    
    private var fights: [Record] { record.fights }
    private var wins: Int { record.wins }
    private var losses: Int { record.losses }
    private var draws: Int { record.draws }
    private var ncs: Int { record.noContests }
    
    private var totalFights: Int {
        wins + losses + draws + ncs
    }
    
    private var winRate: Double {
        let total = wins + losses + draws
        guard total > 0 else { return 0 }
        return Double(wins) / Double(total) * 100
    }
    
    private var koWins: Int {
        fights.filter { fight in
            fight.status == .win && (fight.method.uppercased().contains("KO") || fight.method.uppercased().contains("TKO"))
        }.count
    }
    
    private var submissionWins: Int {
        fights.filter { fight in
            fight.status == .win && (fight.method.uppercased().contains("SUBMISSION") || fight.method.uppercased().contains("SUB"))
        }.count
    }
    
    private var decisionWins: Int {
        fights.filter { fight in
            fight.status == .win && (fight.method.uppercased().contains("DECISION") || fight.method.uppercased().contains("DEC"))
        }.count
    }
    
    private var koLosses: Int {
        fights.filter { fight in
            fight.status == .loss && (fight.method.uppercased().contains("KO") || fight.method.uppercased().contains("TKO"))
        }.count
    }
    
    private var submissionLosses: Int {
        fights.filter { fight in
            fight.status == .loss && (fight.method.uppercased().contains("SUBMISSION") || fight.method.uppercased().contains("SUB"))
        }.count
    }
    
    private var decisionLosses: Int {
        fights.filter { fight in
            fight.status == .loss && (fight.method.uppercased().contains("DECISION") || fight.method.uppercased().contains("DEC"))
        }.count
    }
    
    // MARK: - Streak Calculations
    
    private struct Streak {
        let type: FighterStatus
        let count: Int
    }
    
    private var streaks: [Streak] {
        var result: [Streak] = []
        
        for fight in fights {
            if let last = result.last, last.type == fight.status {
                result[result.count - 1] = Streak(type: fight.status, count: last.count + 1)
            } else {
                result.append(Streak(type: fight.status, count: 1))
            }
        }
        
        return result
    }
    
    private var currentStreak: Streak {
        streaks.first ?? Streak(type: .pending, count: 0)
    }
    
    private var bestWinStreak: Int {
        streaks
            .filter { $0.type == .win }
            .map { $0.count }
            .max() ?? 0
    }
    
    private var worstLossStreak: Int {
        streaks
            .filter { $0.type == .loss }
            .map { $0.count }
            .max() ?? 0
    }
    
    // MARK: - Time
    private var octagonTime: String {
        let totalSeconds = fights.reduce(0) { total, fight in
            print("\(fight.round) - \(fight.time)")
            
            // Parse round number (e.g., "Round 3" -> 3)
            let roundNumber = Int(fight.round.filter { $0.isNumber }) ?? 1
            
            // Parse time (e.g., "2:34" -> 154 seconds)
            let timeComponents = fight.time.split(separator: ":").compactMap { Int($0) }
            let fightSeconds: Int
            if timeComponents.count == 2 {
                fightSeconds = (timeComponents[0] * 60) + timeComponents[1]
            } else {
                fightSeconds = 0
            }
            
            // Calculate total time: (completed rounds * 5 minutes) + time in current round
            let completedRounds = max(0, roundNumber - 1)
            let totalFightSeconds = (completedRounds * 5 * 60) + fightSeconds
            
            return total + totalFightSeconds
        }
        
        print("totalSeconds: \(totalSeconds)")
        
        let days = totalSeconds / (24 * 3600)
        let hours = (totalSeconds % (24 * 3600)) / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        return String(format: "%02d %02d:%02d:%02d", days, hours, minutes, seconds)
    }
    
    var body: some View {
        List {
            recordSection
            performanceSection
            finishTypesSection
            lossMethodsSection
            breakdownSection
        }
        .navigationTitle("Carrer statistics")
        .navigationBarTitleDisplayMode(.large)
    }
    
    @ViewBuilder
    private var recordSection: some View {
        if ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 16 {
            HStack {
                Label("Fighter", systemImage: "person")
                Spacer()
                Text(fighter.name)
                    .foregroundStyle(.secondary)
            }
        }
        Section {
            VStack(spacing: 16) {
                // Record Display
                HStack(spacing: 16) {
                    RecordBadge(label: "W", value: wins, color: .green)
                    RecordBadge(label: "L", value: losses, color: .red)
                    RecordBadge(label: "D", value: draws, color: .orange)
                    RecordBadge(label: "NC", value: ncs, color: .gray)
                }
                .padding(.bottom, 8)
                
                HStack(spacing: 20) {
                    StatCard(
                        title: "Total Fights",
                        value: "\(totalFights)",
                        icon: "figure.boxing",
                        color: .blue
                    )
                    
                    Divider()
                    
                    StatCard(
                        title: "Win Rate",
                        value: String(format: "%.0f%%", winRate),
                        icon: "trophy.fill",
                        color: .green
                    )
                }
                .padding(.vertical, 8)
            }
            .padding(.top, 8)
        }
    }
    
    @ViewBuilder
    private var performanceSection: some View {
        Section("Performance Metrics") {
            VStack(spacing: 12) {
                // Current Streak
                HStack {
                    Label("Current Streak", systemImage: "flame.fill")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text("\(currentStreak.count)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text(currentStreak.type == .win ? "W" : currentStreak.type == .loss ? "L" : "-")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                    .foregroundStyle(currentStreak.type == .win ? .green : currentStreak.type == .loss ? .red : .gray)
                }
                .padding(.vertical, 4)
                
                Divider()
                
                // Best Win Streak
                HStack {
                    Label("Best Win Streak", systemImage: "chart.line.uptrend.xyaxis")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text("\(bestWinStreak)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("W")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                    .foregroundStyle(.green)
                }
                .padding(.vertical, 4)
                
                Divider()
                
                // Worst Loss Streak
                HStack {
                    Label("Worst Loss Streak", systemImage: "chart.line.downtrend.xyaxis")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text("\(worstLossStreak)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("L")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                    .foregroundStyle(.red)
                }
                .padding(.vertical, 4)
                
                Divider()
                
                // Octagon Time
                HStack {
                    Label("Time in Octagon", systemImage: "timer")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Text(octagonTime)
                        .font(.system(.subheadline, design: .monospaced))
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                }
                .padding(.vertical, 4)
            }
            .padding(.vertical, 4)
        }
    }
    
    @ViewBuilder
    private var finishTypesSection: some View {
        Section("Win Methods") {
            StatBar(
                title: "KO/TKO",
                value: koWins,
                total: wins,
                icon: "figure.martial.arts",
                color: .red
            )
            
            StatBar(
                title: "Submission",
                value: submissionWins,
                total: wins,
                icon: "figure.fall",
                color: .green
            )
            
            StatBar(
                title: "Decision",
                value: decisionWins,
                total: wins,
                icon: "list.bullet.clipboard",
                color: .blue
            )
        }
    }
    
    @ViewBuilder
    private var lossMethodsSection: some View {
        Section("Loss Methods") {
            StatBar(
                title: "KO/TKO",
                value: koLosses,
                total: losses,
                icon: "figure.martial.arts",
                color: .red
            )
            
            StatBar(
                title: "Submission",
                value: submissionLosses,
                total: losses,
                icon: "figure.fall",
                color: .orange
            )
            
            StatBar(
                title: "Decision",
                value: decisionLosses,
                total: losses,
                icon: "list.bullet.clipboard",
                color: .purple
            )
        }
    }
    
    @ViewBuilder
    private var breakdownSection: some View {
        Section("Breakdown") {
            VStack(spacing: 12) {
                if wins > 0 {
                    Text("Wins Breakdown")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    PercentageRow(
                        title: "KO/TKO Wins",
                        value: koWins,
                        total: wins,
                        color: .red,
                        showFraction: true
                    )
                    
                    PercentageRow(
                        title: "Submission Wins",
                        value: submissionWins,
                        total: wins,
                        color: .green,
                        showFraction: true
                    )
                    
                    PercentageRow(
                        title: "Decision Wins",
                        value: decisionWins,
                        total: wins,
                        color: .blue,
                        showFraction: true
                    )
                }
                
                if losses > 0 {
                    if wins > 0 {
                        Divider()
                            .padding(.vertical, 8)
                    }
                    
                    Text("Losses Breakdown")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    PercentageRow(
                        title: "KO/TKO Losses",
                        value: koLosses,
                        total: losses,
                        color: .red,
                        showFraction: true
                    )
                    
                    PercentageRow(
                        title: "Submission Losses",
                        value: submissionLosses,
                        total: losses,
                        color: .orange,
                        showFraction: true
                    )
                    
                    PercentageRow(
                        title: "Decision Losses",
                        value: decisionLosses,
                        total: losses,
                        color: .purple,
                        showFraction: true
                    )
                }
            }
            .padding(.vertical, 4)
        }
    }
}

// MARK: - No local components needed - using SharedComponents

#Preview {
    let fighter = Fighter(name: "Merab Dvalishvili", image: URL(string: "https://www.sherdog.com/image_crop/44/44/_images/fighter/1648844898903_20220401042811_Merab_Dvalishvili_ff.JPG")!, link: URL(string: "https://www.sherdog.com/fighter/Islam-Makhachev-76836")!)
    let record = FighterRecord(name: fighter.name, nationality: "Georgia", age: "33", height: "66", weight: "135", wins: 18, losses: 4, draws: 0, noContests: 0, fights: [])
    return NavigationStack {
        FighterCareer(fighter: fighter, record: record)
    }
}

