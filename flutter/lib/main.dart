import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mmascorecard/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/di/injection.dart';
import 'core/locale/app_locale_controller.dart';
import 'core/logger/app_logger.dart';
import 'core/security/app_biometric_unlock_controller.dart';
import 'core/theme/app_theme_controller.dart';
import 'router.dart';

// Dart's HttpClient (used under the hood by package:http and thus by the
// Sherdog scraper) has its own bundled trust store,
// independent of the Android/iOS OS trust store - installing a corporate
// proxy's root CA (e.g. Zscaler) at the OS level does nothing for it.
// Debug-only: trust it here too, so local dev works behind a
// TLS-intercepting proxy. Never runs in release builds.
Future<void> _trustDevProxyCertificateIfNeeded() async {
  if (!kDebugMode) return;
  try {
    final bytes = await rootBundle.load('assets/certs/zscaler_root_ca.pem');
    SecurityContext.defaultContext.setTrustedCertificatesBytes(
      bytes.buffer.asUint8List(),
    );
    AppLogger.info('trusted dev proxy certificate');
  } catch (e) {
    AppLogger.info('no dev proxy certificate to trust: $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _trustDevProxyCertificateIfNeeded();

  setupDi(prefs: await SharedPreferences.getInstance());
  AppLogger.info('DI setup complete');
  await bootstrap();

  runApp(const App());
}

/// Loads persisted preferences. Shared with widget tests so they boot the
/// app exactly like [main].
Future<void> bootstrap() async {
  await getIt<AppLocaleController>().load();
  await getIt<AppThemeController>().load();
  await getIt<AppBiometricUnlockController>().load();
}

class App extends StatefulWidget {
  const App({super.key});

  static Locale? _resolveDeviceLocale(
    Locale? deviceLocale,
    Iterable<Locale> supported,
  ) {
    if (deviceLocale == null) return supported.first;
    for (final loc in supported) {
      if (loc.languageCode == deviceLocale.languageCode) return loc;
    }
    return supported.first;
  }

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  late final GoRouter _router = buildRouter();

  /// True after [AppLifecycleState.paused]; cleared on resume.
  bool _shouldUnlockOnNextResume = false;

  /// Full-screen gate: no router navigation visible until cleared.
  /// There is no sign-in, so a cold start locks too when biometrics are on.
  late bool _biometricLockActive;

  @override
  void initState() {
    super.initState();
    final bio = getIt<AppBiometricUnlockController>();
    _biometricLockActive = bio.enabled && bio.authenticatorAvailable;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _router.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _shouldUnlockOnNextResume = true;
    } else if (state == AppLifecycleState.resumed &&
        _shouldUnlockOnNextResume) {
      _shouldUnlockOnNextResume = false;
      unawaited(_activateBiometricLockIfNeeded());
    }
  }

  Future<void> _activateBiometricLockIfNeeded() async {
    final bio = getIt<AppBiometricUnlockController>();
    await bio.refreshAuthenticatorAvailability();
    if (!bio.enabled || !bio.authenticatorAvailable) return;
    if (!mounted) return;
    setState(() => _biometricLockActive = true);
  }

  void _clearBiometricLock() {
    if (_biometricLockActive) {
      setState(() => _biometricLockActive = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocale = getIt<AppLocaleController>();
    final appTheme = getIt<AppThemeController>();
    return ListenableBuilder(
      listenable: Listenable.merge([appLocale, appTheme]),
      builder: (context, _) {
        final seed = Colors.deepPurple;
        return MaterialApp.router(
          title: 'MMA ScoreCard',
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: appLocale.materialAppLocale,
          localeResolutionCallback: App._resolveDeviceLocale,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: seed),
            useMaterial3: true,
            bottomSheetTheme: const BottomSheetThemeData(
              clipBehavior: Clip.antiAlias,
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: seed,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            bottomSheetTheme: const BottomSheetThemeData(
              clipBehavior: Clip.antiAlias,
            ),
          ),
          themeMode: appTheme.themeMode,
          routerConfig: _router,
          builder: (context, child) {
            if (_biometricLockActive) {
              return PopScope(
                canPop: false,
                child: _BiometricLockScreen(onUnlocked: _clearBiometricLock),
              );
            }
            return child ?? const SizedBox.shrink();
          },
        );
      },
    );
  }
}

class _BiometricLockScreen extends StatefulWidget {
  const _BiometricLockScreen({required this.onUnlocked});

  final VoidCallback onUnlocked;

  @override
  State<_BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends State<_BiometricLockScreen> {
  /// True while refresh + system biometric UI may be active — disables the Unlock button.
  bool _busy = false;

  /// Prevents overlapping [_attemptUnlock] runs (e.g. double-tap before first await).
  bool _unlockInFlight = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _attemptUnlock());
  }

  Future<void> _attemptUnlock() async {
    if (!mounted) return;
    if (_unlockInFlight) return;
    _unlockInFlight = true;
    setState(() => _busy = true);

    try {
      final bio = getIt<AppBiometricUnlockController>();
      await bio.refreshAuthenticatorAvailability();
      if (!mounted) return;

      if (!bio.enabled || !bio.authenticatorAvailable) {
        widget.onUnlocked();
        return;
      }

      final l10n = AppLocalizations.of(context);
      if (l10n == null) return;

      final ok = await bio.authenticate(l10n.settingsBiometricResumeReason);
      if (!mounted) return;

      if (ok) {
        widget.onUnlocked();
      }
    } finally {
      _unlockInFlight = false;
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: scheme.surface,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 56,
                  color: scheme.primary,
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.biometricLockTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.biometricLockBody,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: _busy ? null : _attemptUnlock,
                  icon: _busy
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: scheme.onPrimary,
                          ),
                        )
                      : const Icon(Icons.fingerprint_rounded),
                  label: Text(l10n.biometricLockUnlockButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
