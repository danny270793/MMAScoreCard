import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mmascorecard/core/di/injection.dart';
import 'package:mmascorecard/core/security/app_biometric_unlock_controller.dart';
import 'package:mmascorecard/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:mmascorecard/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mmascorecard/features/auth/domain/entities/user_entity.dart';
import 'package:mmascorecard/features/events/data/datasources/mma_events_remote_datasource.dart';
import 'package:mmascorecard/features/events/domain/entities/event_fight.dart';
import 'package:mmascorecard/features/events/domain/entities/events_page.dart';
import 'package:mmascorecard/features/events/domain/entities/fighter_profile.dart';
import 'package:mmascorecard/features/events/domain/entities/mma_event.dart';
import 'package:mmascorecard/main.dart';

void main() {
  tearDown(() => getIt.reset());

  testWidgets('shows login before access is selected', (tester) async {
    final auth = FakeAuthDatasource();
    await _pumpApp(tester, auth: auth);

    expect(find.text('Sign in'), findsWidgets);
    expect(find.text('Continue without account'), findsOneWidget);
  });

  testWidgets('restores persistent guest access', (tester) async {
    final auth = FakeAuthDatasource();
    await _pumpApp(
      tester,
      auth: auth,
      preferences: {AuthLocalDatasource.guestPreferenceKey: true},
    );

    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('Past'), findsOneWidget);
  });

  testWidgets('signs in with email and password', (tester) async {
    final auth = FakeAuthDatasource();
    await _pumpApp(tester, auth: auth);

    await tester.enterText(find.byType(EditableText).at(0), 'fan@example.com');
    await tester.enterText(find.byType(EditableText).at(1), 'password');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(auth.lastEmail, 'fan@example.com');
    expect(auth.lastPassword, 'password');
    expect(find.text('Upcoming'), findsOneWidget);
  });

  testWidgets('guest settings hide profile and offer sign in', (tester) async {
    final auth = FakeAuthDatasource();
    await _pumpApp(
      tester,
      auth: auth,
      preferences: {AuthLocalDatasource.guestPreferenceKey: true},
    );
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsNothing);
    expect(find.text('Change email'), findsNothing);
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Rate on Google Play'), 300);
    expect(find.text('Rate on Google Play'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.widgetWithText(OutlinedButton, 'Sign in'),
      300,
    );
    expect(find.widgetWithText(OutlinedButton, 'Sign in'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Continue without account'), findsOneWidget);
  });

  testWidgets('authenticated settings show account and biometrics', (
    tester,
  ) async {
    final auth = FakeAuthDatasource(
      initialUser: const UserEntity(email: 'fan@example.com'),
    );
    await _pumpApp(tester, auth: auth);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.text('fan@example.com'), findsOneWidget);
    expect(find.text('Change password'), findsOneWidget);
    expect(find.text('Face ID / biometric unlock'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.widgetWithText(FilledButton, 'Sign out'),
      300,
    );
    expect(find.widgetWithText(FilledButton, 'Sign out'), findsOneWidget);
  });

  testWidgets('settings is translated to Spanish', (tester) async {
    final auth = FakeAuthDatasource();
    await _pumpApp(
      tester,
      auth: auth,
      preferences: {
        AuthLocalDatasource.guestPreferenceKey: true,
        'language_code': 'es',
      },
    );
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Ajustes'), findsOneWidget);
    expect(find.text('Idioma'), findsOneWidget);
  });
}

Future<void> _pumpApp(
  WidgetTester tester, {
  required FakeAuthDatasource auth,
  Map<String, Object> preferences = const {},
}) async {
  SharedPreferences.setMockInitialValues(preferences);
  final prefs = await SharedPreferences.getInstance();
  setupDi(
    prefs: prefs,
    authRemoteDatasource: auth,
    biometricService: FakeBiometricService(),
    eventsRemoteDatasource: FakeEventsDatasource(),
  );
  await bootstrap();

  await tester.pumpWidget(const App());
  await tester.pumpAndSettle();
}

class FakeAuthDatasource implements AuthRemoteDatasource {
  FakeAuthDatasource({UserEntity? initialUser}) : _user = initialUser;

  final _changes = StreamController<UserEntity?>.broadcast();
  UserEntity? _user;
  String? lastEmail;
  String? lastPassword;

  @override
  Stream<UserEntity?> get authStateChanges => _changes.stream;

  @override
  UserEntity? get currentUser => _user;

  @override
  Future<void> signIn({required String email, required String password}) async {
    lastEmail = email;
    lastPassword = password;
    _user = UserEntity(email: email);
    _changes.add(_user);
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _changes.add(null);
  }

  @override
  Future<void> updateEmail({required String newEmail}) async {
    _user = UserEntity(email: newEmail);
    _changes.add(_user);
  }

  @override
  Future<void> updatePassword({required String newPassword}) async {}
}

class FakeBiometricService implements BiometricService {
  @override
  Future<bool> authenticate(String reason) async => true;

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
