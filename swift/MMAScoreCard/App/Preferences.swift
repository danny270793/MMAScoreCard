import LocalAuthentication
import SwiftUI

/// Persisted UI language: follow the device, or fixed English / Spanish.
enum AppLanguage: String, CaseIterable, Identifiable {
  case system, en, es
  var id: String { rawValue }
  var code: String? { self == .system ? nil : rawValue }
  var label: String {
    switch self {
    case .system: L("settingsLanguageSystem")
    case .en: L("settingsLanguageEnglish")
    case .es: L("settingsLanguageSpanish")
    }
  }
}

enum AppTheme: String, CaseIterable, Identifiable {
  case system, light, dark
  var id: String { rawValue }
  var colorScheme: ColorScheme? {
    switch self {
    case .system: nil
    case .light: .light
    case .dark: .dark
    }
  }
  var label: String {
    switch self {
    case .system: L("settingsThemeSystem")
    case .light: L("settingsThemeLight")
    case .dark: L("settingsThemeDark")
    }
  }
}

/// Language, theme and Face ID lock. Same `UserDefaults` keys as the Flutter app.
@MainActor @Observable
final class Preferences {
  private let defaults = UserDefaults.standard

  var language: AppLanguage {
    didSet {
      if let code = language.code {
        defaults.set(code, forKey: "language_code")
      } else {
        defaults.removeObject(forKey: "language_code")
      }
      L10n.apply(language)
    }
  }

  var theme: AppTheme {
    didSet { defaults.set(theme.rawValue, forKey: "theme_mode") }
  }

  var biometricUnlock: Bool {
    didSet { defaults.set(biometricUnlock, forKey: "app_biometric_unlock_enabled") }
  }

  init() {
    language = AppLanguage(rawValue: defaults.string(forKey: "language_code") ?? "") ?? .system
    theme = AppTheme(rawValue: defaults.string(forKey: "theme_mode") ?? "") ?? .system
    biometricUnlock = defaults.bool(forKey: "app_biometric_unlock_enabled")
    L10n.apply(language)
  }

  /// Device has an enrolled biometric (Face ID / Touch ID).
  var biometricAvailable: Bool {
    LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
  }

  func authenticate(reason: String) async -> Bool {
    (try? await LAContext().evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)) ?? false
  }
}
