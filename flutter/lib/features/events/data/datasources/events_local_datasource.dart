import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/event_fight.dart';
import '../../domain/entities/fighter_profile.dart';
import '../../domain/entities/mma_event.dart';
import '../../domain/entities/cached_request_info.dart';

const _orgUrl =
    'https://www.sherdog.com/organizations/Ultimate-Fighting-Championship-UFC-2';

/// Persists every Sherdog request (event listings, fight cards, fighter
/// profiles) so none of them are ever fetched more than once: once a URL
/// has a cache entry, all reads come from here and the network is never
/// hit again for it.
class EventsLocalDatasource {
  EventsLocalDatasource(this._prefs);

  final SharedPreferences _prefs;

  static const _upcomingKey = 'events_cache_upcoming';
  static const _pastPagesKey = 'events_cache_past_pages';
  static const _pastHasMoreKey = 'events_cache_past_has_more';
  static const _fightUrlsKey = 'events_cache_fight_urls';
  static const _fighterUrlsKey = 'events_cache_fighter_urls';
  static String _pastPageKey(int page) => 'events_cache_past_page_$page';
  static String _fightKey(String eventUrl) => 'events_cache_fight_$eventUrl';
  static String _fighterKey(String fighterUrl) =>
      'events_cache_fighter_$fighterUrl';
  static String _cachedAtKey(String key) => '${key}_cached_at';
  static String _refreshedAtKey(String key) => '${key}_refreshed_at';
  static String _readCountKey(String key) => '${key}_read_count';

  List<MmaEvent>? loadUpcoming() => _loadList(_upcomingKey);

  Future<void> saveUpcoming(List<MmaEvent> events) =>
      _saveList(_upcomingKey, events);

  List<int> loadPastPageNumbers() {
    final raw = _prefs.getStringList(_pastPagesKey);
    if (raw == null) return const [];
    return raw.map(int.parse).toList()..sort();
  }

  List<MmaEvent>? loadPastPage(int page) => _loadList(_pastPageKey(page));

  bool loadPastHasMore() => _prefs.getBool(_pastHasMoreKey) ?? true;

  Future<void> savePastPage(
    int page,
    List<MmaEvent> events, {
    required bool hasMore,
  }) async {
    await _saveList(_pastPageKey(page), events);
    final pages = loadPastPageNumbers().toSet()..add(page);
    final sorted = pages.toList()..sort();
    await _prefs.setStringList(
      _pastPagesKey,
      sorted.map((p) => p.toString()).toList(),
    );
    await _prefs.setBool(_pastHasMoreKey, hasMore);
  }

  List<String> _fightUrls() => _prefs.getStringList(_fightUrlsKey) ?? const [];

  List<String> _fighterUrls() =>
      _prefs.getStringList(_fighterUrlsKey) ?? const [];

  List<EventFight>? loadFights(String eventUrl) {
    final key = _fightKey(eventUrl);
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    _recordRead(key);
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => EventFight.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveFights(String eventUrl, List<EventFight> fights) async {
    final key = _fightKey(eventUrl);
    final encoded = jsonEncode(fights.map((f) => f.toJson()).toList());
    await _prefs.setString(key, encoded);
    await _markSaved(key);
    final urls = _fightUrls().toSet()..add(eventUrl);
    await _prefs.setStringList(_fightUrlsKey, urls.toList());
  }

  FighterProfile? loadFighterProfile(String fighterUrl) {
    final key = _fighterKey(fighterUrl);
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    _recordRead(key);
    return FighterProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveFighterProfile(
    String fighterUrl,
    FighterProfile profile,
  ) async {
    final key = _fighterKey(fighterUrl);
    await _prefs.setString(key, jsonEncode(profile.toJson()));
    await _markSaved(key);
    final urls = _fighterUrls().toSet()..add(fighterUrl);
    await _prefs.setStringList(_fighterUrlsKey, urls.toList());
  }

  /// Every cached Sherdog request currently stored on disk, newest first.
  List<CachedRequestInfo> listCachedRequests() {
    final entries = <CachedRequestInfo>[];

    final upcomingRaw = _prefs.getString(_upcomingKey);
    if (upcomingRaw != null) {
      entries.add(
        CachedRequestInfo(
          url: _orgUrl,
          cachedAt: _cachedAtFor(_upcomingKey),
          refreshedAt: _refreshedAtFor(_upcomingKey),
          readCount: _readCountFor(_upcomingKey),
          sizeBytes: utf8.encode(upcomingRaw).length,
          kind: CachedRequestKind.upcoming,
        ),
      );
    }

    for (final page in loadPastPageNumbers()) {
      final key = _pastPageKey(page);
      final raw = _prefs.getString(key);
      if (raw == null) continue;
      entries.add(
        CachedRequestInfo(
          url: '$_orgUrl/recent-events/$page',
          cachedAt: _cachedAtFor(key),
          refreshedAt: _refreshedAtFor(key),
          readCount: _readCountFor(key),
          sizeBytes: utf8.encode(raw).length,
          kind: CachedRequestKind.pastPage,
          page: page,
        ),
      );
    }

    for (final url in _fightUrls()) {
      final key = _fightKey(url);
      final raw = _prefs.getString(key);
      if (raw == null) continue;
      entries.add(
        CachedRequestInfo(
          url: url,
          cachedAt: _cachedAtFor(key),
          refreshedAt: _refreshedAtFor(key),
          readCount: _readCountFor(key),
          sizeBytes: utf8.encode(raw).length,
          kind: CachedRequestKind.fightCard,
        ),
      );
    }

    for (final url in _fighterUrls()) {
      final key = _fighterKey(url);
      final raw = _prefs.getString(key);
      if (raw == null) continue;
      entries.add(
        CachedRequestInfo(
          url: url,
          cachedAt: _cachedAtFor(key),
          refreshedAt: _refreshedAtFor(key),
          readCount: _readCountFor(key),
          sizeBytes: utf8.encode(raw).length,
          kind: CachedRequestKind.fighterProfile,
        ),
      );
    }

    entries.sort((a, b) => b.refreshedAt.compareTo(a.refreshedAt));
    return entries;
  }

  DateTime _cachedAtFor(String key) {
    final raw = _prefs.getString(_cachedAtKey(key));
    return raw == null
        ? DateTime.fromMillisecondsSinceEpoch(0)
        : DateTime.parse(raw);
  }

  DateTime _refreshedAtFor(String key) {
    final raw = _prefs.getString(_refreshedAtKey(key));
    return raw == null ? _cachedAtFor(key) : DateTime.parse(raw);
  }

  int _readCountFor(String key) => _prefs.getInt(_readCountKey(key)) ?? 0;

  /// Records a cache write: the first-cached timestamp is set once and kept
  /// forever, while the refreshed timestamp is updated on every write - so a
  /// pull-to-refresh updates "refreshed" without resetting "cached".
  Future<void> _markSaved(String key) async {
    final now = DateTime.now().toUtc().toIso8601String();
    if (_prefs.getString(_cachedAtKey(key)) == null) {
      await _prefs.setString(_cachedAtKey(key), now);
    }
    await _prefs.setString(_refreshedAtKey(key), now);
  }

  /// Records a cache read. Fire-and-forget: read count is a display-only
  /// counter, not something callers need to await, and it must never be
  /// reset by a later [_markSaved] call.
  void _recordRead(String key) {
    unawaited(_prefs.setInt(_readCountKey(key), _readCountFor(key) + 1));
  }

  List<MmaEvent>? _loadList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    _recordRead(key);
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => MmaEvent.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveList(String key, List<MmaEvent> events) async {
    final encoded = jsonEncode(events.map((e) => e.toJson()).toList());
    await _prefs.setString(key, encoded);
    await _markSaved(key);
  }
}
