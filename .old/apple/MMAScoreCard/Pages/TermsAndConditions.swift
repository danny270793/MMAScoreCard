//
//  TermsAndConditions.swift
//  MMAScoreCard
//
//  Created by dvaca on 27/3/25.
//

import SwiftUI

struct TermsAndConditionsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Terms and Conditions")
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
                    
                    Text("Welcome to MMA ScoreCard. By using this application, you agree to these terms and conditions. Please read them carefully.")
                        .foregroundStyle(.secondary)
                }
                
                // Use of Application
                Section {
                    Text("2. Use of Application")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("This application is provided for informational purposes only. Users are granted a limited license to:")
                            .foregroundStyle(.secondary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            bulletPoint("View MMA event information and fight statistics")
                            bulletPoint("Track fighter records and career statistics")
                            bulletPoint("Access historical fight data")
                        }
                        .padding(.leading, 16)
                    }
                }
                
                // Data Sources
                Section {
                    Text("3. Data Sources")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Fight data and statistics are sourced from publicly available information. While we strive for accuracy, we cannot guarantee that all information is complete or error-free.")
                        .foregroundStyle(.secondary)
                }
                
                // Intellectual Property
                Section {
                    Text("4. Intellectual Property")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("All content, trademarks, and data in this application, including but not limited to software, databases, text, graphics, icons, and hyperlinks, are the property of or licensed to MMA ScoreCard and protected from infringement by domestic and international legislation.")
                        .foregroundStyle(.secondary)
                }
                
                // User Conduct
                Section {
                    Text("5. User Conduct")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Users agree not to misuse the application or help anyone else do so. You may not attempt to reverse engineer, decompile, or extract the source code of the application.")
                        .foregroundStyle(.secondary)
                }
                
                // Disclaimer
                Section {
                    Text("6. Disclaimer")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("This application is provided \"as is\" without any warranties, expressed or implied. We do not warrant that the application will be uninterrupted or error-free.")
                        .foregroundStyle(.secondary)
                }
                
                // Limitation of Liability
                Section {
                    Text("7. Limitation of Liability")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("In no event shall MMA ScoreCard or its developers be liable for any damages arising out of the use or inability to use this application.")
                        .foregroundStyle(.secondary)
                }
                
                // Changes to Terms
                Section {
                    Text("8. Changes to Terms")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("We reserve the right to modify these terms at any time. Continued use of the application after changes constitutes acceptance of the modified terms.")
                        .foregroundStyle(.secondary)
                }
                
                // Contact
                Section {
                    Text("9. Contact Information")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("If you have any questions about these Terms and Conditions, please contact us at:")
                        .foregroundStyle(.secondary)
                    
                    Link("danny270793@icloud.com", destination: URL(string: "mailto:danny270793@icloud.com")!)
                        .font(.subheadline)
                        .padding(.leading, 16)
                }
            }
            .padding()
        }
        .navigationTitle("Terms & Conditions")
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
        TermsAndConditionsView()
    }
}

