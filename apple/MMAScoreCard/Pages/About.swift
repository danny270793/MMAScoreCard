//
//  About.swift
//  MMAScoreCard
//
//  Created by dvaca on 27/3/25.
//

import SwiftUI

struct AboutView: View {
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        
    
    var body: some View {
        List {
            Section(header: Text("Application")) {
                LabeledContent("Name", value: "MMA Score Card")
                LabeledContent("Version", value: appVersion)
                LabeledContent("Build number", value: buildNumber)
            }
            Section(header: Text("Developer")) {
                LabeledContent("Name", value: "Danny Vaca")
                LabeledContent("Email", value: "danny270793@icloud.com")
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
