import 'package:equatable/equatable.dart';

import '../../domain/entities/mma_event.dart';

class PastEventsState extends Equatable {
  final List<MmaEvent> events;
  final bool hasMore;
  final bool isLoadingMore;
  final Object? error;

  const PastEventsState({
    this.events = const [],
    this.hasMore = true,
    this.isLoadingMore = false,
    this.error,
  });

  @override
  List<Object?> get props => [events, hasMore, isLoadingMore, error];
}
