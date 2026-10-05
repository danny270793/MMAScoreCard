import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mmascorecard/core/di/injection.dart';
import 'package:mmascorecard/core/security/app_biometric_unlock_controller.dart';
import 'package:mmascorecard/features/events/data/datasources/mma_events_remote_datasource.dart';
import 'package:mmascorecard/features/events/domain/entities/event_fight.dart';
import 'package:mmascorecard/features/events/domain/entities/events_page.dart';
import 'package:mmascorecard/features/events/domain/entities/fighter_profile.dart';
import 'package:mmascorecard/features/events/domain/entities/mma_event.dart';
import 'package:mmascorecard/main.dart';

void main() {
  tearDown(() => getIt.reset());

  testWidgets('opens directly on events without a login', (tester) async {
    await _pumpApp(tester);

    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('Past'), findsOneWidget);
    expect(find.text('Sign in'), findsNothing);
  });

  testWidgets('settings show biometrics, cache and rating without sign in', (
    tester,
  ) async {
    await _pumpApp(tester);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Face ID / biometric unlock'), findsOneWidget);
    expect(find.byType(SwitchListTile), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Cached records'), 300);
    expect(find.text('Cached records'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Rate on Google Play'), 300);
    expect(find.text('Rate on Google Play'), findsOneWidget);
    expect(find.text('Sign in'), findsNothing);
    expect(find.text('Sign out'), findsNothing);
    expect(find.text('Profile'), findsNothing);
  });

  testWidgets('cold start is locked when biometric unlock is enabled', (
    tester,
  ) async {
    final bio = FakeBiometricService();
    await _pumpApp(
      tester,
      biometricService: bio,
      preferences: {'app_biometric_unlock_enabled': true},
    );

    expect(bio.authenticateCalls, 1);
    expect(find.text('Upcoming'), findsOneWidget);
  });

  testWidgets('settings is translated to Spanish', (tester) async {
    await _pumpApp(tester, preferences: {'language_code': 'es'});
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Ajustes'), findsOneWidget);
    expect(find.text('Idioma'), findsOneWidget);
  });
}

Future<void> _pumpApp(
  WidgetTester tester, {
  BiometricService? biometricService,
  Map<String, Object> preferences = const {},
}) async {
  SharedPreferences.setMockInitialValues(preferences);
  final prefs = await SharedPreferences.getInstance();
  setupDi(
    prefs: prefs,
    biometricService: biometricService ?? FakeBiometricService(),
    eventsRemoteDatasource: FakeEventsDatasource(),
  );
  await bootstrap();

  await tester.pumpWidget(const App());
  await tester.pumpAndSettle();
}

class FakeBiometricService implements BiometricService {
  int authenticateCalls = 0;

  @override
  Future<bool> authenticate(String reason) async {
    authenticateCalls++;
    return true;
  }

  @override
  Future<bool> isAvailable() async => true;
}

/// Offline event source so widget tests never hit Sherdog.
class FakeEventsDatasource implements MmaEventsRemoteDatasource {
  @override
  Future<List<MmaEvent>> fetchUpcomingEvents() async => const [];

  @override
  Future<EventsPage> fetchPastEvents({required int page}) async =>
      EventsPage(events: const [], page: page, hasMore: false);

  @override
  Future<List<EventFight>> fetchEventFights(String eventUrl) async => const [];

  @override
  Future<FighterProfile> fetchFighterProfile(String fighterUrl) =>
      throw UnimplementedError();
}
