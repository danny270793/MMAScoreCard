import SwiftUI

@main
struct MMAScoreCardApp: App {
  @State private var store = EventsStore()
  @State private var prefs = Preferences()

  var body: some Scene {
    WindowGroup {
      RootView()
        .environment(store)
        .environment(prefs)
        .environment(\.locale, L10n.locale)
        .preferredColorScheme(prefs.theme.colorScheme)
        // Rebuild every screen when the language changes so all strings refresh.
        .id(prefs.language)
    }
  }
}

struct RootView: View {
  @Environment(Preferences.self) private var prefs
  @Environment(\.scenePhase) private var scenePhase
  /// There is no sign-in, so a cold start locks too when Face ID is on.
  @State private var locked = false
  @State private var wasBackgrounded = false

  var body: some View {
    MainTabView()
      .overlay {
        if locked {
          BiometricLockView { locked = false }
            .transition(.opacity)
        }
      }
      .animation(.smooth, value: locked)
      .onAppear { locked = prefs.biometricUnlock && prefs.biometricAvailable }
      .onChange(of: scenePhase) { _, phase in
        if phase == .background {
          wasBackgrounded = true
        } else if phase == .active, wasBackgrounded {
          wasBackgrounded = false
          if prefs.biometricUnlock, prefs.biometricAvailable { locked = true }
        }
      }
  }
}

/// Full-screen gate shown on launch and resume while biometric unlock is on.
struct BiometricLockView: View {
  @Environment(Preferences.self) private var prefs
  let onUnlocked: () -> Void
  @State private var busy = false

  var body: some View {
    VStack(spacing: 20) {
      Image(systemName: "lock.fill")
        .font(.system(size: 52))
        .foregroundStyle(.tint)
      Text(L("biometricLockTitle")).font(.title2.bold())
      Text(L("biometricLockBody"))
        .multilineTextAlignment(.center)
        .foregroundStyle(.secondary)
      Button {
        Task { await unlock() }
      } label: {
        Label(L("biometricLockUnlockButton"), systemImage: "faceid")
          .padding(.horizontal, 8)
      }
      .buttonStyle(.glassProminent)
      .controlSize(.large)
      .disabled(busy)
    }
    .padding(32)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.background)
    .task { await unlock() }
  }

  private func unlock() async {
    guard !busy else { return }
    busy = true
    defer { busy = false }
    if !prefs.biometricUnlock || !prefs.biometricAvailable {
      onUnlocked()
      return
    }
    if await prefs.authenticate(reason: L("settingsBiometricResumeReason")) { onUnlocked() }
  }
}
