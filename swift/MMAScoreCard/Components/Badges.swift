import ScoreCardCore
import SwiftUI

/// Small capsule tag ("WIN", "TITLE FIGHT", "AMATEUR").
struct Tag: View {
  let text: String
  var color: Color = .secondary
  var prominent = true

  var body: some View {
    Text(text.uppercased())
      .font(.caption2.weight(.bold))
      .tracking(0.4)
      .padding(.horizontal, 7)
      .padding(.vertical, 2)
      .foregroundStyle(prominent ? .white : color)
      .background(prominent ? color : color.opacity(0.15), in: .capsule)
  }
}

struct OutcomeTag: View {
  let outcome: FightOutcome

  var body: some View {
    if let label = outcome.label { Tag(text: label, color: outcome.color) }
  }
}

/// KO/TKO, submission or decision icon in a tinted circle.
struct MethodIcon: View {
  let method: String?
  var size: CGFloat = 32

  var body: some View {
    let kind = method.map(FightMethodKind.init(method:))
    Image(systemName: kind?.symbol ?? "clock")
      .font(.system(size: size * 0.45, weight: .semibold))
      .foregroundStyle(kind?.color ?? .secondary)
      .frame(width: size, height: size)
      .background((kind?.color ?? .secondary).opacity(0.14), in: .circle)
  }
}

/// Large number above a caption, used for the card and bout statistics.
struct StatTile: View {
  let symbol: String
  let color: Color
  let value: String
  let label: String

  var body: some View {
    VStack(spacing: 4) {
      Image(systemName: symbol).foregroundStyle(color)
      Text(value).font(.title2.bold()).monospacedDigit()
      Text(label).font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity)
    .accessibilityElement(children: .combine)
  }
}

/// Spinner, error with retry, or empty state for a list that has no rows yet.
struct LoadStateView: View {
  enum Kind {
    case loading
    case failed(String, retry: () async -> Void)
    case empty(String, systemImage: String)
  }

  let kind: Kind

  var body: some View {
    switch kind {
    case .loading:
      ProgressView().controlSize(.large).frame(maxWidth: .infinity, maxHeight: .infinity)
    case .failed(let message, let retry):
      ContentUnavailableView {
        Label(message, systemImage: "wifi.exclamationmark")
      } actions: {
        Button(L("retryButton")) { Task { await retry() } }.buttonStyle(.glassProminent)
      }
    case .empty(let message, let symbol):
      ContentUnavailableView(message, systemImage: symbol)
    }
  }
}
