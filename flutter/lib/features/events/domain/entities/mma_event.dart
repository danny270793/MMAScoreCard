class MmaEvent {
  final String id;
  final String eventName;
  final String? matchup;
  final DateTime dateUtc;
  final String location;
  final String url;
  final bool isUpcoming;

  const MmaEvent({
    required this.id,
    required this.eventName,
    required this.dateUtc,
    required this.location,
    required this.url,
    required this.isUpcoming,
    this.matchup,
  });

  /// Whole calendar days between [from] and the event date.
  int daysUntil(DateTime from) {
    final target = DateTime.utc(dateUtc.year, dateUtc.month, dateUtc.day);
    final today = DateTime.utc(from.year, from.month, from.day);
    return target.difference(today).inDays;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'eventName': eventName,
    'matchup': matchup,
    'dateUtc': dateUtc.toIso8601String(),
    'location': location,
    'url': url,
    'isUpcoming': isUpcoming,
  };

  factory MmaEvent.fromJson(Map<String, dynamic> json) => MmaEvent(
    id: json['id'] as String,
    eventName: json['eventName'] as String,
    matchup: json['matchup'] as String?,
    dateUtc: DateTime.parse(json['dateUtc'] as String),
    location: json['location'] as String,
    url: json['url'] as String,
    isUpcoming: json['isUpcoming'] as bool,
  );
}
