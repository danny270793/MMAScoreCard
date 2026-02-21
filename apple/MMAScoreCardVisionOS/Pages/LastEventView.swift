//
//  LastEventView.swift
//  MMAScoreCard
//
//  Created by dvaca on 31/3/25.
//

import SwiftUI

struct LastEventView: View {
    @Environment(\.mmaDataProvider) private var dataProvider
    @State private var isFetching: Bool = true
    @State private var error: Error? = nil
    @State var event: Event? = nil
    
    func onAppear() {
        Task {
            await loadFights(forceRefresh: false)
        }
    }
    
    func onRefresh() {
        Task {
            await loadFights(forceRefresh: true)
        }
    }
    
    func loadFights(forceRefresh: Bool) async {
        Task {
            isFetching = true
            do {
                let events = try await dataProvider.loadEvents(forceRefresh: forceRefresh)
                let pastEvents = events.data.filter { event in event.date <= Date.now}
                event = pastEvents[0]
            } catch {
                self.error = error
            }
            isFetching = false
        }
    }
    
    var body: some View {
        ZStack {
            if event != nil {
                FigthsList(event: event!)
            }
        }
        .onAppear(perform: onAppear)
        .refreshable(action: onRefresh)
        .overlay {
            if isFetching {
                ProgressView()
            }
        }
        .alert(isPresented: .constant(error != nil)) {
            Alert(
                title: Text("Error"),
                message: Text(error!.localizedDescription),
                dismissButton: .default(Text("OK")) {
                    error = nil
                }
            )
        }
    }
}
