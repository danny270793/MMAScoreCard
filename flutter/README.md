# MMA ScoreCard

UFC event and fight browsing. No account or sign-in: event data is scraped from Sherdog and cached on the device.

Flutter **3.47.2** (see [`.tool-versions`](.tool-versions)). Package / bundle ID: `io.github.danny270793.mmascorecard`.

Architecture mirrors the Wallet app: `get_it` + `flutter_bloc` + `go_router`, with `lib/core`, `lib/features/<feature>/{data,domain,presentation}`, `lib/pages`, `lib/widgets` and `lib/l10n` (see [AGENTS.md](../AGENTS.md#project-structure)).

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

See [AGENTS.md](../AGENTS.md) (Claude: [CLAUDE.md](../CLAUDE.md)).

## Deploy

`./scripts/deploy.sh` builds a release APK and publishes it to Firebase App Distribution. Before the first run, copy `scripts/.env.deploy.example` to `scripts/.env.deploy` (gitignored), set `FIREBASE_GROUPS` to the tester group alias, and run `firebase login`. `--bump` raises the build number and `--dry-run` prints the commands without running them.
