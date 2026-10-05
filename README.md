# MMA ScoreCard

UFC event and fight browsing. Auth is optional (continue without an account). Event data is not stored per user in Supabase.

Flutter **3.47.2** (see [`.tool-versions`](.tool-versions)). Package / bundle ID: `io.github.danny270793.mmascorecard`.

Architecture mirrors the Wallet app: `get_it` + `flutter_bloc` + `go_router`, with `lib/core`, `lib/features/<feature>/{data,domain,presentation}`, `lib/pages`, `lib/widgets` and `lib/l10n` (see [AGENTS.md](AGENTS.md#project-structure)).

## Quick start

```sh
cp .env.example.json .env.json   # then fill in real values
asdf exec flutter pub get
asdf exec flutter run --dart-define-from-file=.env.json
```

## Documentation

- [Run on an emulator or device](docs/getting-started.md)
- [Fill `.env.json`](docs/environment.md)
- [Sync Xcode and publish to the App Store](docs/app-store.md)
- [Bump app version and Flutter SDK](docs/versioning.md)

## Agents

See [AGENTS.md](AGENTS.md) (Claude: [CLAUDE.md](CLAUDE.md)).
