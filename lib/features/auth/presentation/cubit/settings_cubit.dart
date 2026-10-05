import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/logger/app_logger.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SignOutUsecase _signOut;

  SettingsCubit({required this._signOut}) : super(const SettingsInitial());

  Future<void> signOut() async {
    AppLogger.debug('sign out requested');
    emit(const SettingsLoading());
    try {
      await _signOut();
      AppLogger.info('sign out success');
      emit(const SettingsSignedOut());
    } on AuthException catch (e) {
      AppLogger.warn('sign out failed — ${e.message}');
      emit(SettingsFailure(e.message));
    } catch (e, s) {
      AppLogger.error('sign out failed', e, s);
      emit(const SettingsFailure(null));
    }
  }
}
