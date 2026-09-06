# Run on an emulator or device

Pin the Flutter SDK with [asdf](https://asdf-vm.com/) using [`.tool-versions`](../.tool-versions). Prefix Flutter commands with `asdf exec` if that SDK is not already first on your `PATH`.

## One-time setup

```sh
asdf install
cp .env.example.json .env.json   # then follow docs/environment.md
asdf exec flutter pub get
```

Start an Android emulator from Android Studio or `emulator -list-avds` / `emulator -avd <name>`, or an iOS simulator from Xcode / `open -a Simulator`.

## Start the app

```sh
asdf exec flutter devices
asdf exec flutter run --dart-define-from-file=.env.json
```

Target a device explicitly:

```sh
asdf exec flutter run --dart-define-from-file=.env.json -d emulator-5554
asdf exec flutter run --dart-define-from-file=.env.json -d "iPhone 16"
```

Release-style run:

```sh
asdf exec flutter run --release --dart-define-from-file=.env.json
```

Do not use a bare `flutter run` for this project. `SUPABASE_URL` and `SUPABASE_ANON_KEY` are compile-time defines; without `--dart-define-from-file=.env.json` the app will not start correctly.
