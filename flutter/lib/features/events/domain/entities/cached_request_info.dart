enum CachedRequestKind { upcoming, pastPage, fightCard, fighterProfile }

class CachedRequestInfo {
  const CachedRequestInfo({
    required this.url,
    required this.cachedAt,
    required this.refreshedAt,
    required this.readCount,
    required this.sizeBytes,
    required this.kind,
    this.page,
  });

  final String url;

  /// When this URL was first ever fetched and cached.
  final DateTime cachedAt;

  /// The last time this entry was re-fetched over the network (a
  /// pull-to-refresh). Equal to [cachedAt] until the first refresh.
  final DateTime refreshedAt;

  /// How many times this cached entry has been read/served. Never reset by
  /// a refresh - only a new URL starts back at 0.
  final int readCount;

  final int sizeBytes;
  final CachedRequestKind kind;

  /// Only set for [CachedRequestKind.pastPage] entries.
  final int? page;

  bool get isUpcoming => kind == CachedRequestKind.upcoming;
}

String formatBytes(int bytes) {
  const kb = 1024;
  const mb = kb * 1024;
  const gb = mb * 1024;
  if (bytes >= gb) return '${(bytes / gb).toStringAsFixed(2)} GB';
  if (bytes >= mb) return '${(bytes / mb).toStringAsFixed(2)} MB';
  if (bytes >= kb) return '${(bytes / kb).toStringAsFixed(1)} KB';
  return '$bytes B';
}
