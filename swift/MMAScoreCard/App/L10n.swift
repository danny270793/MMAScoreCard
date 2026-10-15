import Foundation

/// Looks up strings in the app's String Catalog (keys come from the Flutter
/// `.arb` files), honoring the in-app language override.
enum L10n {
  /// Bundle of the chosen language; `.main` follows the device.
  nonisolated(unsafe) static var bundle: Bundle = .main
  nonisolated(unsafe) static var locale: Locale = .current

  static func apply(_ language: AppLanguage) {
    if let code = language.code, let path = Bundle.main.path(forResource: code, ofType: "lproj"),
      let b = Bundle(path: path)
    {
      bundle = b
      locale = Locale(identifier: code)
    } else {
      bundle = .main
      locale = .current
    }
  }
}

/// Localized string for `key`; `args` fill `%1$@` / `%1$lld`… in order, and
/// plural variations pick the form for the number passed.
func L(_ key: String, _ args: any CVarArg...) -> String {
  let format = L10n.bundle.localizedString(forKey: key, value: key, table: nil)
  guard !args.isEmpty else { return format }
  return String(format: format, locale: L10n.locale, arguments: args)
}
