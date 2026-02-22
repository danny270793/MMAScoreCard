//
//  CacheListView.swift
//  MMAScoreCard
//

import SwiftUI

struct CacheListView: View {
    @State private var cachedItems: [LocalStorage.CachedURLInfo] = []
    @State private var error: Error?
    
    var body: some View {
        List {
            if let error = error {
                Section {
                    Text(error.localizedDescription)
                        .foregroundStyle(.red)
                }
            }
            
            if cachedItems.isEmpty && error == nil {
                ContentUnavailableView(
                    String(localized: "cache.empty_title"),
                    systemImage: "externaldrive.badge.clock",
                    description: Text(String(localized: "cache.empty_description"))
                )
            } else {
                Section {
                    ForEach(cachedItems, id: \.url) { item in
                        CacheRowView(item: item)
                    }
                }
            }
        }
        .navigationTitle(String(localized: "cache.title"))
        .onAppear(perform: loadCacheList)
        .refreshable(action: loadCacheList)
    }
    
    private func loadCacheList() {
        do {
            cachedItems = try LocalStorage.listAllCachedURLs()
            error = nil
        } catch {
            self.error = error
        }
    }
}

private struct CacheRowView: View {
    let item: LocalStorage.CachedURLInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(item.url)
                .font(.subheadline)
                .lineLimit(2)
                .textSelection(.enabled)

            Label(
                    item.cachedAt.formatted(.dateTime.day().month(.abbreviated).year().hour().minute()),
                    systemImage: "clock"
                )
                
                .font(.caption)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 12) {
                Label(
                    LocalStorage.minutesToText(minutes: Int(Date.now.timeIntervalSince(item.cachedAt) / 60)),
                    systemImage: "clock"
                ).font(.caption)
                .foregroundStyle(.secondary)
                
                Text("•")
                    .foregroundStyle(.secondary)
                
                Text(String(format: String(localized: "cache.access_count"), item.accessCount))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        CacheListView()
    }
}
