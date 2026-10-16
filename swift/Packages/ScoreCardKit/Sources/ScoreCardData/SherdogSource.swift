import Foundation
import OSLog
import ScoreCardCore
import SwiftSoup

/// Source of MMA event listings. Implement this against any site (Sherdog,
/// UFC.com, Tapology, ...) and add it to `FallbackEventsSource` to swap or
/// add sources without touching the repository or the UI.
public protocol EventsSource: Sendable {
  func upcomingEvents() async throws -> [MmaEvent]
  func pastEvents(page: Int) async throws -> EventsPage
  func eventFights(_ eventUrl: String) async throws -> [EventFight]
  func fighterProfile(_ fighterUrl: String) async throws -> FighterProfile
}

public struct EventsSourceError: LocalizedError {
  public let message: String
  public let underlying: (any Error)?

  public init(_ message: String, _ underlying: (any Error)? = nil) {
    self.message = message
    self.underlying = underlying
  }

  public var errorDescription: String? { message }
}

/// Tries each source in order, falling back to the next one when a source throws.
public struct FallbackEventsSource: EventsSource {
  private let sources: [any EventsSource]

  public init(_ sources: [any EventsSource]) {
    precondition(!sources.isEmpty, "Provide at least one source")
    self.sources = sources
  }

  public func upcomingEvents() async throws -> [MmaEvent] { try await first { try await $0.upcomingEvents() } }
  public func pastEvents(page: Int) async throws -> EventsPage { try await first { try await $0.pastEvents(page: page) } }
  public func eventFights(_ url: String) async throws -> [EventFight] { try await first { try await $0.eventFights(url) } }
  public func fighterProfile(_ url: String) async throws -> FighterProfile {
    try await first { try await $0.fighterProfile(url) }
  }

  private func first<T>(_ action: (any EventsSource) async throws -> T) async throws -> T {
    var lastError: (any Error)?
    for source in sources {
      do { return try await action(source) } catch { lastError = error }
    }
    throw EventsSourceError("All MMA event sources failed", lastError)
  }
}

/// Scrapes UFC event listings from the Sherdog organization page.
///
/// The org page renders two static `table.new_table.event` tables server side:
/// the first is "Upcoming Events", the second "Recent Events" (paginated via
/// `/recent-events/{page}`, 100 rows per page). Both use schema.org/Event
/// microdata, which is what's parsed instead of layout classes.
public struct SherdogSource: EventsSource {
  public static let orgUrl = "https://www.sherdog.com/organizations/Ultimate-Fighting-Championship-UFC-2"
  private static let userAgent =
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36"
  private static let log = Logger(subsystem: "io.github.danny270793.mmascorecard", category: "Sherdog")

  private let session: URLSession

  public init(session: URLSession = .shared) {
    self.session = session
  }

  public func upcomingEvents() async throws -> [MmaEvent] {
    let doc = try await fetch(Self.orgUrl)
    guard let table = try eventTables(doc).first else { return [] }
    return try SherdogParser.events(in: table, isUpcoming: true)
  }

  public func pastEvents(page: Int) async throws -> EventsPage {
    try SherdogParser.pastPage(try await fetch("\(Self.orgUrl)/recent-events/\(page)"), page: page)
  }

  public func eventFights(_ eventUrl: String) async throws -> [EventFight] {
    try SherdogParser.fights(try await fetch(eventUrl))
  }

  public func fighterProfile(_ fighterUrl: String) async throws -> FighterProfile {
    try SherdogParser.fighter(try await fetch(fighterUrl))
  }

  private func eventTables(_ doc: Document) throws -> [Element] { try doc.select("table.new_table.event").array() }

  private func fetch(_ url: String) async throws -> Document {
    guard let u = URL(string: url) else { throw EventsSourceError("Bad URL \(url)") }
    var request = URLRequest(url: u, timeoutInterval: 12)
    request.setValue(Self.userAgent, forHTTPHeaderField: "User-Agent")
    let start = Date()
    Self.log.debug("GET \(url, privacy: .public)")
    let data: Data
    let response: URLResponse
    do {
      (data, response) = try await session.data(for: request)
    } catch {
      Self.log.error("\(url, privacy: .public) failed: \(error.localizedDescription, privacy: .public)")
      let timedOut = (error as? URLError)?.code == .timedOut
      throw EventsSourceError(timedOut ? "Sherdog took too long to respond" : "Could not reach Sherdog", error)
    }
    let status = (response as? HTTPURLResponse)?.statusCode ?? 0
    let ms = Int(Date().timeIntervalSince(start) * 1000)
    Self.log.debug("\(url, privacy: .public) -> \(status) (\(data.count)B) in \(ms)ms")
    guard status == 200 else { throw EventsSourceError("Sherdog returned HTTP \(status)") }
    return try SwiftSoup.parse(String(decoding: data, as: UTF8.self), url)
  }
}

/// The HTML parsing behind `SherdogSource`, separate so tests can feed saved pages.
public enum SherdogParser {
  private static let base = "https://www.sherdog.com"

  public static func pastPage(_ doc: Document, page: Int) throws -> EventsPage {
    let tables = try doc.select("table.new_table.event").array()
    let events = tables.count > 1 ? try events(in: tables[1], isUpcoming: false) : []
    let next = "/recent-events/\(page + 1)"
    let hasMore = try doc.select(".pagination a").array().contains { (try? $0.attr("href").contains(next)) ?? false }
    return EventsPage(events: events, page: page, hasMore: hasMore)
  }

  static func events(in table: Element, isUpcoming: Bool) throws -> [MmaEvent] {
    try table.select("tr[itemtype=http://schema.org/Event]").array().compactMap { try event($0, isUpcoming: isUpcoming) }
  }

  private static func event(_ row: Element, isUpcoming: Bool) throws -> MmaEvent? {
    guard let dateText = try row.select("meta[itemprop=startDate]").first()?.attr("content"),
      let href = try row.select("a[itemprop=url]").first()?.attr("href"), !href.isEmpty,
      let title = try row.select("span[itemprop=name]").first()?.text().trimmed,
      let date = ISO8601DateFormatter().date(from: dateText)
    else { return nil }
    let location = try row.select("td[itemprop=location]").first()?.text().trimmed ?? ""
    // Titles look like "UFC 331 - Van vs. Pantoja 2": the event name, then the matchup.
    let parts = title.components(separatedBy: " - ")
    let name = parts[0].trimmed
    let matchup = parts.count > 1 ? parts.dropFirst().joined(separator: " - ").trimmed : nil
    let id = href.firstMatch(of: /-(\d+)$/).map { String($0.1) } ?? href
    return MmaEvent(
      id: id, eventName: name, matchup: matchup, dateUtc: date, location: location, url: absolute(href),
      isUpcoming: isUpcoming)
  }

  public static func fights(_ doc: Document) throws -> [EventFight] {
    var fights: [EventFight] = []
    if let card = try doc.select("div.fight_card").first(), let fight = try headliner(card) { fights.append(fight) }
    for row in try doc.select("table.new_table tr[itemprop=subEvent]").array() {
      if let fight = try cardRow(row) { fights.append(fight) }
    }
    return fights
  }

  /// The headliner is a standalone `.fight_card` block (fighters either side
  /// of a `.versus` column) with its result in a `fight_card_resume` table.
  private static func headliner(_ card: Element) throws -> EventFight? {
    guard let left = try card.select(".fighter.left_side").first(),
      let right = try card.select(".fighter.right_side").first()
    else { return nil }
    let center = try card.select(".versus").first()
    let resume = try card.parent()?.select("table.fight_card_resume").first()
    return EventFight(
      fighterA: try fighterName(left), fighterB: try fighterName(right),
      fighterAUrl: try fighterUrl(left), fighterBUrl: try fighterUrl(right),
      weightClass: try center?.select(".weight_class").first()?.text().trimmed ?? "",
      isTitleFight: try center?.select(".title_fight").first() != nil,
      outcomeA: try outcome(left.select(".final_result").first()),
      outcomeB: try outcome(right.select(".final_result").first()),
      method: try resume.flatMap { try resumeField($0, "Method") },
      round: try resume.flatMap { try resumeField($0, "Round") },
      time: try resume.flatMap { try resumeField($0, "Time") },
      referee: try resume.flatMap { try resumeField($0, "Referee") })
  }

  /// Every other bout is a `tr[itemprop=subEvent]` row: fighter cells either
  /// side of a weight-class column, then method/round/time once fought.
  private static func cardRow(_ row: Element) throws -> EventFight? {
    guard let left = try row.select("td.text_right").first(), let right = try row.select("td.text_left").first()
    else { return nil }
    let center = try row.select("td.text_center").first()
    let winby = try row.select("td.winby").first()
    let cells = try row.select("td").array()
    let hasResult = cells.count >= 7
    return EventFight(
      fighterA: try fighterName(left), fighterB: try fighterName(right),
      fighterAUrl: try fighterUrl(left), fighterBUrl: try fighterUrl(right),
      weightClass: try center?.select(".weight_class").first()?.text().trimmed ?? "",
      isTitleFight: try center?.select(".title_fight").first() != nil,
      outcomeA: try outcome(left.select(".final_result").first()),
      outcomeB: try outcome(right.select(".final_result").first()),
      method: try winby?.select("b").first()?.text().trimmed,
      round: hasResult ? try cells[cells.count - 2].text().trimmed : nil,
      time: hasResult ? try cells[cells.count - 1].text().trimmed : nil,
      referee: try winby?.select(".sub_line").first()?.text().trimmed)
  }

  public static func fighter(_ doc: Document) throws -> FighterProfile {
    func text(_ css: String) throws -> String? { try doc.select(css).first()?.text().trimmed }
    var age: Int?
    for tr in try doc.select("table tr").array() where try tr.select("td").first()?.text().trimmed == "AGE" {
      age = Int(try tr.select("td b").first()?.text().trimmed ?? "")
      break
    }
    return FighterProfile(
      name: try text("h1 span.fn") ?? "",
      nationality: try text("strong[itemprop=nationality]"),
      hometown: try text("span[itemprop=addressLocality]"),
      age: age,
      birthDate: try text("span[itemprop=birthDate]"),
      height: try withMetric(doc.select("b[itemprop=height]").first()),
      weight: try withMetric(doc.select("b[itemprop=weight]").first()),
      association: try text("span[itemprop=memberOf] span[itemprop=name]"),
      weightClass: try text(".association-class a[href*=weightclass=]"),
      wins: Int(try text(".wins .winloses span:last-child") ?? "") ?? 0,
      losses: Int(try text(".loses .winloses span:last-child") ?? "") ?? 0,
      winsBreakdown: try breakdown(doc, ".wins"),
      lossesBreakdown: try breakdown(doc, ".loses"),
      fightHistory: try history(doc))
  }

  /// Professional and amateur bouts live in separate tables under their own
  /// "Fight History" headings, so each table is read on its own.
  private static func history(_ doc: Document) throws -> [FighterFightRecord] {
    var records: [FighterFightRecord] = []
    for table in try doc.select("table.new_table.fighter").array() {
      let amateur = try isAmateurTable(table)
      for row in try table.select("tr").array() where !row.hasClass("table_head") {
        if let record = try historyRow(row, isAmateur: amateur) { records.append(record) }
      }
    }
    // Newest first; undated rows go last. Stable, so same-day rows keep page order.
    return records.enumerated().sorted { a, b in
      switch (historyDate(a.element.eventDateText), historyDate(b.element.eventDateText)) {
      case let (x?, y?) where x != y: x > y
      case (nil, _?): false
      case (_?, nil): true
      default: a.offset < b.offset
      }
    }.map(\.element)
  }

  /// The "Fight History - Amateur" title is a `.slanted_title` in the same
  /// `<section>` as the table, not a sibling heading.
  private static func isAmateurTable(_ table: Element) throws -> Bool {
    var node: Element? = table
    while let n = node, n.tagName() != "section" { node = n.parent() }
    guard let scope = node ?? table.parent() else { return false }
    let title = try scope.select(".slanted_title").first() ?? scope.select("h2").first()
    let text = try (title ?? scope).text().lowercased()
    return text.contains("fight history") && text.contains("amateur")
  }

  private static func historyRow(_ row: Element, isAmateur: Bool) throws -> FighterFightRecord? {
    let cells = try row.select("td").array()
    guard cells.count >= 4 else { return nil }
    let opponent = try cells[1].select("a").first()
    let event = try cells[2].select("a").first()
    let opponentHref = try opponent?.attr("href") ?? ""
    let eventHref = try event?.attr("href") ?? ""
    return FighterFightRecord(
      outcome: try outcome(cells[0].select(".final_result").first()),
      opponentName: try opponent?.text().trimmed ?? "",
      opponentUrl: opponentHref.isEmpty ? nil : absolute(opponentHref),
      eventName: try event?.text().trimmed ?? "",
      eventUrl: eventHref.isEmpty ? nil : absolute(eventHref),
      eventDateText: try cells[2].select(".sub_line").first()?.text().trimmed,
      method: try cells[3].select("b").first()?.text().trimmed,
      referee: try cells[3].select(".sub_line").first()?.text().trimmed,
      round: cells.count > 4 ? try cells[4].text().trimmed : nil,
      time: cells.count > 5 ? try cells[5].text().trimmed : nil,
      isAmateur: isAmateur)
  }

  private static let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

  /// "May / 09 / 2026" as a sortable (year, month, day) number.
  static func historyDate(_ text: String?) -> Int? {
    let parts = (text ?? "").split(separator: "/").map { $0.trimmingCharacters(in: .whitespaces) }
    guard parts.count == 3, let m = months.firstIndex(of: parts[0]), let d = Int(parts[1]), let y = Int(parts[2])
    else { return nil }
    return y * 10_000 + (m + 1) * 100 + d
  }

  private static func breakdown(_ doc: Document, _ scope: String) throws -> RecordBreakdown {
    let meters = try doc.select("\(scope) .meter").array()
    func meter(_ i: Int) throws -> RecordMeter {
      guard i < meters.count else { return .zero }
      let count = Int(try meters[i].select(".pl").first()?.text().trimmed ?? "") ?? 0
      let percent = Int((try meters[i].select(".pr").first()?.text().trimmed ?? "").replacingOccurrences(of: "%", with: "")) ?? 0
      return RecordMeter(count: count, percent: percent)
    }
    return RecordBreakdown(koTko: try meter(0), submissions: try meter(1), decisions: try meter(2))
  }

  /// `<b itemprop="height">5'7"</b> <em>/</em> 170.18 cm` becomes "5'7" (170.18 cm)".
  private static func withMetric(_ value: Element?) throws -> String? {
    guard let cell = value?.parent() else { return nil }
    let text = try cell.text().trimmed
    let parts = text.split(separator: "/", omittingEmptySubsequences: false)
    guard parts.count == 2 else { return text.isEmpty ? nil : text }
    return "\(parts[0].trimmingCharacters(in: .whitespaces)) (\(parts[1].trimmingCharacters(in: .whitespaces)))"
  }

  private static func fighterUrl(_ cell: Element) throws -> String? {
    let href = try cell.select("a[itemprop=url]").first()?.attr("href") ?? ""
    return href.isEmpty ? nil : absolute(href)
  }

  /// Names are split across lines with a bare `<br>` ("Kevin<br>Vallejos"),
  /// which plain text extraction would glue together.
  private static func fighterName(_ cell: Element) throws -> String {
    guard let span = try cell.select("span[itemprop=name]").first() else { return "" }
    let joined = try span.getChildNodes().map { node -> String in
      if let el = node as? Element { return el.tagName() == "br" ? " " : try el.text() }
      return (node as? TextNode)?.text() ?? ""
    }.joined()
    return joined.split(whereSeparator: \.isWhitespace).joined(separator: " ")
  }

  private static func outcome(_ result: Element?) throws -> FightOutcome {
    guard let result else { return .pending }
    if result.hasClass("win") { return .win }
    if result.hasClass("loss") { return .loss }
    if result.hasClass("draw") { return .draw }
    if try result.hasClass("no_contest") || result.text().lowercased().contains("no contest") { return .noContest }
    return .pending
  }

  /// Cells look like `<em>Method</em><br> KO (Punches)`: the label is stripped
  /// from the front of the cell text.
  private static func resumeField(_ resume: Element, _ label: String) throws -> String? {
    for cell in try resume.select("td").array() {
      guard let em = try cell.select("em").first(), try em.text().trimmed == label else { continue }
      let value = String(try cell.text().trimmed.dropFirst(label.count)).trimmed
      return value.isEmpty ? nil : value
    }
    return nil
  }

  private static func absolute(_ href: String) -> String { href.hasPrefix("http") ? href : base + href }
}

extension String {
  var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
