//
//  FighterDetails.swift
//  MMAScoreCard
//
//  Created by dvaca on 24/3/25.
//

import SwiftUI
import SwiftData

struct FighterDetails: View {
    let figther: Fighter
    @State private var isFetching: Bool = true
    @State private var error: Error? = nil
    //@State private var image: Data? = nil
    @State private var searchText = ""
    @State private var fighterRecord: FighterRecord? = nil
    
    func onRefresh() {
        Task {
            isFetching = true
            do {
                //image = try await Sheredog.loadImage(url: figther.image)
                fighterRecord = try await Sheredog.loadRecord(fighter: figther)
            } catch {
                self.error = error
            }
            isFetching = false
        }
    }
    
    private var filteredFights: [Record] {
        if fighterRecord == nil {
            return []
        }
        
        if searchText.isEmpty {
            return fighterRecord!.fights
        } else {
            return fighterRecord!.fights.filter { fight in
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
        List {
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
                if fighterRecord != nil {
                    LabeledContent("Nationality", value: fighterRecord!.nationality)
                    LabeledContent("Age", value: fighterRecord!.age)
                    LabeledContent("Height", value: fighterRecord!.height)
                    LabeledContent("Weight", value: fighterRecord!.weight)
                }
            }
            if fighterRecord != nil {
                Section(header: Text("Record")) {
                    
                    LabeledContent("WIN", value: "\(fighterRecord!.fights.filter { fight in fight.status == FighterStatus.win }.count)")
                    LabeledContent("LOSS", value: "\(fighterRecord!.fights.filter { fight in fight.status == FighterStatus.loss }.count)")
                    LabeledContent("DRAW", value: "\(fighterRecord!.fights.filter { fight in fight.status == FighterStatus.draw }.count)")
                    LabeledContent("NC", value: "\(fighterRecord!.fights.filter { fight in fight.status == FighterStatus.nc }.count)")
                }
                Section(header: Text("Fights")) {
                    ForEach(filteredFights) { fight in
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
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear(perform: onRefresh)
        .refreshable(action: onRefresh)
        .searchable(text: $searchText)
        .navigationTitle(figther.name)
    }
}

#Preview {
    NavigationView {
        FighterDetails(figther: Fighter(name: "Merab Dvalishvili", image: URL(string: "https://www.sherdog.com/image_crop/44/44/_images/fighter/1648844898903_20220401042811_Merab_Dvalishvili_ff.JPG")!, link: URL(string: "https://www.sherdog.com/fighter/Merab-Dvalishvili-157355")!))
    }
}
