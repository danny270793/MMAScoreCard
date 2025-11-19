//
//  SharedComponents.swift
//  MMAScoreCard
//
//  Shared reusable UI components across all pages
//

import SwiftUI

// MARK: - Statistics Components

/// Stat card displaying a value with icon and title
struct StatCard: View {
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

/// Progress bar showing value/total ratio
struct StatBar: View {
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

/// Percentage display row
struct PercentageRow: View {
    let title: String
    let value: Int
    let total: Int
    let color: Color
    let showFraction: Bool
    
    init(title: String, value: Int, total: Int, color: Color, showFraction: Bool = false) {
        self.title = title
        self.value = value
        self.total = total
        self.color = color
        self.showFraction = showFraction
    }
    
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
            
            if showFraction {
                Text("\(value)/\(total)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Text(percentageString)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(color)
                .frame(minWidth: 50, alignment: .trailing)
        }
    }
}

/// Record badge (W-L-D-NC)
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

// MARK: - Info Display Components

/// Info row with icon, label, and value
struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Label(label, systemImage: icon)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

/// Labeled content row with icon
struct LabeledInfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        LabeledContent {
            Text(value)
                .foregroundStyle(.secondary)
        } label: {
            Label(label, systemImage: icon)
        }
    }
}

// MARK: - Status & Badge Components

/// Fighter status badge (Win/Loss/Draw/NC)
struct StatusBadge: View {
    let status: FighterStatus
    
    private var badgeColor: Color {
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

/// Info pill for displaying statistics
struct InfoPill: View {
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

// MARK: - Fight Result Helpers

/// Helper struct for fight result styling
struct FightResultStyle {
    let icon: String
    let color: Color
    let hasResult: Bool
    
    init(result: String) {
        let upperResult = result.uppercased()
        
        if upperResult.hasPrefix("KO") || upperResult.hasPrefix("TKO") {
            self.icon = "figure.martial.arts"
            self.color = .red
            self.hasResult = true
        } else if upperResult.contains("DECISION") || upperResult.contains("DEC") {
            self.icon = "list.bullet.clipboard"
            self.color = .blue
            self.hasResult = true
        } else if upperResult.contains("SUBMISSION") || upperResult.contains("SUB") {
            self.icon = "figure.fall"
            self.color = .green
            self.hasResult = true
        } else if upperResult.contains("NO CONTEST") || upperResult.contains("NC") {
            self.icon = "nosign"
            self.color = .primary
            self.hasResult = false
        } else if upperResult.contains("DRAW") {
            self.icon = "figure.2.right.holdinghands"
            self.color = .green
            self.hasResult = true
        } else {
            self.icon = "clock.badge"
            self.color = .orange
            self.hasResult = false
        }
    }
}

// MARK: - Section Views

/// Cache metadata section
struct CacheMetadataSection: View {
    let cachedAt: Date?
    let timeCached: String?
    
    var body: some View {
        if let cachedAt = cachedAt, let timeCached = timeCached {
            Section("Cache Info") {
                LabeledContent {
                    Text(cachedAt.formatted(date: .abbreviated, time: .shortened))
                        .foregroundStyle(.secondary)
                } label: {
                    Label("Cached", systemImage: "clock.arrow.circlepath")
                }
                
                LabeledContent {
                    Text(timeCached)
                        .foregroundStyle(.secondary)
                } label: {
                    Label("Cache Time", systemImage: "timer")
                }
            }
        }
    }
}

/// Loading overlay with progress indicator
struct LoadingOverlay: View {
    let isLoading: Bool
    let isEmpty: Bool
    let message: String
    
    init(isLoading: Bool, isEmpty: Bool, message: String = "Loading...") {
        self.isLoading = isLoading
        self.isEmpty = isEmpty
        self.message = message
    }
    
    var body: some View {
        if isLoading && isEmpty {
            ContentUnavailableView {
                ProgressView()
            } description: {
                Text(message)
            }
        }
    }
}

// MARK: - Action Buttons

/// Share button for swipe actions
struct ShareSwipeButton: View {
    let text: String
    let action: () -> Void
    
    init(text: String) {
        self.text = text
        self.action = { Sharing.shareText(text: text) }
    }
    
    var body: some View {
        Button(action: action) {
            Label("Share", systemImage: "square.and.arrow.up")
        }
        .tint(.blue)
    }
}

/// Context menu share item
struct ShareContextMenuItem: View {
    let text: String
    
    var body: some View {
        Button(action: { Sharing.shareText(text: text) }) {
            Label("Share", systemImage: "square.and.arrow.up")
        }
    }
}

// MARK: - Helper Functions

/// Open URL in Safari or appropriate app
func openURL(_ urlString: String) {
    if let url = URL(string: urlString) {
        UIApplication.shared.open(url)
    }
}

/// Open app settings
func openAppSettings() {
    if let appSettings = URL(string: UIApplication.openSettingsURLString) {
        UIApplication.shared.open(appSettings)
    }
}

