//
//  PrivacyPolicy.swift
//  MMAScoreCard
//
//  Created by dvaca on 27/3/25.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Privacy Policy")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Last updated: \(Date.now.formatted(date: .long, time: .omitted))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Divider()
                
                // Introduction
                Section {
                    Text("1. Introduction")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("MMA ScoreCard (\"we\", \"our\", or \"us\") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our mobile application.")
                        .foregroundStyle(.secondary)
                }
                
                // Information Collection
                Section {
                    Text("2. Information We Collect")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("We collect the following types of information:")
                            .foregroundStyle(.secondary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            bulletPoint("**Usage Data**: Information about how you interact with the app, including viewed events and fighters")
                            bulletPoint("**Device Information**: Device type, operating system version, and unique device identifiers")
                            bulletPoint("**Cache Data**: Locally stored data to improve app performance")
                        }
                        .padding(.leading, 16)
                    }
                }
                
                // How We Use Information
                Section {
                    Text("3. How We Use Your Information")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("We use the collected information to:")
                            .foregroundStyle(.secondary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            bulletPoint("Provide and maintain the application")
                            bulletPoint("Improve user experience and app functionality")
                            bulletPoint("Analyze usage patterns and optimize performance")
                            bulletPoint("Cache data locally to reduce loading times")
                        }
                        .padding(.leading, 16)
                    }
                }
                
                // Data Storage
                Section {
                    Text("4. Data Storage and Security")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("All data is stored locally on your device. We use industry-standard security measures to protect your information. However, no method of electronic storage is 100% secure, and we cannot guarantee absolute security.")
                        .foregroundStyle(.secondary)
                }
                
                // Third-Party Services
                Section {
                    Text("5. Third-Party Services")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("We retrieve fight data from public sources including Sherdog.com. When accessing this data, you may be subject to their respective privacy policies. We do not share your personal information with third parties.")
                        .foregroundStyle(.secondary)
                }
                
                // Data Sharing
                Section {
                    Text("6. Data Sharing and Disclosure")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("We do not sell, trade, or transfer your personal information to third parties. We may disclose information if required by law or to protect our rights and safety.")
                        .foregroundStyle(.secondary)
                }
                
                // User Rights
                Section {
                    Text("7. Your Rights")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("You have the right to:")
                            .foregroundStyle(.secondary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            bulletPoint("Access the data we store about you")
                            bulletPoint("Request deletion of your data")
                            bulletPoint("Opt-out of data collection features")
                            bulletPoint("Clear cached data through app settings")
                        }
                        .padding(.leading, 16)
                    }
                }
                
                // Children's Privacy
                Section {
                    Text("8. Children's Privacy")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Our application is not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13. If you believe we have collected information from a child under 13, please contact us immediately.")
                        .foregroundStyle(.secondary)
                }
                
                // Changes to Privacy Policy
                Section {
                    Text("9. Changes to This Privacy Policy")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the \"Last updated\" date.")
                        .foregroundStyle(.secondary)
                }
                
                // Contact
                Section {
                    Text("10. Contact Us")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("If you have any questions about this Privacy Policy, please contact us at:")
                        .foregroundStyle(.secondary)
                    
                    Link("danny270793@icloud.com", destination: URL(string: "mailto:danny270793@icloud.com")!)
                        .font(.subheadline)
                        .padding(.leading, 16)
                }
                
                // Consent
                Section {
                    Text("11. Consent")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("By using our application, you consent to our Privacy Policy and agree to its terms.")
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundStyle(.secondary)
            Text(text)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
}

