import ScoreCardCore
import StoreKit
import SwiftUI

struct SettingsView: View {
  @Environment(Preferences.self) private var prefs
  @Environment(\.requestReview) private var requestReview
  @State private var notice: String?

  var body: some View {
    @Bindable var prefs = prefs
    Form {
      Section(L("settingsSecuritySection")) {
        Toggle(isOn: Binding(get: { prefs.biometricUnlock }, set: { on in Task { await setBiometric(on) } })) {
          VStack(alignment: .leading) {
            Text(L("settingsBiometricUnlockTitle"))
            Text(L(prefs.biometricAvailable ? "settingsBiometricUnlockSubtitle" : "settingsBiometricUnavailable"))
              .font(.caption).foregroundStyle(.secondary)
          }
        }
        .disabled(!prefs.biometricAvailable && !prefs.biometricUnlock)
      }

      Section(L("settingsAppearance")) {
        Picker(L("settingsLanguage"), selection: $prefs.language) {
          ForEach(AppLanguage.allCases) { Text($0.label).tag($0) }
        }
        Picker(L("settingsTheme"), selection: $prefs.theme) {
          ForEach(AppTheme.allCases) { Text($0.label).tag($0) }
        }
      }

      Section(L("settingsDataSection")) {
        NavigationLink {
          CacheView()
        } label: {
          VStack(alignment: .leading) {
            Text(L("settingsOfflineCache"))
            Text(L("settingsOfflineCacheSubtitle")).font(.caption).foregroundStyle(.secondary)
          }
        }
      }

      Section(L("settingsAboutSection")) {
        NavigationLink(L("settingsAboutApp")) { LegalView(kind: .about) }
        Button(L("settingsRateAppStore")) { requestReview() }
        NavigationLink(L("settingsPrivacyPolicy")) { LegalView(kind: .privacy) }
        NavigationLink(L("settingsTermsOfUse")) { LegalView(kind: .terms) }
      }
    }
    .navigationTitle(L("settings"))
    .alert(notice ?? "", isPresented: Binding(get: { notice != nil }, set: { if !$0 { notice = nil } })) {
      Button("OK", role: .cancel) {}
    }
  }

  private func setBiometric(_ on: Bool) async {
    if !on {
      prefs.biometricUnlock = false
      return
    }
    guard prefs.biometricAvailable else {
      notice = L("settingsBiometricUnavailable")
      return
    }
    if await prefs.authenticate(reason: L("settingsBiometricAuthReason")) { prefs.biometricUnlock = true }
  }
}

/// Every cached Sherdog request: what it is, when it was cached and last
/// refreshed, how often it was read and its size.
struct CacheView: View {
  @Environment(EventsStore.self) private var store
  @State private var entries: [CachedRequestInfo] = []

  var body: some View {
    List {
      if entries.isEmpty {
        ContentUnavailableView(L("cachedRecordsEmpty"), systemImage: "externaldrive").listRowBackground(Color.clear)
      }
      ForEach(entries) { e in
        HStack(alignment: .top) {
          VStack(alignment: .leading, spacing: 2) {
            Text(label(e)).font(.headline)
            #if DEBUG
              Text(URL(string: e.url)?.path ?? e.url).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
            #endif
            Text(L("cachedAtLabel", date(e.cachedAt))).font(.caption).foregroundStyle(.secondary)
            Text(L("cachedRefreshedAtLabel", date(e.refreshedAt))).font(.caption).foregroundStyle(.secondary)
          }
          Spacer()
          VStack(alignment: .trailing, spacing: 2) {
            Text(ByteCountFormatter.string(fromByteCount: Int64(e.sizeBytes), countStyle: .file))
              .font(.subheadline.weight(.semibold)).monospacedDigit()
            Text(L("cachedReadCountLabel", e.readCount)).font(.caption).foregroundStyle(.secondary)
          }
        }
      }
    }
    .navigationTitle(L("settingsOfflineCache"))
    .safeAreaInset(edge: .bottom) {
      if !entries.isEmpty {
        let total = entries.reduce(0) { $0 + $1.sizeBytes }
        Text("\(entries.count) · \(ByteCountFormatter.string(fromByteCount: Int64(total), countStyle: .file))")
          .font(.headline).monospacedDigit()
          .frame(maxWidth: .infinity)
          .padding(.vertical, 12)
          .glassEffect(.regular, in: .capsule)
          .padding(.horizontal, 16)
      }
    }
    .task { entries = await store.repo.cachedRequests() }
  }

  private func label(_ e: CachedRequestInfo) -> String {
    switch e.kind {
    case .upcoming: L("cachedUpcomingLabel")
    case .pastPage: L("cachedPastPageLabel", e.page ?? 0)
    case .fightCard: L("cachedFightCardLabel")
    case .fighterProfile: L("cachedFighterProfileLabel")
    }
  }

  private func date(_ d: Date) -> String {
    d.formatted(.dateTime.year().month(.abbreviated).day().hour().minute().locale(L10n.locale))
  }
}
