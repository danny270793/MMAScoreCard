//
//  ContentView.swift
//  MMAScoreCard
//
//  Created by dvaca on 23/3/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    
    @State private var isFetching: Bool = true
    @State private var error: Error? = nil
    @Query var events: [Event]
    
    var body: some View {
        ZStack {
            List(events) { event in
                Text(event.name)
            }
            if isFetching {
                ProgressView()
            }
        }
        .alert(isPresented: .constant(error != nil)) {
            Alert(
                title: Text("Error"),
                message: Text(error!.localizedDescription),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
             Task {
                 isFetching = true
                 do {
                     let newEvents = try await Sheredog.loadEvents()
                     print("\(newEvents.count) newEvents")
                     
                     print("deleting old events")
                     for event in events {
                         context.delete(event)
                     }
                     try context.save()
                     
                     print("inserting new events")
                     for event in newEvents {
                         context.insert(event)
                     }
                     try context.save()
                     
                 } catch {
                     self.error = error
                 }
                 isFetching = false
             }
        }
    }
}

#Preview {
    ContentView()
}
