// Deliberate: logs every request this repository makes to the terminal.
// ignore_for_file: avoid_print

import 'dart:async';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

import '../../domain/entities/event_fight.dart';
import '../../domain/entities/events_page.dart';
import '../../domain/entities/fighter_profile.dart';
import '../../domain/entities/mma_event.dart';
import 'mma_events_remote_datasource.dart';

/// Scrapes UFC event listings from the Sherdog organization page.
///
/// The org page renders two static `table.new_table.event` tables server
/// side (no JS/captcha involved): the first is "Upcoming Events", the
/// second is "Recent Events" (paginated via `/recent-events/{page}`,
/// 100 rows per page, oldest last). Both use schema.org/Event microdata,
/// which is what's parsed below instead of relying on layout/CSS classes.
class SherdogEventsRemoteDatasource implements MmaEventsRemoteDatasource {
  SherdogEventsRemoteDatasource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  static const _orgSlug = 'Ultimate-Fighting-Championship-UFC-2';
  static const _baseUrl = 'https://www.sherdog.com/organizations/$_orgSlug';
  static const _userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/120.0 Safari/537.36';

  @override
  Future<List<MmaEvent>> fetchUpcomingEvents() async {
    final document = await _fetchDocument(_baseUrl);
    final tables = _eventTables(document);
    if (tables.isEmpty) return const [];
    return _parseRows(tables.first, isUpcoming: true);
  }

  @override
  Future<EventsPage> fetchPastEvents({required int page}) async {
    final document = await _fetchDocument('$_baseUrl/recent-events/$page');
    final tables = _eventTables(document);
    final pastTable = tables.length > 1 ? tables[1] : null;
    final events = pastTable == null
        ? const <MmaEvent>[]
        : _parseRows(pastTable, isUpcoming: false);

    final hasMore = document
        .querySelectorAll('.pagination a')
        .any(
          (a) => (a.attributes['href'] ?? '').contains(
            '/recent-events/${page + 1}',
          ),
        );

    return EventsPage(events: events, page: page, hasMore: hasMore);
  }

  @override
  Future<List<EventFight>> fetchEventFights(String eventUrl) async {
    final document = await _fetchDocument(eventUrl);
    final fights = <EventFight>[];

    final headliner = document.querySelector('div.fight_card');
    if (headliner != null) {
      final fight = _parseHeadlinerFight(headliner);
      if (fight != null) fights.add(fight);
    }

    for (final row in document.querySelectorAll(
      'table.new_table tr[itemprop="subEvent"]',
    )) {
      final fight = _parseCardRow(row);
      if (fight != null) fights.add(fight);
    }

    return fights;
  }

  @override
  Future<FighterProfile> fetchFighterProfile(String fighterUrl) async {
    final document = await _fetchDocument(fighterUrl);

    final name = document.querySelector('h1 span.fn')?.text.trim() ?? '';
    final nationality = document
        .querySelector('strong[itemprop="nationality"]')
        ?.text
        .trim();
    final hometown = document
        .querySelector('span[itemprop="addressLocality"]')
        ?.text
        .trim();

    String? ageText;
    for (final tr in document.querySelectorAll('table tr')) {
      if (tr.querySelector('td')?.text.trim() == 'AGE') {
        ageText = tr.querySelector('td b')?.text.trim();
        break;
      }
    }
    final age = ageText == null ? null : int.tryParse(ageText);
    final birthDate = document
        .querySelector('span[itemprop="birthDate"]')
        ?.text
        .trim();
    final height = _valueWithMetric(
      document.querySelector('b[itemprop="height"]'),
    );
    final weight = _valueWithMetric(
      document.querySelector('b[itemprop="weight"]'),
    );
    final association = document
        .querySelector('span[itemprop="memberOf"] span[itemprop="name"]')
        ?.text
        .trim();
    final weightClass = document
        .querySelector('.association-class a[href*="weightclass="]')
        ?.text
        .trim();

    final winsCountText = document
        .querySelector('.wins .winloses span:last-child')
        ?.text
        .trim();
    final lossesCountText = document
        .querySelector('.loses .winloses span:last-child')
        ?.text
        .trim();

    return FighterProfile(
      name: name,
      nationality: nationality,
      hometown: hometown,
      age: age,
      birthDate: birthDate,
      height: height,
      weight: weight,
      association: association,
      weightClass: weightClass,
      wins: int.tryParse(winsCountText ?? '') ?? 0,
      losses: int.tryParse(lossesCountText ?? '') ?? 0,
      winsBreakdown: _parseRecordBreakdown(document, '.wins'),
      lossesBreakdown: _parseRecordBreakdown(document, '.loses'),
      fightHistory: _parseFightHistory(document),
    );
  }

  /// Sherdog keeps professional and amateur bouts in separate tables under
  /// their own "Fight History" headings, so each table is read on its own to
  /// keep track of which side of the record its rows belong to.
  List<FighterFightRecord> _parseFightHistory(Document document) {
    final history = <FighterFightRecord>[];
    for (final table in document.querySelectorAll('table.new_table.fighter')) {
      final isAmateur = _isAmateurHistoryTable(table);
      for (final row in table.querySelectorAll('tr')) {
        if (row.classes.contains('table_head')) continue;
        final record = _parseFightHistoryRow(row, isAmateur: isAmateur);
        if (record != null) history.add(record);
      }
    }
    history.sort((a, b) {
      final dateA = _parseHistoryDate(a.eventDateText);
      final dateB = _parseHistoryDate(b.eventDateText);
      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;
      return dateB.compareTo(dateA);
    });
    return history;
  }

  /// Sherdog puts the "Fight History - Amateur" title in `.slanted_title`
  /// inside the same `<section>` as the table, not as an `h2` sibling.
  bool _isAmateurHistoryTable(Element table) {
    Element? section = table;
    while (section != null && section.localName != 'section') {
      section = section.parent;
    }
    final scope = section ?? table.parent ?? table;
    final title =
        scope.querySelector('.slanted_title') ??
        scope.querySelector('h2') ??
        scope.querySelector('.module_header');
    final text = (title ?? scope).text.trim().toLowerCase();
    return text.contains('fight history') && text.contains('amateur');
  }

  /// Cells like `<b itemprop="height">5'7"</b> <em>/</em> 170.18 cm` already
  /// carry the metric conversion right after the slash - just reformat it
  /// as "5'7" (170.18 cm)" instead of discarding it.
  String? _valueWithMetric(Element? valueEl) {
    final cell = valueEl?.parent;
    if (cell == null) return null;
    final parts = cell.text.trim().split('/');
    if (parts.length != 2) {
      return cell.text.trim().isEmpty ? null : cell.text.trim();
    }
    return '${parts[0].trim()} (${parts[1].trim()})';
  }

  static const _historyMonths = {
    'Jan': 1,
    'Feb': 2,
    'Mar': 3,
    'Apr': 4,
    'May': 5,
    'Jun': 6,
    'Jul': 7,
    'Aug': 8,
    'Sep': 9,
    'Oct': 10,
    'Nov': 11,
    'Dec': 12,
  };

  DateTime? _parseHistoryDate(String? text) {
    if (text == null) return null;
    final parts = text.split('/').map((p) => p.trim()).toList();
    if (parts.length != 3) return null;
    final month = _historyMonths[parts[0]];
    final day = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (month == null || day == null || year == null) return null;
    return DateTime(year, month, day);
  }

  RecordBreakdown _parseRecordBreakdown(
    Document document,
    String scopeSelector,
  ) {
    final meters = document.querySelectorAll('$scopeSelector .meter');
    RecordMeter meterAt(int index) {
      if (index >= meters.length) {
        return const RecordMeter(count: 0, percent: 0);
      }
      final meter = meters[index];
      final count =
          int.tryParse(meter.querySelector('.pl')?.text.trim() ?? '') ?? 0;
      final percent =
          int.tryParse(
            (meter.querySelector('.pr')?.text.trim() ?? '').replaceAll('%', ''),
          ) ??
          0;
      return RecordMeter(count: count, percent: percent);
    }

    return RecordBreakdown(
      koTko: meterAt(0),
      submissions: meterAt(1),
      decisions: meterAt(2),
    );
  }

  FighterFightRecord? _parseFightHistoryRow(
    Element row, {
    required bool isAmateur,
  }) {
    final cells = row.querySelectorAll('td');
    if (cells.length < 4) return null;

    final opponentLink = cells[1].querySelector('a');
    final eventLink = cells[2].querySelector('a');
    final winby = cells[3];

    return FighterFightRecord(
      outcome: _parseOutcome(cells[0].querySelector('.final_result')),
      opponentName: opponentLink?.text.trim() ?? '',
      opponentUrl: opponentLink?.attributes['href'] == null
          ? null
          : _absoluteUrl(opponentLink!.attributes['href']!),
      eventName: eventLink?.text.trim() ?? '',
      eventUrl: eventLink?.attributes['href'] == null
          ? null
          : _absoluteUrl(eventLink!.attributes['href']!),
      eventDateText: cells[2].querySelector('.sub_line')?.text.trim(),
      method: winby.querySelector('b')?.text.trim(),
      referee: winby.querySelector('.sub_line')?.text.trim(),
      round: cells.length > 4 ? cells[4].text.trim() : null,
      time: cells.length > 5 ? cells[5].text.trim() : null,
      isAmateur: isAmateur,
    );
  }

  static const _requestTimeout = Duration(seconds: 12);

  Future<Document> _fetchDocument(String url) async {
    final stopwatch = Stopwatch()..start();
    print('[Sherdog] GET $url');
    http.Response response;
    try {
      response = await _client
          .get(Uri.parse(url), headers: const {'User-Agent': _userAgent})
          .timeout(_requestTimeout);
    } on TimeoutException catch (e) {
      print(
        '[Sherdog] $url -> timeout after ${stopwatch.elapsedMilliseconds}ms',
      );
      throw MmaEventsException('Sherdog took too long to respond', e);
    } catch (e) {
      print(
        '[Sherdog] $url -> failed after ${stopwatch.elapsedMilliseconds}ms: $e',
      );
      throw MmaEventsException('Could not reach Sherdog', e);
    }
    print(
      '[Sherdog] $url -> ${response.statusCode} '
      '(${response.bodyBytes.length}B) in ${stopwatch.elapsedMilliseconds}ms',
    );
    if (response.statusCode != 200) {
      throw MmaEventsException('Sherdog returned HTTP ${response.statusCode}');
    }
    return html_parser.parse(response.body);
  }

  List<Element> _eventTables(Document document) =>
      document.querySelectorAll('table.new_table.event');

  List<MmaEvent> _parseRows(Element table, {required bool isUpcoming}) {
    final rows = table.querySelectorAll(
      'tr[itemtype="http://schema.org/Event"]',
    );
    return rows
        .map((row) => _parseRow(row, isUpcoming: isUpcoming))
        .whereType<MmaEvent>()
        .toList();
  }

  MmaEvent? _parseRow(Element row, {required bool isUpcoming}) {
    final dateStr = row
        .querySelector('meta[itemprop="startDate"]')
        ?.attributes['content'];
    final href = row.querySelector('a[itemprop="url"]')?.attributes['href'];
    final title = row.querySelector('span[itemprop="name"]')?.text.trim();
    final location =
        row.querySelector('td[itemprop="location"]')?.text.trim() ?? '';

    if (dateStr == null || href == null || title == null) return null;

    final date = DateTime.tryParse(dateStr);
    if (date == null) return null;

    // Sherdog titles look like "UFC 331 - Van vs. Pantoja 2": everything
    // before " - " is the event name, everything after is the matchup.
    final separator = title.indexOf(' - ');
    final eventName = separator == -1 ? title : title.substring(0, separator);
    final matchup = separator == -1
        ? null
        : title.substring(separator + 3).trim();

    final idMatch = RegExp(r'-(\d+)$').firstMatch(href);

    return MmaEvent(
      id: idMatch?.group(1) ?? href,
      eventName: eventName.trim(),
      matchup: matchup,
      dateUtc: date.toUtc(),
      location: location,
      url: href.startsWith('http') ? href : 'https://www.sherdog.com$href',
      isUpcoming: isUpcoming,
    );
  }

  /// The headliner is rendered as a standalone `.fight_card` block (fighter
  /// photos/records either side of a `.versus` column) rather than as a row
  /// in the results table below it, so it needs its own parser.
  EventFight? _parseHeadlinerFight(Element card) {
    final left = card.querySelector('.fighter.left_side');
    final right = card.querySelector('.fighter.right_side');
    if (left == null || right == null) return null;

    final center = card.querySelector('.versus');
    final resume = card.parent?.querySelector('table.fight_card_resume');

    return EventFight(
      fighterA: _fighterName(left),
      fighterB: _fighterName(right),
      fighterAUrl: _fighterUrl(left),
      fighterBUrl: _fighterUrl(right),
      weightClass: center?.querySelector('.weight_class')?.text.trim() ?? '',
      isTitleFight: center?.querySelector('.title_fight') != null,
      outcomeA: _parseOutcome(left.querySelector('.final_result')),
      outcomeB: _parseOutcome(right.querySelector('.final_result')),
      method: resume == null ? null : _resumeField(resume, 'Method'),
      round: resume == null ? null : _resumeField(resume, 'Round'),
      time: resume == null ? null : _resumeField(resume, 'Time'),
      referee: resume == null ? null : _resumeField(resume, 'Referee'),
    );
  }

  /// Every other bout is a `tr[itemprop="subEvent"]` row in a `.new_table`
  /// (classed `result` once fought, `upcoming` before then): fighter cells
  /// either side of a weight-class column, followed by method/round/time
  /// cells that are only present once the fight has happened.
  EventFight? _parseCardRow(Element row) {
    final left = row.querySelector('td.text_right');
    final right = row.querySelector('td.text_left');
    if (left == null || right == null) return null;

    final center = row.querySelector('td.text_center');
    final winby = row.querySelector('td.winby');
    final cells = row.querySelectorAll('td');
    final hasResult = cells.length >= 7;

    return EventFight(
      fighterA: _fighterName(left),
      fighterB: _fighterName(right),
      fighterAUrl: _fighterUrl(left),
      fighterBUrl: _fighterUrl(right),
      weightClass: center?.querySelector('.weight_class')?.text.trim() ?? '',
      isTitleFight: center?.querySelector('.title_fight') != null,
      outcomeA: _parseOutcome(left.querySelector('.final_result')),
      outcomeB: _parseOutcome(right.querySelector('.final_result')),
      method: winby?.querySelector('b')?.text.trim(),
      round: hasResult ? cells[cells.length - 2].text.trim() : null,
      time: hasResult ? cells[cells.length - 1].text.trim() : null,
      referee: winby?.querySelector('.sub_line')?.text.trim(),
    );
  }

  String? _fighterUrl(Element fighterCell) {
    final href = fighterCell
        .querySelector('a[itemprop="url"]')
        ?.attributes['href'];
    return href == null ? null : _absoluteUrl(href);
  }

  String _absoluteUrl(String href) =>
      href.startsWith('http') ? href : 'https://www.sherdog.com$href';

  String _fighterName(Element fighterCell) {
    final nameSpan = fighterCell.querySelector('span[itemprop="name"]');
    if (nameSpan == null) return '';
    // Fighter names are split across lines with a bare `<br>` (e.g.
    // "Kevin<br>Vallejos"), which `.text` would otherwise glue together
    // with no space.
    return nameSpan.nodes
        .map(
          (node) =>
              node is Element && node.localName == 'br' ? ' ' : node.text ?? '',
        )
        .join()
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  FightOutcome _parseOutcome(Element? finalResult) {
    if (finalResult == null) return FightOutcome.pending;
    if (finalResult.classes.contains('win')) return FightOutcome.win;
    if (finalResult.classes.contains('loss')) return FightOutcome.loss;
    if (finalResult.classes.contains('draw')) return FightOutcome.draw;
    if (finalResult.classes.contains('no_contest') ||
        finalResult.text.trim().toLowerCase().contains('no contest')) {
      return FightOutcome.noContest;
    }
    return FightOutcome.pending;
  }

  /// Cells in `fight_card_resume` look like `<em>Method</em><br> KO
  /// (Punches)`, so the label text is stripped from the front of the cell's
  /// full text to get just the value.
  String? _resumeField(Element resume, String label) {
    for (final cell in resume.querySelectorAll('td')) {
      final em = cell.querySelector('em');
      if (em?.text.trim() != label) continue;
      final value = cell.text.trim().substring(em!.text.trim().length).trim();
      return value.isEmpty ? null : value;
    }
    return null;
  }
}
