//
//  About.swift
//  MMAScoreCard
//
//  Created by dvaca on 27/3/25.
//

import SwiftUI

extension Bundle {
    var iconFileName: String? {
        guard let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
              let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
              let iconFileName = iconFiles.last
        else { return nil }
        return iconFileName
    }
}

struct AppIcon: View {
    var body: some View {
        Bundle.main.iconFileName
            .flatMap { UIImage(named: $0) }
            .map { Image(uiImage: $0) }
    }
}

struct AboutView: View {
    private let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "MMA ScoreCard"
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    var body: some View {
        List {
            appHeaderSection
            appInfoSection
            developerSection
            socialSection
            legalSection
            footerSection
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.large)
    }
    
    @ViewBuilder
    private var appHeaderSection: some View {
        Section {
            VStack(spacing: 16) {
                AppIcon()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 22.5, style: .continuous))
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                
                Text(appName)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Track MMA fights and statistics")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
    
    @ViewBuilder
    private var appInfoSection: some View {
        Section("Application") {
            InfoRow(label: "Version", icon: "number.circle.fill", value: appVersion)
            InfoRow(label: "Build", icon: "hammer.fill", value: buildNumber)
            InfoRow(label: "Requires", icon: "iphone", value: "iOS 16.0+")
        }
    }
    
    @ViewBuilder
    private var developerSection: some View {
        Section("Developer") {
            VStack(spacing: 12) {
                ProfileCard(
                    name: "Danny Vaca",
                    subtitle: "iOS Developer",
                    icon: "person.circle.fill",
                    color: .blue
                )
                
                Divider()
                
                LinkButton(
                    label: "danny270793@icloud.com",
                    icon: "envelope.fill",
                    url: "mailto:danny270793@icloud.com"
                )
            }
            .padding(.vertical, 4)
        }
    }
    
    @ViewBuilder
    private var socialSection: some View {
        Section("Connect") {
            IconCard(
                title: "GitHub",
                subtitle: "@danny270793",
                icon: "chevron.left.forwardslash.chevron.right",
                color: .primary,
                url: "https://github.com/danny270793"
            )
            
            IconCard(
                title: "YouTube",
                subtitle: "@DannyVacaO",
                icon: "play.rectangle.fill",
                color: .red,
                url: "https://www.youtube.com/@DannyVacaO"
            )
        }
    }
    
    @ViewBuilder
    private var legalSection: some View {
        Section("Legal") {
            NavigationLink(destination: TermsAndConditionsView()) {
                IconCardContent(
                    title: "Terms & Conditions",
                    subtitle: "View our terms of service",
                    icon: "doc.text.fill",
                    color: .blue
                )
            }
            
            NavigationLink(destination: PrivacyPolicyView()) {
                IconCardContent(
                    title: "Privacy Policy",
                    subtitle: "How we protect your data",
                    icon: "lock.shield.fill",
                    color: .green
                )
            }
        }
    }
    
    @ViewBuilder
    private var footerSection: some View {
        Section {
            VStack(spacing: 8) {
                Text("Made with ❤️ for MMA fans")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                Text("© 2025 Danny Vaca")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Reusable Components

/// Reusable info row with icon and value
fileprivate struct InfoRow: View {
    let label: String
    let icon: String
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

/// Circular icon background
fileprivate struct CircularIconBackground: View {
    let icon: String
    let color: Color
    let size: CGFloat
    
    var body: some View {
        Image(systemName: icon)
            .font(.title3)
            .foregroundStyle(color)
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(color.opacity(0.15))
            )
    }
}

/// Profile card with icon and text
fileprivate struct ProfileCard: View {
    let name: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

/// External link button with icon
fileprivate struct LinkButton: View {
    let label: String
    let icon: String
    let url: String
    
    var body: some View {
        Button(action: { openURL(url) }) {
            HStack {
                Label(label, systemImage: icon)
                    .font(.subheadline)
                
                Spacer()
                
                Image(systemName: "arrow.up.right.square.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

/// Icon card content (for use with buttons or navigation links)
fileprivate struct IconCardContent: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            CircularIconBackground(icon: icon, color: color, size: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

/// Icon card as a button with external link
fileprivate struct IconCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let url: String
    
    var body: some View {
        Button(action: { openURL(url) }) {
            HStack(spacing: 12) {
                CircularIconBackground(icon: icon, color: color, size: 40)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.right.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.tertiary)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Helper Functions

fileprivate func openURL(_ urlString: String) {
    if let url = URL(string: urlString) {
        UIApplication.shared.open(url)
    }
}

#Preview {
    NavigationView {
        AboutView()
    }
}
