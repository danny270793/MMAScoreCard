//
//  FighterCareer.swift
//  MMAScoreCard
//
//  Created by dvaca on 24/3/25.
//

import SwiftUI

struct FighterCareer: View {
    let fighter: Fighter
    let fights: [Record]
    
    private var wins: Int {
        fights.filter { $0.status == .win }.count
    }
    
    private var losses: Int {
        fights.filter { $0.status == .loss }.count
    }
    
    private var draws: Int {
        fights.filter { $0.status == .draw }.count
    }
    
    private var ncs: Int {
        fights.filter { $0.status == .nc }.count
    }
    
    private var totalFights: Int {
        fights.count
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
    
    var body: some View {
        List {
            recordSection
            finishTypesSection
            breakdownSection
        }
        .navigationTitle("Career Statistics")
        .navigationBarTitleDisplayMode(.large)
    }
    
    @ViewBuilder
    private var recordSection: some View {
        Section {
            VStack(spacing: 16) {
                // Record Display
                HStack(spacing: 16) {
                    RecordBadge(label: "W", value: wins, color: .green)
                    RecordBadge(label: "L", value: losses, color: .red)
                    RecordBadge(label: "D", value: draws, color: .orange)
                    if ncs > 0 {
                        RecordBadge(label: "NC", value: ncs, color: .gray)
                    }
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
    private var breakdownSection: some View {
        Section("Breakdown") {
            VStack(spacing: 12) {
                if wins > 0 {
                    PercentageRow(
                        title: "KO/TKO Wins",
                        value: koWins,
                        total: wins,
                        color: .red
                    )
                    
                    PercentageRow(
                        title: "Submission Wins",
                        value: submissionWins,
                        total: wins,
                        color: .green
                    )
                    
                    PercentageRow(
                        title: "Decision Wins",
                        value: decisionWins,
                        total: wins,
                        color: .blue
                    )
                }
            }
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Supporting Views

struct RecordBadge: View {
    let label: String
    let value: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundStyle(color)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(minWidth: 50)
    }
}

fileprivate struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundStyle(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

fileprivate struct StatBar: View {
    let title: String
    let value: Int
    let total: Int
    let icon: String
    let color: Color
    
    private var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(value) / Double(total)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text("\(value)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(color)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * percentage, height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding(.vertical, 4)
    }
}

fileprivate struct PercentageRow: View {
    let title: String
    let value: Int
    let total: Int
    let color: Color
    
    private var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(value) / Double(total)
    }
    
    private var percentageString: String {
        String(format: "%.1f%%", percentage * 100)
    }
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.primary)
            
            Spacer()
            
            Text("\(value)/\(total)")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(percentageString)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(color)
                .frame(minWidth: 50, alignment: .trailing)
        }
    }
}

#Preview {
    NavigationStack {
        FighterCareer(
            fighter: Fighter(name: "Merab Dvalishvili", image: URL(string: "https://www.sherdog.com/image_crop/44/44/_images/fighter/1648844898903_20220401042811_Merab_Dvalishvili_ff.JPG")!, link: URL(string: "https://www.sherdog.com/fighter/Islam-Makhachev-76836")!),
            fights: [
                
            ]
        )
    }
}

