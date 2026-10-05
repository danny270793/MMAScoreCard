# MMA ScoreCard

UFC event and fight browsing. No account or sign-in: event data is scraped from Sherdog and cached on the device.

Flutter **3.47.2** (see [`.tool-versions`](.tool-versions)). Package / bundle ID: `io.github.danny270793.mmascorecard`.

Architecture mirrors the Wallet app: `get_it` + `flutter_bloc` + `go_router`, with `lib/core`, `lib/features/<feature>/{data,domain,presentation}`, `lib/pages`, `lib/widgets` and `lib/l10n` (see [AGENTS.md](AGENTS.md#project-structure)).

## Quick start

```sh
asdf exec flutter pub get
asdf exec flutter run
```

## Documentation

- [Run on an emulator or device](docs/getting-started.md)
- [Sync Xcode and publish to the App Store](docs/app-store.md)
- [Bump app version and Flutter SDK](docs/versioning.md)

## Agents

See [AGENTS.md](AGENTS.md) (Claude: [CLAUDE.md](CLAUDE.md)).
