# Versions: pubspec, Android, iOS, Flutter SDK

## App version (Android + iOS)

Edit **only** [`pubspec.yaml`](../pubspec.yaml):

```yaml
version: 1.0.0+1
```

| Part | Meaning | Android | iOS |
|------|---------|---------|-----|
| `1.0.0` | User-visible version | `versionName` | `CFBundleShortVersionString` (`FLUTTER_BUILD_NAME`) |
| `1` | Monotonic build number | `versionCode` | `CFBundleVersion` (`FLUTTER_BUILD_NUMBER`) |

`android/app/build.gradle.kts` already uses `flutter.versionName` / `flutter.versionCode`. iOS `Info.plist` already uses `$(FLUTTER_BUILD_NAME)` / `$(FLUTTER_BUILD_NUMBER)`. Do **not** hardcode versions there.

Rules:

- Every App Store or Play upload needs a **higher** `+build` than the last one.
- After changing `version`, run `asdf exec flutter pub get` so generated iOS config updates.

## Flutter SDK

1. Set the SDK in [`.tool-versions`](../.tool-versions), e.g. `flutter 3.47.2-stable`.
2. `asdf install` (or `asdf install flutter`).
3. Align [`pubspec.yaml`](../pubspec.yaml) `environment.sdk` with that Dart SDK (`flutter --version` prints it).
4. Refresh lockfiles and iOS pods:

   ```sh
   asdf exec flutter pub get
   cd ios && pod install && cd ..
   asdf exec flutter analyze
   asdf exec flutter test
   ```

5. If you ship from Xcode, re-run the [App Store sync](app-store.md) so `Generated.xcconfig` matches the new SDK.
