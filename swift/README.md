# MMA ScoreCard — SwiftUI (iOS 26, Liquid Glass)

Native port of the [Flutter app](../flutter). Same Sherdog source, same
features, no account or backend. Requires **Xcode 26** and the **iOS 26
simulator/SDK**.

## Quick start

```sh
open swift/MMAScoreCard.xcodeproj
```

No configuration is needed. Pick an iPhone or iPad simulator and run.

## Behind a corporate network

If requests fail with `NSURLErrorDomain -1200` / `-9802`, a corporate network
service is inspecting TLS and the simulator doesn't trust its root CA. Each
simulator has its own trust store, separate from the Mac's. Trust the CA in
the booted simulator (or pass `all`):

```sh
swift/scripts/trust_dev_proxy_cert.sh path/to/corporate_root_ca.pem
swift/scripts/trust_dev_proxy_cert.sh path/to/corporate_root_ca.pem all
```

Keep the certificate out of git (`*.pem` is ignored). The app needs no code change.

## Layout

| Path | What |
|---|---|
| `Packages/ScoreCardKit/Sources/ScoreCardCore` | Entities, streaks, octagon time, month/year grouping, search filters, card statistics. No I/O. |
| `Packages/ScoreCardKit/Sources/ScoreCardData` | Sherdog scraper ([SwiftSoup](https://github.com/scinfu/SwiftSoup)), source fallback, on-device JSON cache with read counts, cache-first repository. |
| `Packages/ScoreCardKit/Tests` | Swift Testing suites; the parser runs against trimmed copies of real Sherdog pages in `Fixtures/`. |
| `MMAScoreCard/App` | App entry, events store, preferences (language, theme, Face ID lock), tab shell. |
| `MMAScoreCard/Features` | Event lists, event / fight / fighter details, search, settings. |
| `MMAScoreCard/Components` | Shared rows, tags, method icons, formatting. |
| `MMAScoreCard/Resources` | Assets and `Localizable.xcstrings` (English and Spanish). |

The project uses a synchronized folder, so new files under `MMAScoreCard/`
are picked up by Xcode automatically.

## Tests

```sh
cd swift/Packages/ScoreCardKit && swift test
```

## Strings

`Localizable.xcstrings` is generated from the Flutter `.arb` files (same keys,
ICU plurals become plural variations) plus `scripts/swift_only_strings.json`.
After changing either:

```sh
python3 -I swift/scripts/arb_to_xcstrings.py
```

## Design (Liquid Glass)

- **Tabs** — the Flutter Upcoming / Past pill becomes a floating glass tab bar
  (Upcoming, Past, Settings) that minimizes on scroll, with the system
  **Search** tab instead of the floating search button.
- **Search** — the search tab covers upcoming and every loaded past event; the
  event and fighter screens get their own toolbar search field.
- **Lists** — inset grouped lists by month or year, the native row style
  instead of Material cards. Glass is only on bars and controls.
- **Details** — share buttons in the toolbar; title fights are tinted in the
  card and in the fighter history; the record shows wins and losses side by
  side with their KO / submission / decision meters.
- Pull to refresh everywhere the Flutter app had it; past events keep loading
  as you reach the end of the list.
