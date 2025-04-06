//
//  EventGraph.swift
//  MMAScoreCard
//
//  Created by dvaca on 6/4/25.
//

import SwiftUI

struct EventGraph : View {
    let event: Event
    @State private var isFetching: Bool = true
    @State private var error: Error? = nil
    @State var response: SherdogResponse<EventStats>? = nil
    
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
                response = try await Sheredog.getEventStats(event: event, forceRefresh: forceRefresh)
            } catch {
                self.error = error
            }
            isFetching = false
        }
    }
    
    func getDetail(title: String, color: Color, value: Int, percentage: Double) -> any View {
        GeometryReader { geometry in
            let textSpace = 0.3
            let labelWidth = geometry.size.width * textSpace
            let minimunBarSpace = 0.2
            let barMinWidht = geometry.size.width * minimunBarSpace
            
            HStack{
                Text(title)
                    .frame(width: labelWidth)
                ZStack {
                    Rectangle()
                        .fill(color)
                        .cornerRadius(10)
                        .frame(width: barMinWidht + ((geometry.size.width - labelWidth - barMinWidht) * percentage))
                    Text(String(value))
                        .foregroundColor(.white)
                }
                Spacer()
            }
        }
    }
    
    var body: some View {
        List {
            Section(header: Text("Event")) {
                LabeledContent("Name", value: event.name)
                LabeledContent("Location", value: event.location)
                LabeledContent("Date", value: event.date.ISO8601Format().split(separator: "T")[0])
            }
            if response != nil {
                let fights = Double(response!.data.kos + response!.data.decisions + response!.data.submissions)
                let kos = Double(response!.data.kos)/fights
                let submissions = Double(response!.data.submissions)/fights
                let decissions = Double(response!.data.decisions)/fights
                
                Section(header: Text("Graphs")) {
                    AnyView(getDetail(title: "KO", color: Color.red, value: response!.data.kos, percentage: kos))
                    AnyView(getDetail(title: "Submission", color: Color.green, value: response!.data.submissions, percentage: submissions))
                    AnyView(getDetail(title: "Decision", color: Color.blue, value: response!.data.decisions, percentage: decissions))
                }
                
            }
        }
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
        .onAppear(perform: onAppear)
        .refreshable(action: onRefresh)
        .navigationTitle("Graph")
    }
}

#Preview {
    NavigationView {
        EventGraph(event: Event(name: "UFC 313", fight: "Alex Pereira vs. Ankalaev", location: "Los Angeles", date: Date(), url: "https://www.sherdog.com/events/UFC-on-ESPN-64-Moreno-vs-Erceg-105790"))
    }
}
