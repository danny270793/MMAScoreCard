import CryptoKit
import Foundation
import ScoreCardCore

/// Persists every Sherdog response (event listings, fight cards, fighter
/// profiles) as JSON files, so none is fetched more than once: once a URL has
/// an entry, reads come from here until a pull-to-refresh overwrites it.
///
/// `index.json` keeps per-entry metadata: first cached, last refreshed, how
/// many times it was read, plus whether more past pages exist.
public actor EventsCache {
  struct Meta: Codable {
    var url: String
    var kind: String
    var page: Int?
    var cachedAt: Date
    var refreshedAt: Date
    var readCount: Int
  }

  struct Index: Codable {
    var entries: [String: Meta] = [:]
    var pastHasMore = true
  }

  private let dir: URL
  private var index: Index
  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()

  public init(directory: URL? = nil) {
    let base =
      directory
      ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
      .appendingPathComponent("EventsCache", isDirectory: true)
    dir = base
    try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
    index = (try? JSONDecoder().decode(Index.self, from: Data(contentsOf: base.appendingPathComponent("index.json"))))
      ?? Index()
  }

  // MARK: Typed entries

  public func upcoming() -> [MmaEvent]? { read("upcoming") }

  public func saveUpcoming(_ events: [MmaEvent]) {
    write("upcoming", events, url: SherdogSource.orgUrl, kind: .upcoming)
  }

  /// Every cached past-events page, keyed by page number.
  public func pastPages() -> [Int: [MmaEvent]] {
    var pages: [Int: [MmaEvent]] = [:]
    for (key, meta) in index.entries where meta.kind == CachedRequestKind.pastPage.rawValue {
      if let page = meta.page, let events: [MmaEvent] = read(key) { pages[page] = events }
    }
    return pages
  }

  public var pastHasMore: Bool { index.pastHasMore }

  public func savePastPage(_ page: Int, _ events: [MmaEvent], hasMore: Bool) {
    index.pastHasMore = hasMore
    write("past_page_\(page)", events, url: "\(SherdogSource.orgUrl)/recent-events/\(page)", kind: .pastPage, page: page)
  }

  public func fights(_ eventUrl: String) -> [EventFight]? { read("fight_\(eventUrl)") }

  public func saveFights(_ eventUrl: String, _ fights: [EventFight]) {
    write("fight_\(eventUrl)", fights, url: eventUrl, kind: .fightCard)
  }

  public func fighter(_ fighterUrl: String) -> FighterProfile? { read("fighter_\(fighterUrl)") }

  public func saveFighter(_ fighterUrl: String, _ profile: FighterProfile) {
    write("fighter_\(fighterUrl)", profile, url: fighterUrl, kind: .fighterProfile)
  }

  /// Every cached request on disk, most recently refreshed first.
  public func requests() -> [CachedRequestInfo] {
    index.entries.compactMap { key, meta -> CachedRequestInfo? in
      guard let kind = CachedRequestKind(rawValue: meta.kind) else { return nil }
      let size = (try? file(key).resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? nil
      return CachedRequestInfo(
        url: meta.url, cachedAt: meta.cachedAt, refreshedAt: meta.refreshedAt, readCount: meta.readCount,
        sizeBytes: size ?? 0, kind: kind, page: meta.page)
    }
    .sorted { $0.refreshedAt > $1.refreshedAt }
  }

  // MARK: Storage

  private func file(_ key: String) -> URL {
    let name = SHA256.hash(data: Data(key.utf8)).map { String(format: "%02x", $0) }.joined()
    return dir.appendingPathComponent("\(name).json")
  }

  /// Reads count as a display-only counter; a later write never resets it.
  private func read<T: Decodable>(_ key: String) -> T? {
    guard index.entries[key] != nil, let data = try? Data(contentsOf: file(key)),
      let value = try? decoder.decode(T.self, from: data)
    else { return nil }
    index.entries[key]?.readCount += 1
    saveIndex()
    return value
  }

  /// The first-cached time is set once and kept; the refreshed time moves on
  /// every write, so a pull-to-refresh doesn't reset "cached".
  private func write<T: Encodable>(_ key: String, _ value: T, url: String, kind: CachedRequestKind, page: Int? = nil) {
    guard let data = try? encoder.encode(value) else { return }
    try? data.write(to: file(key), options: .atomic)
    let now = Date()
    var meta =
      index.entries[key]
      ?? Meta(url: url, kind: kind.rawValue, page: page, cachedAt: now, refreshedAt: now, readCount: 0)
    meta.refreshedAt = now
    index.entries[key] = meta
    saveIndex()
  }

  private func saveIndex() {
    try? encoder.encode(index).write(to: dir.appendingPathComponent("index.json"), options: .atomic)
  }
}
