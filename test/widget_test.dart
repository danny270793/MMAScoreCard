import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mmascorecard/core/persistence/shared_preferences_provider.dart';
import 'package:mmascorecard/features/auth/application/auth_controller.dart';
import 'package:mmascorecard/features/auth/application/biometric_controller.dart';
import 'package:mmascorecard/features/auth/domain/auth_service.dart';
import 'package:mmascorecard/main.dart';

void main() {
  testWidgets('shows login before access is selected', (tester) async {
    final auth = FakeAuthService();
    await _pumpApp(tester, auth: auth);
    await tester.pump();

    expect(find.text('Sign in'), findsWidgets);
    expect(find.text('Continue without account'), findsOneWidget);
  });

  testWidgets('restores persistent guest access', (tester) async {
    final auth = FakeAuthService();
    await _pumpApp(
      tester,
      auth: auth,
      preferences: {AuthController.guestPreferenceKey: true},
    );
    await tester.pump();

    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('Past'), findsOneWidget);
  });

  testWidgets('signs in with email and password', (tester) async {
    final auth = FakeAuthService();
    await _pumpApp(tester, auth: auth);
    await tester.pump();

    await tester.enterText(find.byType(EditableText).at(0), 'fan@example.com');
    await tester.enterText(find.byType(EditableText).at(1), 'password');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();

    expect(auth.lastEmail, 'fan@example.com');
    expect(auth.lastPassword, 'password');
    expect(find.text('Upcoming'), findsOneWidget);
  });

  testWidgets('guest settings hide profile and offer sign in', (tester) async {
    final auth = FakeAuthService();
    await _pumpApp(
      tester,
      auth: auth,
      preferences: {AuthController.guestPreferenceKey: true},
    );
    await tester.pump();
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsNothing);
    expect(find.text('Change email'), findsNothing);
    await tester.scrollUntilVisible(
      find.widgetWithText(OutlinedButton, 'Sign in'),
      300,
    );
    expect(find.widgetWithText(OutlinedButton, 'Sign in'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
  });

  testWidgets('authenticated settings show account and biometrics', (
    tester,
  ) async {
    final auth = FakeAuthService(
      initialUser: const AuthUser(email: 'fan@example.com'),
    );
    await _pumpApp(tester, auth: auth);
    await tester.pump();
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
}

Future<void> _pumpApp(
  WidgetTester tester, {
  required FakeAuthService auth,
  Map<String, Object> preferences = const {},
}) async {
  SharedPreferences.setMockInitialValues(preferences);
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authServiceProvider.overrideWithValue(auth),
        biometricServiceProvider.overrideWithValue(FakeBiometricService()),
      ],
      child: const MmaScorecardApp(),
    ),
  );
}

class FakeAuthService implements AuthService {
  FakeAuthService({AuthUser? initialUser}) : _user = initialUser;

  final _changes = StreamController<AuthUser?>.broadcast();
  AuthUser? _user;
  String? lastEmail;
  String? lastPassword;

  @override
  Stream<AuthUser?> get authStateChanges => _changes.stream;

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> signIn({required String email, required String password}) async {
    lastEmail = email;
    lastPassword = password;
    _user = AuthUser(email: email);
    _changes.add(_user);
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _changes.add(null);
  }

  @override
  Future<void> updateEmail(String email) async {
    _user = AuthUser(email: email);
    _changes.add(_user);
  }

  @override
  Future<void> updatePassword(String password) async {}
}

class FakeBiometricService implements BiometricService {
  @override
  Future<bool> authenticate(String reason) async => true;

  @override
  Future<bool> isAvailable() async => true;
}
