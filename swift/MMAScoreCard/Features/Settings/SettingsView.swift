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

/// Every saved response: what it is, when it was first saved and last
/// refreshed, how often it was used and its size. With Supabase these are the
/// last responses of each request, used only offline.
struct CacheView: View {
  @Environment(EventsStore.self) private var store
  @State private var entries: [CachedRequestInfo] = []

  var body: some View {
    List {
      if entries.isEmpty {
        ContentUnavailableView(L("cachedRecordsEmpty"), systemImage: "externaldrive").listRowBackground(Color.clear)
      } else {
        // Totals first, the way Settings > iPhone Storage does it.
        Section {
          LabeledContent(L("cachedRecordsCountLabel"), value: "\(entries.count)")
          LabeledContent(
            L("cachedRecordsSizeLabel"),
            value: ByteCountFormatter.string(
              fromByteCount: Int64(entries.reduce(0) { $0 + $1.sizeBytes }), countStyle: .file))
        }
        .monospacedDigit()
      }
      Section {
        ForEach(entries) { e in
          HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
              Text(label(e)).font(.headline)
              #if DEBUG
                Text(request(e.url)).font(.caption2).foregroundStyle(.secondary).lineLimit(2)
              #endif
              Text(L("cachedAtLabel", date(e.cachedAt))).font(.caption).foregroundStyle(.secondary)
              Text(L("cachedRefreshedAtLabel", date(e.refreshedAt))).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
              Text(ByteCountFormatter.string(fromByteCount: Int64(e.sizeBytes), countStyle: .file))
                .font(.subheadline.weight(.semibold)).monospacedDigit()
              Text(L(store.repo.readsFromBackend ? "cachedOfflineUseCountLabel" : "cachedReadCountLabel", e.readCount))
                .font(.caption).foregroundStyle(.secondary)
            }
          }
        }
      }
    }
    .navigationTitle(L("settingsOfflineCache"))
    .task { entries = await store.repo.cachedRequests() }
  }

  private func label(_ e: CachedRequestInfo) -> String {
    switch e.kind {
    case .upcoming: L("cachedUpcomingLabel")
    case .pastPage: L("cachedPastPageLabel", e.page ?? 0)
    case .fightCard: L("cachedFightCardLabel")
    case .fighterProfile: L("cachedFighterProfileLabel")
    case .event: L("cachedEventLabel")
    case .browse: L("cachedBrowseLabel")
    }
  }

  /// Supabase requests as "mma_fights · event.sherdog_id=eq.114293 · …"
  /// (the column list is left out); Sherdog URLs as their path.
  private func request(_ raw: String) -> String {
    guard let c = URLComponents(string: raw) else { return raw }
    guard c.path.contains("/rest/v1/") else { return c.path }
    let filters = (c.queryItems ?? []).filter { $0.name != "select" }.map { "\($0.name)=\($0.value ?? "")" }
    return ([String(c.path.split(separator: "/").last ?? "")] + filters).joined(separator: " · ")
  }

  private func date(_ d: Date) -> String {
    d.formatted(.dateTime.year().month(.abbreviated).day().hour().minute().locale(L10n.locale))
  }
}
