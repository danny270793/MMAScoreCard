# Run on an emulator or device

Pin the Flutter SDK with [asdf](https://asdf-vm.com/) using [`.tool-versions`](../.tool-versions). Prefix Flutter commands with `asdf exec` if that SDK is not already first on your `PATH`.

## One-time setup

```sh
asdf install
asdf exec flutter pub get
```

Start an Android emulator from Android Studio or `emulator -list-avds` / `emulator -avd <name>`, or an iOS simulator from Xcode / `open -a Simulator`.

## Start the app

```sh
asdf exec flutter devices
asdf exec flutter run
```

Target a device explicitly:

```sh
asdf exec flutter run -d emulator-5554
asdf exec flutter run -d "iPhone 16"
```

Release-style run:

```sh
asdf exec flutter run --release
```

`scripts/start.sh` and `scripts/build.sh` wrap the same commands. No `--dart-define` values are required.
