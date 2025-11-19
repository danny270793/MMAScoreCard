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
    let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "MMA ScoreCard"
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
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
                // App Icon
                AppIcon()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 22.5, style: .continuous))
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                
                // App Name
                Text(appName)
                    .font(.title2)
                    .fontWeight(.bold)
                
                // Tagline
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
            LabeledContent {
                Text(appVersion)
                    .foregroundStyle(.secondary)
            } label: {
                Label("Version", systemImage: "number.circle.fill")
            }
            
            LabeledContent {
                Text(buildNumber)
                    .foregroundStyle(.secondary)
            } label: {
                Label("Build", systemImage: "hammer.fill")
            }
            
            LabeledContent {
                Text("iOS 16.0+")
                    .foregroundStyle(.secondary)
            } label: {
                Label("Requires", systemImage: "iphone")
            }
        }
    }
    
    @ViewBuilder
    private var developerSection: some View {
        Section("Developer") {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Danny Vaca")
                            .font(.headline)
                        
                        Text("iOS Developer")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                
                Divider()
                
                // Email Button
                Button(action: {
                    if let url = URL(string: "mailto:danny270793@icloud.com") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack {
                        Label("danny270793@icloud.com", systemImage: "envelope.fill")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.right.square.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    @ViewBuilder
    private var socialSection: some View {
        Section("Connect") {
            SocialButton(
                title: "GitHub",
                subtitle: "@danny270793",
                icon: "chevron.left.forwardslash.chevron.right",
                color: .primary,
                url: "https://github.com/danny270793"
            )
            
            SocialButton(
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
                HStack(spacing: 12) {
                    Image(systemName: "doc.text.fill")
                        .font(.title3)
                        .foregroundStyle(.blue)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(Color.blue.opacity(0.15))
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Terms & Conditions")
                            .font(.headline)
                        
                        Text("View our terms of service")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
            }
            
            NavigationLink(destination: PrivacyPolicyView()) {
                HStack(spacing: 12) {
                    Image(systemName: "lock.shield.fill")
                        .font(.title3)
                        .foregroundStyle(.green)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(Color.green.opacity(0.15))
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Privacy Policy")
                            .font(.headline)
                        
                        Text("How we protect your data")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
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

// MARK: - Supporting Views

fileprivate struct SocialButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let url: String
    
    var body: some View {
        Button(action: {
            if let url = URL(string: url) {
                UIApplication.shared.open(url)
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(color.opacity(0.15))
                    )
                
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
