import 'package:go_router/go_router.dart';

import 'features/events/domain/entities/event_fight.dart';
import 'features/events/domain/entities/mma_event.dart';
import 'pages/event_detail_page.dart';
import 'pages/events_home_page.dart';
import 'pages/fight_detail_page.dart';
import 'pages/fighter_detail_page.dart';
import 'pages/legal_info_page.dart';
import 'pages/settings_cache_page.dart';
import 'pages/settings_page.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/events',
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/events'),
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
