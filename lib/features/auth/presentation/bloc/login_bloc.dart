import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/logger/app_logger.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final SignInUsecase _signIn;

  LoginBloc({required this._signIn}) : super(const LoginInitial()) {
    on<LoginSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    AppLogger.debug('sign in submitted');
    emit(const LoginLoading());
    try {
      await _signIn(email: event.email, password: event.password);
      AppLogger.info('sign in success');
      emit(const LoginSuccess());
    } on AuthException catch (e) {
      AppLogger.warn('sign in failed — ${e.message}');
      emit(LoginFailure(e.message));
    } catch (e, s) {
      AppLogger.error('unexpected error during sign in', e, s);
      emit(const LoginFailure(null));
    }
  }
}
