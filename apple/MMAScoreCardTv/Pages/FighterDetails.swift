//
//  FighterDetails.swift
//  MMAScoreCard
//
//  Created by dvaca on 24/3/25.
//

import SwiftUI
import SwiftData

struct FighterDetails: View {
    @Environment(\.mmaDataProvider) private var dataProvider
    let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 40), count: 2)
    
    let figther: Fighter
    @State private var isFetching: Bool = true
    @State private var error: Error? = nil
    //@State private var image: Data? = nil
    @State private var searchText = ""
    @State private var response: SherdogResponse<FighterRecord>? = nil
    
    func onAppear() {
        Task {
            await loadRecord(forceRefresh: false)
        }
    }
    
    func onRefresh() {
        Task {
            await loadRecord(forceRefresh: true)
        }
    }
    
    func loadRecord(forceRefresh: Bool) async {
        Task {
            isFetching = true
            do {
                //image = try await Sheredog.loadImage(url: figther.image)
                response = try await dataProvider.loadRecord(fighter: figther, forceRefresh: forceRefresh)
            } catch {
                self.error = error
            }
            isFetching = false
        }
    }
    
    private var filteredFights: [Record] {
        if response == nil {
            return []
        }
        
        if searchText.isEmpty {
            return response!.data.fights
        } else {
            return response!.data.fights.filter { fight in
                fight.figther.lowercased().contains(searchText.lowercased()) ||
                fight.status.rawValue.lowercased().contains(searchText.lowercased()) ||
                fight.method.lowercased().contains(searchText.lowercased()) ||
                fight.round.lowercased().contains(searchText.lowercased()) ||
                fight.time.lowercased().contains(searchText.lowercased()) ||
                (fight.referee != nil && fight.referee!.lowercased().contains(searchText.lowercased()))
            }
        }
    }
    
    var body: some View {
        ScrollView {
            //            HStack {
            //                Spacer()
            //                if let image = image, let uiImage = UIImage(data: image) {
            //                    Image(uiImage: uiImage)
            //                        .resizable()
            //                        .scaledToFit()
            //                        .frame(width: 50, height: 50)
            //                        .clipShape(Circle())
            //                } else {
            //                    ProgressView()
            //                }
            //                Spacer()
            //            }
            Section(header: Text("Fighter")) {
                LabeledContent("Name", value: figther.name)
                if response?.data != nil {
                    LabeledContent("Nationality", value: response!.data.nationality)
                    LabeledContent("Age", value: response!.data.age)
                    LabeledContent("Height", value: response!.data.height)
                    LabeledContent("Weight", value: response!.data.weight)
                }
            }
            if response?.data != nil {
                Section(header: Text("Record")) {
                    LabeledContent("WIN", value: "\(response!.data.fights.filter { fight in fight.status == FighterStatus.win }.count)")
                    LabeledContent("LOSS", value: "\(response!.data.fights.filter { fight in fight.status == FighterStatus.loss }.count)")
                    LabeledContent("DRAW", value: "\(response!.data.fights.filter { fight in fight.status == FighterStatus.draw }.count)")
                    LabeledContent("NC", value: "\(response!.data.fights.filter { fight in fight.status == FighterStatus.nc }.count)")
                }
                Section(header: Text("Fights")) {
                    LazyVGrid(columns: columns) {
                        ForEach(filteredFights) { fight in
                            Button {} label: {
                                VStack {
                                    Text("\(fight.figther)")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text("\(fight.status.rawValue) by \(fight.method)")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text("Round \(fight.round) at \(fight.time)")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    if fight.referee != nil {
                                        Text("\(fight.referee!)")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    Text("\(fight.event)")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text("\(fight.date.ISO8601Format().split(separator: "T")[0])")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                    }
                }
            }
            if response?.data != nil || response?.timeCached != nil {
                Section("Metadata") {
                    LabeledContent("Cached at", value: response!.cachedAt!.ISO8601Format())
                    LabeledContent("Time cached", value: response!.timeCached!)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Text("\(filteredFights.count) Fights")
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
        .searchable(text: $searchText)
        .navigationTitle(figther.name)
    }
}

#Preview {
    NavigationView {
        FighterDetails(figther: Fighter(name: "Merab Dvalishvili", image: URL(string: "https://www.sherdog.com/image_crop/44/44/_images/fighter/1648844898903_20220401042811_Merab_Dvalishvili_ff.JPG")!, link: URL(string: "https://www.sherdog.com/fighter/Islam-Makhachev-76836")!))
    }
}
