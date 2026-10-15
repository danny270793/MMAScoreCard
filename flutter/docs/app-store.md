# Sync Xcode and publish to the App Store

Always open **`ios/Runner.xcworkspace`**, never `Runner.xcodeproj`. CocoaPods and Flutter plugins live in the workspace.

Run a Flutter build (or `--config-only`) **before** you Archive in Xcode so `ios/Flutter/Generated.xcconfig` is up to date.

## Sync the iOS project

```sh
asdf exec flutter pub get
asdf exec flutter build ios --config-only --release
cd ios && pod install && cd ..
open ios/Runner.xcworkspace
```

`--config-only` refreshes `ios/Flutter/Generated.xcconfig` without a full compile.

## Signing

In Xcode, select the **Runner** target → **Signing & Capabilities**:

- Team and unique bundle identifier
- Automatically manage signing (or install your distribution profile)
- Enable capabilities this app needs (Sign in with Apple is not required; Face ID uses `NSFaceIDUsageDescription` in `Info.plist`)

## Preferred store build

From the repo root (produces an IPA):

```sh
asdf exec flutter build ipa
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
- Archiving in Xcode without first running a Flutter build (stale `Generated.xcconfig`)
- Reusing the same `version` `+build` as a previous upload (App Store Connect rejects it)
