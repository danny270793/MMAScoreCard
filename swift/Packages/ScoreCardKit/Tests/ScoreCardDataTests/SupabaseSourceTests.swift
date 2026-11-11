import Foundation
import ScoreCardCore
import Testing

@testable import ScoreCardData

/// Rows as PostgREST returns them, mapped to the app's types.
struct SupabaseMappingTests {
  private func decode<T: Decodable>(_ json: String) throws -> T {
    try JSONDecoder().decode(T.self, from: Data(json.utf8))
  }

  @Test func eventRowRebuildsSherdogLocationAndDate() throws {
    let rows: [EventRow] = try decode(
      """
      [{"name":"UFC 334","matchup":"Gane vs. Hokit","date":"2026-11-14","status":"upcoming","sherdog_id":114293,
        "link":"https://www.sherdog.com/events/UFC-334-Gane-vs-Hokit-114293",
        "location":{"name":"Madison Square Garden,  New York City",
                    "city":{"name":"New York","country":{"name":"United States"}}}}]
      """)
    let event = rows[0].event
    #expect(event.id == "114293")
    #expect(event.isUpcoming)
    #expect(event.location == "Madison Square Garden, New York City, New York, United States")
    #expect(event.dateUtc == Date(timeIntervalSince1970: 1_794_614_400))  // 2026-11-14T00:00:00Z
  }

  @Test func eventRowWithoutVenueKeepsCityAndCountry() throws {
    let rows: [EventRow] = try decode(
      """
      [{"name":"UFC Fight Night","matchup":null,"date":"2026-03-14","status":"past","sherdog_id":1,
        "link":"https://www.sherdog.com/events/x-1",
        "location":{"name":null,"city":{"name":"Shanghai","country":{"name":"China"}}}}]
      """)
    #expect(rows[0].event.location == "Shanghai, China")
    #expect(!rows[0].event.isUpcoming)
  }

  @Test func fightRowMapsResultBackToSherdogWording() throws {
    let rows: [FightRow] = try decode(
      """
      [{"position":13,"main_event":true,"title_fight":false,"status":"done","method":"Corner Stoppage",
        "decision":"TKO","round":4,"time_seconds":300,"winner":1,
        "one":{"name":"Brendan Allen","link":"https://www.sherdog.com/fighter/Brendan-Allen-201703"},
        "two":{"name":"Reinier de Ridder","link":"https://www.sherdog.com/fighter/Reinier-de-Ridder-133677"},
        "category":{"name":"Middleweight"},"referee":{"name":"Jason Herzog"}},
       {"position":2,"main_event":false,"title_fight":true,"status":"done","method":"Split","decision":"Draw",
        "round":5,"time_seconds":300,"winner":null,
        "one":{"name":"A","link":"https://www.sherdog.com/fighter/A-1"},
        "two":{"name":"B","link":"https://www.sherdog.com/fighter/B-2"},"category":null,"referee":null},
       {"position":1,"main_event":false,"title_fight":false,"status":"pending","method":null,"decision":null,
        "round":null,"time_seconds":null,"winner":null,
        "one":{"name":"C","link":"https://www.sherdog.com/fighter/C-3"},
        "two":{"name":"D","link":"https://www.sherdog.com/fighter/D-4"},"category":{"name":"Flyweight"},"referee":null}]
      """)
    let main = rows[0].fight
    #expect(main.method == "TKO (Corner Stoppage)")
    #expect(main.round == "4" && main.time == "5:00")
    #expect(main.outcomeA == .win && main.outcomeB == .loss)
    #expect(main.weightClass == "Middleweight" && main.referee == "Jason Herzog")
    #expect(main.octagonTime == TimeInterval(20 * 60))

    let draw = rows[1].fight
    #expect(draw.outcomeA == .draw && draw.outcomeB == .draw)
    #expect(draw.isTitleFight && draw.weightClass == "")

    let pending = rows[2].fight
    #expect(!pending.isCompleted && pending.method == nil && pending.time == nil)
  }

  @Test func profileJsonDecodesIntoFighterProfile() throws {
    let rows: [ProfileRow] = try decode(
      """
      [{"profile":{"name":"Mateusz Gamrot","nationality":"Poland","hometown":"Poznan","age":35,
        "birthDate":"Dec 11, 1990","height":"5'10\\" (177.8 cm)","weight":"156 lbs (70.76 kg)",
        "association":"American Top Team","weightClass":"Lightweight","wins":26,"losses":5,
        "winsBreakdown":{"koTko":{"count":8,"percent":31},"submissions":{"count":6,"percent":23},
                         "decisions":{"count":12,"percent":46}},
        "lossesBreakdown":{"koTko":{"count":0,"percent":0},"submissions":{"count":2,"percent":40},
                           "decisions":{"count":3,"percent":60}},
        "fightHistory":[{"outcome":"loss","opponentName":"Quillan Salkilld",
          "opponentUrl":"https://www.sherdog.com/fighter/Quillan-Salkilld-300317",
          "eventName":"UFC Fight Night 284 - Gamrot vs. Salkilld","eventUrl":null,
          "eventDateText":"Aug / 08 / 2026","method":"Submission (Rear-Naked Choke)","referee":"Jason Herzog",
          "round":"1","time":"4:25","isAmateur":false},
          {"outcome":"noContest","opponentName":"X","opponentUrl":null,"eventName":"Y","eventUrl":null,
           "eventDateText":null,"method":null,"referee":null,"round":null,"time":null,"isAmateur":true}]}},
       {"profile":null}]
      """)
    let profile = try #require(rows[0].profile)
    #expect(profile.recordSummary == "26-5-0-1")
    #expect(profile.professionalFights.count == 1)
    #expect(profile.currentStreak == FightStreak(outcome: .loss, count: 1))
    #expect(rows[1].profile == nil)
  }

  @Test func sherdogIdIsTheTrailingNumber() {
    #expect(SupabaseEventsSource.sherdogId("https://www.sherdog.com/events/UFC-334-Gane-vs-Hokit-114293") == "114293")
    #expect(SupabaseEventsSource.sherdogId("https://www.sherdog.com/fighter/Mateusz-Gamrot-90605") == "90605")
    #expect(SupabaseEventsSource.sherdogId("https://www.sherdog.comjavascript:void();") == nil)
  }
}

private actor BackendSource: EventsSource, EventsRefreshing {
  var offline = false
  var reads = 0
  var refreshes: [String] = []
  let events: [MmaEvent]

  init(_ events: [MmaEvent]) { self.events = events }

  func goOffline() { offline = true }

  func upcomingEvents() async throws -> [MmaEvent] {
    reads += 1
    if offline { throw EventsSourceError("offline") }
    return events
  }
  func pastEvents(page: Int) async throws -> EventsPage { EventsPage(events: [], page: page, hasMore: false) }
  func eventFights(_ eventUrl: String) async throws -> [EventFight] { [] }
  func fighterProfile(_ fighterUrl: String) async throws -> FighterProfile { throw EventsSourceError("offline") }

  func refreshEvents() async { refreshes.append("events") }
  func refreshEvent(_ eventUrl: String) async { refreshes.append("event") }
  func refreshFighter(_ fighterUrl: String) async { refreshes.append("fighter") }
}

/// With a backend, every read hits it; the cache only covers being offline.
struct BackendRepositoryTests {
  private let event = MmaEvent(
    id: "1", eventName: "UFC 1", matchup: nil, dateUtc: Date(timeIntervalSince1970: 0), location: "Denver",
    url: "https://www.sherdog.com/events/UFC-1-1", isUpcoming: true)

  private func repo(_ source: BackendSource) -> EventsRepository {
    EventsRepository(
      source: source, refresher: source,
      cache: EventsCache(directory: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)))
  }

  @Test func readsAlwaysGoToTheBackendAndRefreshAsksItToRescrape() async throws {
    let source = BackendSource([event])
    let repo = repo(source)
    #expect(repo.readsFromBackend)
    _ = try await repo.upcomingEvents()
    _ = try await repo.upcomingEvents()
    #expect(await source.reads == 2)
    #expect(await source.refreshes.isEmpty)
    _ = try await repo.upcomingEvents(refresh: true)
    #expect(await source.refreshes == ["events"])
  }

  @Test func backendModeKeepsNoDecodedCopies() async throws {
    let source = BackendSource([event])
    let repo = repo(source)
    _ = try await repo.upcomingEvents()
    await source.goOffline()
    // The repository doesn't cache with a backend: the source's saved responses do.
    await #expect(throws: EventsSourceError.self) { try await repo.upcomingEvents() }
    #expect(await repo.cachedRequests().isEmpty)
  }

  @Test func refreshingCardsAndFightersCallsTheBackend() async {
    let source = BackendSource([])
    let repo = repo(source)
    _ = try? await repo.eventFights("https://www.sherdog.com/events/UFC-1-1", refresh: true)
    _ = try? await repo.fighterProfile("https://www.sherdog.com/fighter/A-1", refresh: true)
    #expect(await source.refreshes == ["event", "fighter"])
  }
}

struct MixedSidesTests {
  private func fight(_ a: String, _ b: String, done: Bool = true) -> EventFight {
    EventFight(
      fighterA: a, fighterB: b, fighterAUrl: "https://www.sherdog.com/fighter/\(a)-1",
      fighterBUrl: "https://www.sherdog.com/fighter/\(b)-2", weightClass: "Lightweight", isTitleFight: false,
      outcomeA: done ? .win : .pending, outcomeB: done ? .loss : .pending, method: done ? "KO (Punch)" : nil)
  }

  @Test func winnersEndUpOnBothSidesAndStayPut() {
    let fights = (0..<40).map { fight("Winner\($0)", "Loser\($0)") }
    let mixed = fights.map { $0.withMixedSides() }
    let swapped = mixed.filter { $0.outcomeB == .win }
    #expect(!swapped.isEmpty && swapped.count < fights.count)
    #expect(fights.map { $0.withMixedSides() } == mixed)
    // A swap moves names, links and results together.
    for s in swapped {
      #expect(s.fighterA.hasPrefix("Loser") && s.fighterBUrl?.contains("Winner") == true && s.outcomeA == .loss)
    }
  }

  @Test func boutsWithoutResultKeepTheListedOrder() {
    let pending = (0..<20).map { fight("Gane\($0)", "Hokit\($0)", done: false) }
    #expect(pending.map { $0.withMixedSides() } == pending)
  }
}

/// Answers requests from a closure, so the source can be tested without a network.
final class StubProtocol: URLProtocol, @unchecked Sendable {
  nonisolated(unsafe) static var handler: (@Sendable (URLRequest) throws -> (Int, Data))?

  override class func canInit(with request: URLRequest) -> Bool { true }
  override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
  override func stopLoading() {}
  override func startLoading() {
    do {
      guard let handler = Self.handler else { throw URLError(.notConnectedToInternet) }
      let (status, data) = try handler(request)
      client?.urlProtocol(
        self, didReceive: HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: nil)!,
        cacheStoragePolicy: .notAllowed)
      client?.urlProtocol(self, didLoad: data)
      client?.urlProtocolDidFinishLoading(self)
    } catch {
      client?.urlProtocol(self, didFailWithError: error)
    }
  }
}

/// The last response of each request is saved and served when Supabase can't be reached.
@Suite(.serialized) struct SavedResponseTests {
  private let upcoming = Data(
    """
    [{"name":"UFC 334","matchup":"Gane vs. Hokit","date":"2026-11-14","status":"upcoming","sherdog_id":114293,
      "link":"https://www.sherdog.com/events/UFC-334-Gane-vs-Hokit-114293","location":null}]
    """.utf8)

  private func source() -> (SupabaseEventsSource, EventsCache) {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [StubProtocol.self]
    let cache = EventsCache(directory: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString))
    let supabase = SupabaseConfig(url: URL(string: "https://example.supabase.co")!, anonKey: "anon")
    return (SupabaseEventsSource(config: supabase, session: URLSession(configuration: config), cache: cache), cache)
  }

  @Test func savesEachResponseAndServesItWhenOffline() async throws {
    let (source, cache) = source()
    let body = upcoming
    StubProtocol.handler = { _ in (200, body) }
    #expect(try await source.upcomingEvents().map(\.eventName) == ["UFC 334"])

    let saved = await cache.requests()
    #expect(saved.count == 1)
    #expect(saved[0].kind == .upcoming && saved[0].readCount == 0)
    #expect(saved[0].url.contains("/rest/v1/mma_events") && saved[0].url.contains("status=eq.upcoming"))

    StubProtocol.handler = { _ in throw URLError(.notConnectedToInternet) }
    #expect(try await source.upcomingEvents().map(\.eventName) == ["UFC 334"])
    StubProtocol.handler = { _ in (503, Data()) }
    #expect(try await source.upcomingEvents().map(\.eventName) == ["UFC 334"])
    #expect(await cache.requests()[0].readCount == 2)
  }

  @Test func offlineWithNothingSavedFails() async {
    let (source, _) = source()
    StubProtocol.handler = { _ in throw URLError(.notConnectedToInternet) }
    await #expect(throws: EventsSourceError.self) { try await source.upcomingEvents() }
  }

  @Test func oldDecodedEntriesAreDropped() async {
    let (_, cache) = source()
    await cache.saveUpcoming([])
    await cache.saveResponse(Data("[]".utf8), for: URL(string: "https://example.supabase.co/rest/v1/mma_events")!, kind: .upcoming)
    await cache.removeNonResponseEntries()
    let left = await cache.requests()
    #expect(left.count == 1 && left[0].url.contains("/rest/v1/"))
  }
}

struct SearchDecodingTests {
  @Test func searchResponseDecodesEventsAndFighters() throws {
    let json = """
      {"events":[{"name":"UFC 100","matchup":"Lesnar vs. Mir 2","date":"2009-07-11","status":"past","sherdog_id":9466,
        "link":"https://www.sherdog.com/events/UFC-100-Lesnar-vs-Mir-2-9466",
        "location":{"name":"Mandalay Bay Events Center,  Las Vegas",
                    "city":{"name":"Nevada","country":{"name":"United States"}}}}],
       "fighters":[{"name":"Alexander Volkanovski","nickname":"The Great",
                    "link":"https://www.sherdog.com/fighter/Alexander-Volkanovski-101527"}]}
      """
    let rows = try JSONDecoder().decode(SearchRow.self, from: Data(json.utf8))
    #expect(rows.events.map(\.event.eventName) == ["UFC 100"])
    #expect(rows.events[0].event.location == "Mandalay Bay Events Center, Las Vegas, Nevada, United States")
    #expect(rows.fighters.map(\.nickname) == ["The Great"])
  }
}

struct BrowseDecodingTests {
  @Test func browseRowsDecode() throws {
    let items = try JSONDecoder().decode(
      [BrowseRow].self,
      from: Data(#"[{"id":3,"name":"Marc Goddard","subtitle":null,"count":512},{"id":9,"name":"A","subtitle":"B","count":1,"link":"https://www.sherdog.com/fighter/A-1"}]"#.utf8))
    #expect(items.map(\.count) == [512, 1] && items[1].link != nil)

    let fights = try JSONDecoder().decode(
      [FightOnCardRow].self,
      from: Data(
        #"""
        [{"event":{"name":"UFC 333","matchup":"Volkanovski vs. Evloev","date":"2026-10-24","status":"past",
                   "sherdog_id":113863,"link":"https://www.sherdog.com/events/UFC-333-Volkanovski-vs-Evloev-113863",
                   "location":{"name":"X","city":{"name":"Y","country":{"name":"Z"}}}},
          "fight":{"position":14,"main_event":true,"title_fight":true,"status":"done","method":"Punches",
                   "decision":"TKO","round":2,"time_seconds":294,"winner":1,
                   "one":{"name":"Alexander Volkanovski","link":"https://www.sherdog.com/fighter/Alexander-Volkanovski-101527"},
                   "two":{"name":"Movsar Evloev","link":"https://www.sherdog.com/fighter/Movsar-Evloev-183539"},
                   "category":{"name":"Featherweight"},"referee":{"name":"Jason Herzog"}}}]
        """#.utf8))
    #expect(fights[0].event.event.eventName == "UFC 333")
    #expect(fights[0].fight.fight.method == "TKO (Punches)" && fights[0].fight.fight.time == "4:54")
  }
}
