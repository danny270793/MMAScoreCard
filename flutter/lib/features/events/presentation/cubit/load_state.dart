import 'package:equatable/equatable.dart';

enum LoadStatus { loading, success, failure }

/// Loading / data / error state shared by the single-resource event cubits.
///
/// A failed refresh keeps the last good [data] (status stays
/// [LoadStatus.success]); [LoadStatus.failure] is only reached when there
/// is nothing to show.
class LoadState<T> extends Equatable {
  const LoadState._(this.status, this.data, this.error);

  const LoadState.loading() : this._(LoadStatus.loading, null, null);

  const LoadState.success(T data) : this._(LoadStatus.success, data, null);

  const LoadState.failure(Object error)
    : this._(LoadStatus.failure, null, error);

  final LoadStatus status;
  final T? data;
  final Object? error;

  bool get hasData => status == LoadStatus.success;

  @override
  List<Object?> get props => [status, data, error];
}
