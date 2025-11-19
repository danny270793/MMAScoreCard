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
        .navigationTitle(String(localized: "about.title"))
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
                
                Text(String(localized: "about.tagline"))
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
        Section(String(localized: "about.app_info")) {
            InfoRow(icon: "number.circle.fill", label: String(localized: "about.version"), value: appVersion)
            InfoRow(icon: "hammer.fill", label: String(localized: "about.build"), value: buildNumber)
            InfoRow(icon: "iphone", label: String(localized: "about.requirements"), value: String(localized: "about.ios_version"))
        }
    }
    
    @ViewBuilder
    private var developerSection: some View {
        Section(String(localized: "about.developer")) {
            VStack(spacing: 12) {
                ProfileCard(
                    name: String(localized: "about.developer_name"),
                    subtitle: String(localized: "about.developer_title"),
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
        Section(String(localized: "about.social")) {
            IconCard(
                title: String(localized: "about.github"),
                subtitle: "@danny270793",
                icon: "chevron.left.forwardslash.chevron.right",
                color: .primary,
                url: "https://github.com/danny270793"
            )
            
            IconCard(
                title: String(localized: "about.youtube"),
                subtitle: "@DannyVacaO",
                icon: "play.rectangle.fill",
                color: .red,
                url: "https://www.youtube.com/@DannyVacaO"
            )
        }
    }
    
    @ViewBuilder
    private var legalSection: some View {
        Section(String(localized: "about.legal")) {
            NavigationLink(destination: TermsAndConditionsView()) {
                IconCardContent(
                    title: String(localized: "about.terms"),
                    subtitle: String(localized: "terms.title"),
                    icon: "doc.text.fill",
                    color: .blue
                )
            }
            
            NavigationLink(destination: PrivacyPolicyView()) {
                IconCardContent(
                    title: String(localized: "about.privacy"),
                    subtitle: String(localized: "privacy.title"),
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
                
                Text(String(localized: "about.footer"))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Reusable Components

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

#Preview {
    NavigationView {
        AboutView()
    }
}
