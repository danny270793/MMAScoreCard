# Sync Xcode and publish to the App Store

Always open **`ios/Runner.xcworkspace`**, never `Runner.xcodeproj`. CocoaPods and Flutter plugins live in the workspace.

Dart defines (`SUPABASE_*`) must be generated **before** you Archive in Xcode. A Xcode-only archive without a prior Flutter build will ship an app without those keys.

## Sync the iOS project

```sh
asdf exec flutter pub get
asdf exec flutter build ios --config-only --release --dart-define-from-file=.env.json
cd ios && pod install && cd ..
open ios/Runner.xcworkspace
```

`--config-only` refreshes `ios/Flutter/Generated.xcconfig` (including dart-defines) without a full compile.

## Signing

In Xcode, select the **Runner** target → **Signing & Capabilities**:

- Team and unique bundle identifier
- Automatically manage signing (or install your distribution profile)
- Enable capabilities this app needs (Sign in with Apple is not required; Face ID uses `NSFaceIDUsageDescription` in `Info.plist`)

## Preferred store build

From the repo root (embeds dart-defines and produces an IPA):

```sh
asdf exec flutter build ipa --dart-define-from-file=.env.json
```

Upload `build/ios/ipa/*.ipa` with **Transporter** or Xcode → **Window** → **Organizer**.

## Archive from Xcode

After the sync commands above:

1. Product → Destination → **Any iOS Device**
2. Product → **Archive**
3. Distribute App → App Store Connect

Bump the version **before** every store upload. See [versioning.md](versioning.md).

## Common failures

- Archiving `Runner.xcodeproj` instead of the workspace
- Archiving without `--dart-define-from-file=.env.json` (login will fail)
- Reusing the same `version` `+build` as a previous upload (App Store Connect rejects it)
