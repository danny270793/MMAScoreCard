import '../entities/cached_request_info.dart';
import '../repositories/events_repository.dart';

class ListCachedRequestsUsecase {
  final EventsRepository _repository;

  const ListCachedRequestsUsecase(this._repository);

  List<CachedRequestInfo> call() => _repository.listCachedRequests();
}
