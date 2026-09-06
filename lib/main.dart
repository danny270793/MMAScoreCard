import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/network/dev_certificate_trust.dart';
import 'core/persistence/shared_preferences_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/application/auth_controller.dart';
import 'features/auth/application/biometric_controller.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/events/presentation/pages/events_home_page.dart';
import 'features/settings/application/app_settings_controller.dart';
import 'l10n/generated/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await trustDevCorporateProxyCertificate();
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    publishableKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MmaScorecardApp(),
    ),
  );
}

class MmaScorecardApp extends ConsumerStatefulWidget {
  const MmaScorecardApp({super.key});

  @override
  ConsumerState<MmaScorecardApp> createState() => _MmaScorecardAppState();
}

class _MmaScorecardAppState extends ConsumerState<MmaScorecardApp>
    with WidgetsBindingObserver {
  bool _lockOnNextResume = false;
  bool _biometricLockActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _lockOnNextResume = true;
    } else if (state == AppLifecycleState.resumed && _lockOnNextResume) {
      _lockOnNextResume = false;
      unawaited(_activateResumeLock());
    }
  }

  Future<void> _activateResumeLock() async {
    if (ref.read(authControllerProvider).mode != AuthAccessMode.authenticated) {
      return;
    }
    final controller = ref.read(biometricControllerProvider.notifier);
    final available = await controller.refreshAvailability();
    final enabled = ref.read(biometricControllerProvider).enabled;
    if (mounted && enabled && available) {
      setState(() => _biometricLockActive = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsControllerProvider);
    final auth = ref.watch(authControllerProvider);

    return MaterialApp(
      title: 'MMA Scorecard',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: _biometricLockActive && auth.mode == AuthAccessMode.authenticated
          ? _BiometricLockScreen(
              onUnlocked: () => setState(() => _biometricLockActive = false),
            )
          : const AuthGate(),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    return switch (auth.mode) {
      AuthAccessMode.loading => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      AuthAccessMode.signedOut => const LoginPage(),
      AuthAccessMode.guest ||
      AuthAccessMode.authenticated => const EventsHomePage(),
    };
  }
}

class _BiometricLockScreen extends ConsumerStatefulWidget {
  const _BiometricLockScreen({required this.onUnlocked});

  final VoidCallback onUnlocked;

  @override
  ConsumerState<_BiometricLockScreen> createState() =>
      _BiometricLockScreenState();
}

class _BiometricLockScreenState extends ConsumerState<_BiometricLockScreen> {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
  }

  Future<void> _unlock() async {
    if (_busy) return;
    setState(() => _busy = true);
    final loc = AppLocalizations.of(context)!;
    final ok = await ref
        .read(biometricControllerProvider.notifier)
        .authenticate(loc.biometricResumeReason);
    if (!mounted) return;
    if (ok) widget.onUnlocked();
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline_rounded, size: 56),
                  const SizedBox(height: 20),
                  Text(
                    loc.biometricLockTitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(loc.biometricLockBody, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _busy ? null : _unlock,
                    icon: const Icon(Icons.fingerprint),
                    label: Text(loc.biometricUnlockButton),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
