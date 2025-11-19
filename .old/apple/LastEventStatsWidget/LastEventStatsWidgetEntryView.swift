//
//  LastEventStatsWidgetEntryView.swift
//  MMAScoreCard
//
//  Created by dvaca on 3/4/25.
//

import WidgetKit
import SwiftUI

struct LastEventStatsWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: LastEventStatsProvider.Entry
    
    var body: some View {
        if entry.stats == nil {
            loadingView
        } else {
            switch family {
            case .systemSmall:
                smallWidgetView
            case .systemMedium:
                mediumWidgetView
            case .systemLarge, .systemExtraLarge:
                largeWidgetView
            default:
                mediumWidgetView
            }
        }
    }
    
    // MARK: - Widget Views
    
    private var stats: EventStats {
        entry.stats!
    }
    
    private var totalFights: Int {
        stats.kos + stats.submissions + stats.decisions
    }
    
    private var loadingView: some View {
        VStack(spacing: 12) {
            Image(systemName: "figure.boxing")
                .font(.system(size: 40))
                .foregroundStyle(.red.gradient)
            
            Text("Loading Stats...")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            ProgressView()
                .tint(.red)
        }
    }
    
    private var smallWidgetView: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            VStack(alignment: .leading, spacing: 2) {
                Label("Fight Statistics", systemImage: "chart.xyaxis.line")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 9))
                
                Text(stats.name)
                    .font(.system(size: 10, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text(stats.mainFight)
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            
            Spacer()
            
            // Stats
            VStack(spacing: 6) {
                StatRow(
                    label: "KO/TKO",
                    value: stats.kos,
                    total: totalFights,
                    color: .red,
                    compact: true
                )
                
                StatRow(
                    label: "Sub",
                    value: stats.submissions,
                    total: totalFights,
                    color: .green,
                    compact: true
                )
                
                StatRow(
                    label: "Dec",
                    value: stats.decisions,
                    total: totalFights,
                    color: .blue,
                    compact: true
                )
            }
        }
        .padding()
    }
    
    private var mediumWidgetView: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Label("Fight Statistics", systemImage: "chart.xyaxis.line")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(stats.name)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text(stats.mainFight)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Total Fights Badge
                VStack(spacing: 2) {
                    Text("\(totalFights)")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundStyle(.red)
                    
                    Text("Fights")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                )
            }
            
            // Detailed Stats
            VStack(spacing: 10) {
                DetailedStatRow(
                    label: "KO/TKO",
                    value: stats.kos,
                    total: totalFights,
                    icon: "figure.martial.arts",
                    color: .red
                )
                
                DetailedStatRow(
                    label: "Submission",
                    value: stats.submissions,
                    total: totalFights,
                    icon: "figure.fall",
                    color: .green
                )
                
                DetailedStatRow(
                    label: "Decision",
                    value: stats.decisions,
                    total: totalFights,
                    icon: "list.bullet.clipboard",
                    color: .blue
                )
            }
        }
        .padding()
    }
    
    private var largeWidgetView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Label("Fight Statistics", systemImage: "chart.xyaxis.line")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text(stats.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(1)
                    
                    Text(stats.mainFight)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
            }
            
            // Summary Cards
            HStack(spacing: 12) {
                SummaryCard(
                    title: "Total Fights",
                    value: "\(totalFights)",
                    icon: "figure.boxing",
                    color: .orange
                )
                
                SummaryCard(
                    title: "Finishes",
                    value: "\(stats.kos + stats.submissions)",
                    icon: "bolt.fill",
                    color: .red
                )
                
                SummaryCard(
                    title: "Decisions",
                    value: "\(stats.decisions)",
                    icon: "list.bullet.clipboard",
                    color: .blue
                )
            }
            
            Divider()
            
            // Detailed Stats
            VStack(spacing: 10) {
                DetailedStatRow(
                    label: "KO/TKO",
                    value: stats.kos,
                    total: totalFights,
                    icon: "figure.martial.arts",
                    color: .red
                )
                
                DetailedStatRow(
                    label: "Submission",
                    value: stats.submissions,
                    total: totalFights,
                    icon: "figure.fall",
                    color: .green
                )
                
                DetailedStatRow(
                    label: "Decision",
                    value: stats.decisions,
                    total: totalFights,
                    icon: "list.bullet.clipboard",
                    color: .blue
                )
            }
        }
        .padding()
    }
}

// MARK: - Supporting Views

fileprivate struct StatRow: View {
    let label: String
    let value: Int
    let total: Int
    let color: Color
    let compact: Bool
    
    private var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(value) / Double(total)
    }
    
    var body: some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.system(size: compact ? 9 : 11, weight: .medium))
                .foregroundStyle(.secondary)
                .frame(width: compact ? 35 : 50, alignment: .leading)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(.systemGray5))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color.gradient)
                        .frame(width: geometry.size.width * percentage, height: 6)
                }
            }
            .frame(height: 6)
            
            Text("\(value)")
                .font(.system(size: compact ? 10 : 12, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .frame(width: compact ? 15 : 20, alignment: .trailing)
        }
    }
}

fileprivate struct StatCard: View {
    let title: String
    let value: Int
    let total: Int
    let icon: String
    let color: Color
    
    private var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(value) / Double(total) * 100
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color.gradient)
            
            Text("\(value)")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(.primary)
            
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(String(format: "%.0f%%", percentage))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
    }
}

fileprivate struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color.gradient)
            
            Text(value)
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundStyle(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

fileprivate struct DetailedStatRow: View {
    let label: String
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
                Label {
                    Text(label)
                        .font(.subheadline)
                        .fontWeight(.medium)
                } icon: {
                    Image(systemName: icon)
                        .foregroundStyle(color)
                }
                
                            Spacer()
                
                HStack(spacing: 4) {
                    Text("\(value)")
                        .font(.system(.body, design: .rounded, weight: .bold))
                        .foregroundStyle(color)
                    
                    Text("/ \(total)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.gradient)
                        .frame(width: geometry.size.width * percentage, height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}

#Preview(as: .systemSmall) {
    LastEventStatsWidget()
} timeline: {
    LastEventStatsEntry(date: .now, stats: EventStats(name: "UFC 313", mainFight: "Pereira vs. Hill", kos: 5, submissions: 3, decisions: 4))
    LastEventStatsEntry(date: .now, stats: nil)
}

#Preview(as: .systemMedium) {
    LastEventStatsWidget()
} timeline: {
    LastEventStatsEntry(date: .now, stats: EventStats(name: "UFC 313", mainFight: "Pereira vs. Hill", kos: 5, submissions: 3, decisions: 4))
    LastEventStatsEntry(date: .now, stats: nil)
}

#Preview(as: .systemLarge) {
    LastEventStatsWidget()
} timeline: {
    LastEventStatsEntry(date: .now, stats: EventStats(name: "UFC 313", mainFight: "Pereira vs. Hill", kos: 5, submissions: 3, decisions: 4))
    LastEventStatsEntry(date: .now, stats: nil)
}

#Preview(as: .systemExtraLarge) {
    LastEventStatsWidget()
} timeline: {
    LastEventStatsEntry(date: .now, stats: EventStats(name: "UFC 313", mainFight: "Pereira vs. Hill", kos: 5, submissions: 3, decisions: 4))
    LastEventStatsEntry(date: .now, stats: nil)
}
