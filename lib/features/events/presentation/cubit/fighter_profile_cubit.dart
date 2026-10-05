import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/logger/app_logger.dart';
import '../../domain/entities/fighter_profile.dart';
import '../../domain/usecases/get_fighter_profile_usecase.dart';
import 'load_state.dart';

typedef FighterProfileState = LoadState<FighterProfile>;

/// A fighter profile is fetched at most once per fighter: [load] serves the
/// cached copy if present, and the network is never hit again on its own.
/// [refresh] (pull-to-refresh) is the only way to force a re-fetch, and it
/// overwrites the cache with the new result.
class FighterProfileCubit extends Cubit<FighterProfileState> {
  FighterProfileCubit(this._getFighterProfile, {required this.fighterUrl})
    : super(const FighterProfileState.loading());

  final GetFighterProfileUsecase _getFighterProfile;
  final String fighterUrl;

  Future<void> load() => _run(refresh: false);

  Future<void> refresh() => _run(refresh: true);

  Future<void> _run({required bool refresh}) async {
    try {
      final profile = await _getFighterProfile(fighterUrl, refresh: refresh);
      if (!isClosed) emit(FighterProfileState.success(profile));
    } catch (e, s) {
      AppLogger.error('loading fighter profile failed', e, s);
      // Keep showing the last good (possibly cached) data if we have any.
      if (!isClosed && !state.hasData) emit(FighterProfileState.failure(e));
    }
  }
}
