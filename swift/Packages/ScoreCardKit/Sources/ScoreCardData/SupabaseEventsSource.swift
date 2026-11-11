import Foundation
import OSLog
import ScoreCardCore

/// Supabase project the app reads from, loaded from `MMAConfig.plist` (see
/// `swift/README.md`).
public struct SupabaseConfig: Sendable {
  public let url: URL
  public let anonKey: String

  public init(url: URL, anonKey: String) {
    self.url = url
    self.anonKey = anonKey
  }

  public static func fromBundle(_ bundle: Bundle = .main) -> SupabaseConfig? {
    guard let path = bundle.path(forResource: "MMAConfig", ofType: "plist"),
      let dict = NSDictionary(contentsOfFile: path) as? [String: String],
      let raw = dict["SUPABASE_URL"], let url = URL(string: raw), let key = dict["SUPABASE_ANON_KEY"], !key.isEmpty,
      !raw.contains("xxxx")
    else { return nil }
    return SupabaseConfig(url: url, anonKey: key)
  }
}

/// Asks the backend to re-read Sherdog and store the result. Each call is
/// rate-limited on the server (once every 5 minutes per item), so it may
/// return without fetching anything; read the data again afterwards either way.
public protocol EventsRefreshing: Sendable {
  func refreshEvents() async
  func refreshEvent(_ eventUrl: String) async
  func refreshFighter(_ fighterUrl: String) async
}

/// Events, fight cards and fighter profiles read from the `mma_` tables. The
/// `mma-sync` Edge Function keeps them in sync with Sherdog (hourly, and
/// whenever someone refreshes), so the app never talks to Sherdog directly.
///
/// A card or profile that isn't stored yet (an upcoming card nobody opened,
/// an opponent from another promotion) is fetched by the backend on first read.
public struct SupabaseEventsSource: EventsSource, EventsRefreshing {
  static let pageSize = 100
  private static let log = Logger(subsystem: "io.github.danny270793.mmascorecard", category: "Supabase")

  private let config: SupabaseConfig
  private let session: URLSession
  /// Last response of every read, served when Supabase can't be reached.
  private let cache: EventsCache?

  public init(config: SupabaseConfig, session: URLSession = .shared, cache: EventsCache? = nil) {
    self.config = config
    self.session = session
    self.cache = cache
  }

  // MARK: Reads

  private static let eventColumns =
    "name,matchup,date,link,status,sherdog_id,location:mma_locations(name,city:mma_cities(name,country:mma_countries(name)))"

  public func upcomingEvents() async throws -> [MmaEvent] {
    let rows: [EventRow] = try await get(
      "mma_events", ["select": Self.eventColumns, "status": "eq.upcoming", "order": "date.asc,id.asc"],
      kind: .upcoming)
    return rows.map(\.event)
  }

  public func pastEvents(page: Int) async throws -> EventsPage {
    // One extra row tells whether another page exists.
    let rows: [EventRow] = try await get(
      "mma_events",
      [
        "select": Self.eventColumns, "status": "eq.past", "order": "date.desc,id.desc",
        "offset": "\(max(0, page - 1) * Self.pageSize)", "limit": "\(Self.pageSize + 1)",
      ], kind: .pastPage, page: page)
    return EventsPage(events: rows.prefix(Self.pageSize).map(\.event), page: page, hasMore: rows.count > Self.pageSize)
  }

  /// One stored event by its Sherdog link; nil when it isn't stored (only UFC
  /// events are).
  public func event(_ eventUrl: String) async throws -> MmaEvent? {
    guard let id = Self.sherdogId(eventUrl) else { return nil }
    let rows: [EventRow] = try await get(
      "mma_events", ["select": Self.eventColumns, "sherdog_id": "eq.\(id)"], kind: .event)
    return rows.first?.event
  }

  public func eventFights(_ eventUrl: String) async throws -> [EventFight] {
    let fights = try await storedFights(eventUrl)
    guard fights.isEmpty else { return fights }
    await refreshEvent(eventUrl)
    return try await storedFights(eventUrl)
  }

  public func fighterProfile(_ fighterUrl: String) async throws -> FighterProfile {
    if let profile = try await storedProfile(fighterUrl) { return profile }
    await refreshFighter(fighterUrl)
    guard let profile = try await storedProfile(fighterUrl) else {
      throw EventsSourceError("Fighter profile not available yet")
    }
    return profile
  }

  private func storedFights(_ eventUrl: String) async throws -> [EventFight] {
    guard let id = Self.sherdogId(eventUrl) else { throw EventsSourceError("Bad event URL \(eventUrl)") }
    let rows: [FightRow] = try await get(
      "mma_fights",
      [
        "select":
          "position,main_event,title_fight,status,method,decision,round,time_seconds,winner,"
          + "one:mma_fighters!fighter_one_id(name,link),two:mma_fighters!fighter_two_id(name,link),"
          + "category:mma_categories(name),referee:mma_referees(name),event:mma_events!inner(sherdog_id)",
        "event.sherdog_id": "eq.\(id)",
        // Main event (highest position) first, as the card is shown.
        "order": "position.desc,id.asc",
      ], kind: .fightCard)
    return rows.map { $0.fight.withMixedSides() }
  }

  private func storedProfile(_ fighterUrl: String) async throws -> FighterProfile? {
    guard let id = Self.sherdogId(fighterUrl) else { throw EventsSourceError("Bad fighter URL \(fighterUrl)") }
    let rows: [ProfileRow] = try await get(
      "mma_fighters", ["select": "profile", "sherdog_id": "eq.\(id)"], kind: .fighterProfile)
    return rows.first?.profile
  }

  /// Every stored event matching the name, headline, venue, city or country,
  /// and fighters by name or nickname (`mma_search`). Not saved for offline use.
  public func search(_ query: String) async throws -> SearchResults {
    var request = URLRequest(url: url("rest/v1/rpc/mma_search", [:]), timeoutInterval: 12)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONSerialization.data(withJSONObject: ["p_query": query, "p_limit": 50])
    authorize(&request)
    let (data, response) = try await session.data(for: request)
    let status = (response as? HTTPURLResponse)?.statusCode ?? 0
    guard status == 200 else { throw EventsSourceError("Server returned HTTP \(status)") }
    let rows = try JSONDecoder().decode(SearchRow.self, from: data)
    return SearchResults(
      events: rows.events.map(\.event),
      fighters: rows.fighters.map { FighterSearchHit(name: $0.name, nickname: $0.nickname, url: $0.link) })
  }

  // MARK: Browse

  public static let browsePageSize = 100

  /// One page of a Browse list, filtered by name, alphabetical or most events / bouts first.
  public func browse(
    _ kind: BrowseKind, query: String, sort: BrowseSort = .name, page: Int, limit: Int = browsePageSize
  ) async throws -> [BrowseItem] {
    let rows: [BrowseRow] = try await rpc(
      "mma_browse",
      [
        "p_kind": kind.rawValue, "p_query": query, "p_sort": sort.rawValue, "p_offset": (page - 1) * limit,
        "p_limit": limit,
      ])
    return rows.map { BrowseItem(id: $0.id, name: $0.name, subtitle: $0.subtitle, count: $0.count, link: $0.link) }
  }

  /// Events held in a city, country or location, newest first.
  public func browseEvents(_ kind: BrowseKind, id: Int64, page: Int) async throws -> [MmaEvent] {
    let rows: [EventRow] = try await rpc(
      "mma_browse_events", ["p_kind": kind.rawValue, "p_id": id, "p_offset": offset(page), "p_limit": Self.browsePageSize])
    return rows.map(\.event)
  }

  /// Bouts of a fighter or referee, newest first, each with its event.
  public func browseFights(_ kind: BrowseKind, id: Int64, page: Int) async throws -> [FightOnCard] {
    let rows: [FightOnCardRow] = try await rpc(
      "mma_browse_fights", ["p_kind": kind.rawValue, "p_id": id, "p_offset": offset(page), "p_limit": Self.browsePageSize])
    return rows.map { FightOnCard(event: $0.event.event, fight: $0.fight.fight.withMixedSides()) }
  }

  private func offset(_ page: Int) -> Int { max(0, page - 1) * Self.browsePageSize }

  /// Calls a read-only database function; its response is saved like any read
  /// (keyed by function and arguments) and served when Supabase can't be reached.
  private func rpc<T: Decodable>(_ function: String, _ args: [String: Any]) async throws -> T {
    let endpoint = url("rest/v1/rpc/\(function)", [:])
    let key = url("rest/v1/rpc/\(function)", args.mapValues { "\($0)" })
    var request = URLRequest(url: endpoint, timeoutInterval: 12)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONSerialization.data(withJSONObject: args)
    authorize(&request)
    let failure: EventsSourceError
    do {
      let (data, response) = try await session.data(for: request)
      let status = (response as? HTTPURLResponse)?.statusCode ?? 0
      if status == 200 {
        let value = try JSONDecoder().decode(T.self, from: data)
        await cache?.saveResponse(data, for: key, kind: .browse)
        return value
      }
      failure = EventsSourceError("Server returned HTTP \(status)")
    } catch let error as DecodingError {
      throw EventsSourceError("Unexpected response from the server", error)
    } catch {
      failure = EventsSourceError("Could not reach the server", error)
    }
    if let saved = await cache?.response(for: key), let value = try? JSONDecoder().decode(T.self, from: saved) {
      return value
    }
    throw failure
  }

  // MARK: Refresh (backend)

  public func refreshEvents() async { await refresh(["refresh": "events"]) }
  public func refreshEvent(_ eventUrl: String) async { await refresh(["refresh": "event", "link": eventUrl]) }
  public func refreshFighter(_ fighterUrl: String) async { await refresh(["refresh": "fighter", "link": fighterUrl]) }

  /// Best effort: a failed or rate-limited refresh still leaves the stored data to read.
  private func refresh(_ query: [String: String]) async {
    var request = URLRequest(url: url("functions/v1/mma-sync", query), timeoutInterval: 60)
    request.httpMethod = "POST"
    authorize(&request)
    do {
      let (data, response) = try await session.data(for: request)
      let status = (response as? HTTPURLResponse)?.statusCode ?? 0
      Self.log.debug("refresh \(query, privacy: .public) -> \(status) \(String(decoding: data, as: UTF8.self), privacy: .public)")
    } catch {
      Self.log.error("refresh \(query, privacy: .public) failed: \(error.localizedDescription, privacy: .public)")
    }
  }

  // MARK: HTTP

  private func url(_ path: String, _ query: [String: String]) -> URL {
    var components = URLComponents(url: config.url.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
    components.queryItems = query.sorted { $0.key < $1.key }.map { URLQueryItem(name: $0.key, value: $0.value) }
    return components.url!
  }

  private func authorize(_ request: inout URLRequest) {
    request.setValue(config.anonKey, forHTTPHeaderField: "apikey")
    request.setValue("Bearer \(config.anonKey)", forHTTPHeaderField: "Authorization")
  }

  /// Reads Supabase and saves the response; when Supabase can't be reached
  /// (or errors), serves the last saved response of this exact request.
  private func get<T: Decodable>(
    _ table: String, _ query: [String: String], kind: CachedRequestKind, page: Int? = nil
  ) async throws -> T {
    let requestUrl = url("rest/v1/\(table)", query)
    var request = URLRequest(url: requestUrl, timeoutInterval: 12)
    authorize(&request)
    let failure: EventsSourceError
    do {
      let (data, response) = try await session.data(for: request)
      let status = (response as? HTTPURLResponse)?.statusCode ?? 0
      if status == 200 {
        let value = try JSONDecoder().decode(T.self, from: data)
        await cache?.saveResponse(data, for: requestUrl, kind: kind, page: page)
        return value
      }
      failure = EventsSourceError("Server returned HTTP \(status)")
    } catch let error as DecodingError {
      throw EventsSourceError("Unexpected response from the server", error)
    } catch {
      Self.log.error("\(table, privacy: .public) failed: \(error.localizedDescription, privacy: .public)")
      failure = EventsSourceError("Could not reach the server", error)
    }
    if let saved = await cache?.response(for: requestUrl), let value = try? JSONDecoder().decode(T.self, from: saved) {
      Self.log.info("\(table, privacy: .public): serving the saved response")
      return value
    }
    throw failure
  }

  /// The number at the end of a Sherdog link ("…-Gane-vs-Hokit-114293").
  static func sherdogId(_ link: String) -> String? {
    link.firstMatch(of: /-(\d+)$/).map { String($0.1) }
  }
}

// MARK: - Rows

struct Named: Decodable {
  let name: String?
}

struct EventRow: Decodable {
  struct Location: Decodable {
    struct City: Decodable {
      let name: String?
      let country: Named?
    }
    let name: String?
    let city: City?
  }

  let name: String
  let matchup: String?
  let date: String
  let link: String
  let status: String
  let sherdog_id: Int64?
  let location: Location?

  private static let dayFormat: Date.ISO8601FormatStyle = .iso8601.year().month().day()

  var event: MmaEvent {
    // Sherdog's own text: "Venue, City, Region, Country".
    let parts = [location?.name, location?.city?.name, location?.city?.country?.name]
      .compactMap { $0?.split(whereSeparator: \.isWhitespace).joined(separator: " ") }
      .filter { !$0.isEmpty }
    return MmaEvent(
      id: sherdog_id.map(String.init) ?? link, eventName: name, matchup: matchup,
      dateUtc: (try? Date(date, strategy: Self.dayFormat)) ?? .distantPast, location: parts.joined(separator: ", "),
      url: link, isUpcoming: status == "upcoming")
  }
}

struct FightRow: Decodable {
  struct Fighter: Decodable {
    let name: String
    let link: String
  }

  let position: Int
  let main_event: Bool
  let title_fight: Bool
  let status: String
  let method: String?
  let decision: String?
  let round: Int?
  let time_seconds: Int?
  let winner: Int?
  let one: Fighter
  let two: Fighter
  let category: Named?
  let referee: Named?

  var fight: EventFight {
    let (a, b) = outcomes
    return EventFight(
      fighterA: one.name, fighterB: two.name, fighterAUrl: one.link, fighterBUrl: two.link,
      weightClass: category?.name ?? "", isTitleFight: title_fight, outcomeA: a, outcomeB: b,
      // Back to Sherdog's wording, e.g. "KO (Punches)" or "Decision (Unanimous)".
      method: decision.map { d in method.map { "\(d) (\($0))" } ?? d }, round: round.map(String.init),
      time: time_seconds.map { String(format: "%d:%02d", $0 / 60, $0 % 60) }, referee: referee?.name)
  }

  private var outcomes: (FightOutcome, FightOutcome) {
    guard status == "done" else { return (.pending, .pending) }
    switch winner {
    case 1: return (.win, .loss)
    case 2: return (.loss, .win)
    default:
      let d = (decision ?? "").lowercased()
      if d.contains("draw") { return (.draw, .draw) }
      if d.contains("no contest") { return (.noContest, .noContest) }
      return (.pending, .pending)
    }
  }
}

struct SearchRow: Decodable {
  struct Fighter: Decodable {
    let name: String
    let nickname: String?
    let link: String
  }
  let events: [EventRow]
  let fighters: [Fighter]
}

struct BrowseRow: Decodable {
  let id: Int64
  let name: String
  let subtitle: String?
  let count: Int
  let link: String?
}

struct FightOnCardRow: Decodable {
  let event: EventRow
  let fight: FightRow
}

struct ProfileRow: Decodable {
  let profile: FighterProfile?
}
