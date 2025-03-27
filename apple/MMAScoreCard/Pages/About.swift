//
//  About.swift
//  MMAScoreCard
//
//  Created by dvaca on 27/3/25.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        List {
            Section(header: Text("Application")) {
                LabeledContent("Name", value: "MMA Score Card")
                LabeledContent("Version", value: "1.0.0")
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
