//
//  About.swift
//  MMAScoreCard
//
//  Created by dvaca on 27/3/25.
//

import SwiftUI

struct AboutView: View {
    let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Unknown"
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    
    var body: some View {
        List {
            Section(header: Text("Application")) {
                LabeledContent("Name", value: appName)
                LabeledContent("Version", value: appVersion)
                LabeledContent("Build number", value: buildNumber)
            }
            Section(header: Text("Developer")) {
                LabeledContent("Name", value: "Danny Vaca")
                LabeledContent("Email", value: "danny270793@icloud.com")
            }
            Section(header: Text("Social")) {
                Button("GitHub") {
                    if let url = URL(string: "https://github.com/danny270793") {
                        UIApplication.shared.open(url)
                    }
                }
                Button("YouTube") {
                    if let url = URL(string: "https://www.youtube.com/@DannyVacaO") {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
        .navigationTitle("About")
    }
}

#Preview {
    NavigationView {
        AboutView()
    }
}
