import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../locale/app_locale_controller.dart';
import '../security/app_biometric_unlock_controller.dart';
import '../theme/app_theme_controller.dart';
import '../../features/events/data/datasources/composite_events_remote_datasource.dart';
import '../../features/events/data/datasources/events_local_datasource.dart';
import '../../features/events/data/datasources/mma_events_remote_datasource.dart';
import '../../features/events/data/datasources/sherdog_events_remote_datasource.dart';
import '../../features/events/data/repositories/events_repository_impl.dart';
import '../../features/events/domain/repositories/events_repository.dart';
import '../../features/events/domain/usecases/fetch_past_events_page_usecase.dart';
import '../../features/events/domain/usecases/get_cached_past_events_usecase.dart';
import '../../features/events/domain/usecases/get_event_fights_usecase.dart';
import '../../features/events/domain/usecases/get_fighter_profile_usecase.dart';
import '../../features/events/domain/usecases/get_upcoming_events_usecase.dart';
import '../../features/events/domain/usecases/list_cached_requests_usecase.dart';
import '../../features/events/presentation/cubit/event_fights_cubit.dart';
import '../../features/events/presentation/cubit/fighter_profile_cubit.dart';
import '../../features/events/presentation/cubit/past_events_cubit.dart';
import '../../features/events/presentation/cubit/upcoming_events_cubit.dart';

final getIt = GetIt.instance;

/// Registers every dependency. Tests can swap the platform-bound pieces
/// (biometrics, MMA event sources) via the optional overrides.
void setupDi({
  required SharedPreferences prefs,
  BiometricService? biometricService,
  MmaEventsRemoteDatasource? eventsRemoteDatasource,
}) {
  getIt.registerSingleton<SharedPreferences>(prefs);

  getIt.registerLazySingleton<AppLocaleController>(AppLocaleController.new);
  getIt.registerLazySingleton<AppThemeController>(AppThemeController.new);
  getIt.registerLazySingleton<BiometricService>(
    () => biometricService ?? LocalBiometricService(),
  );
  getIt.registerLazySingleton<AppBiometricUnlockController>(
    () => AppBiometricUnlockController(getIt()),
  );

  // events
  // Single place to change/add MMA event sources. On error the composite
  // falls through to the next source in the list - add e.g. a UFC.com
  // datasource here later to get automatic fallback.
  getIt.registerLazySingleton<MmaEventsRemoteDatasource>(
    () =>
        eventsRemoteDatasource ??
        CompositeEventsRemoteDatasource([SherdogEventsRemoteDatasource()]),
  );
  getIt.registerLazySingleton<EventsLocalDatasource>(
    () => EventsLocalDatasource(getIt()),
  );
  getIt.registerLazySingleton<EventsRepository>(
    () => EventsRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerFactory<GetUpcomingEventsUsecase>(
    () => GetUpcomingEventsUsecase(getIt()),
  );
  getIt.registerFactory<GetCachedPastEventsUsecase>(
    () => GetCachedPastEventsUsecase(getIt()),
  );
  getIt.registerFactory<FetchPastEventsPageUsecase>(
    () => FetchPastEventsPageUsecase(getIt()),
  );
  getIt.registerFactory<GetEventFightsUsecase>(
    () => GetEventFightsUsecase(getIt()),
  );
  getIt.registerFactory<GetFighterProfileUsecase>(
    () => GetFighterProfileUsecase(getIt()),
  );
  getIt.registerFactory<ListCachedRequestsUsecase>(
    () => ListCachedRequestsUsecase(getIt()),
  );
  getIt.registerFactory<UpcomingEventsCubit>(
    () => UpcomingEventsCubit(getIt()),
  );
  getIt.registerFactory<PastEventsCubit>(
    () => PastEventsCubit(
      getCachedPastEvents: getIt(),
      fetchPastEventsPage: getIt(),
    ),
  );
  getIt.registerFactoryParam<EventFightsCubit, String, void>(
    (eventUrl, _) => EventFightsCubit(getIt(), eventUrl: eventUrl),
  );
  getIt.registerFactoryParam<FighterProfileCubit, String, void>(
    (fighterUrl, _) => FighterProfileCubit(getIt(), fighterUrl: fighterUrl),
  );
}
