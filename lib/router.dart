import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injection.dart';
import 'features/auth/presentation/cubit/auth_session_cubit.dart';
import 'features/auth/presentation/cubit/auth_session_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/events/domain/entities/event_fight.dart';
import 'features/events/domain/entities/mma_event.dart';
import 'pages/event_detail_page.dart';
import 'pages/events_home_page.dart';
import 'pages/fight_detail_page.dart';
import 'pages/fighter_detail_page.dart';
import 'pages/legal_info_page.dart';
import 'pages/settings_cache_page.dart';
import 'pages/settings_page.dart';
import 'pages/splash_page.dart';

/// Re-runs the router's redirect whenever the auth session changes.
class _AuthSessionRefresh extends ChangeNotifier {
  _AuthSessionRefresh(AuthSessionCubit cubit) {
    _subscription = cubit.stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthSessionState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter buildRouter() {
  final session = getIt<AuthSessionCubit>();
  return GoRouter(
    initialLocation: '/',
    refreshListenable: _AuthSessionRefresh(session),
    redirect: (context, state) {
      final mode = session.state.mode;
      final loc = state.matchedLocation;

      if (mode == AuthAccessMode.loading) return loc == '/' ? null : '/';
      if (mode == AuthAccessMode.signedOut) {
        return loc == '/login' ? null : '/login';
      }
      if (loc == '/' || loc == '/login') return '/events';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/events',
        builder: (context, state) => const EventsHomePage(),
      ),
      GoRoute(
        path: '/event',
        builder: (context, state) =>
            EventDetailPage(event: state.extra! as MmaEvent),
      ),
      GoRoute(
        path: '/fight',
        builder: (context, state) {
          final (event, fight) = state.extra! as (MmaEvent, EventFight);
          return FightDetailPage(event: event, fight: fight);
        },
      ),
      GoRoute(
        path: '/fighter',
        builder: (context, state) {
          final args = state.extra! as FighterDetailArgs;
          return FighterDetailPage(
            fighterName: args.fighterName,
            fighterUrl: args.fighterUrl,
            currentEventUrl: args.currentEventUrl,
            currentEventIsTitleFight: args.currentEventIsTitleFight,
          );
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
        routes: [
          GoRoute(
            path: 'about',
            builder: (context, state) =>
                const LegalInfoPage(kind: LegalInfoKind.about),
          ),
          GoRoute(
            path: 'privacy',
            builder: (context, state) =>
                const LegalInfoPage(kind: LegalInfoKind.privacy),
          ),
          GoRoute(
            path: 'terms',
            builder: (context, state) =>
                const LegalInfoPage(kind: LegalInfoKind.terms),
          ),
          GoRoute(
            path: 'cache',
            builder: (context, state) => const SettingsCachePage(),
          ),
        ],
      ),
    ],
  );
}
