import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mmascorecard/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/di/injection.dart';
import '../core/locale/app_locale_controller.dart';
import '../core/security/app_biometric_unlock_controller.dart';
import '../core/theme/app_theme_controller.dart';
import '../widgets/bottom_sheet_pinned_title.dart';
import '../widgets/max_width_body.dart';

const _playStoreUrl =
    'https://play.google.com/store/apps/details?id=io.github.danny270793.mmascorecard';

String _languageOptionLabel(AppLocalizations l10n, AppLanguagePreference p) =>
    switch (p) {
      AppLanguagePreference.system => l10n.settingsLanguageSystem,
      AppLanguagePreference.en => l10n.settingsLanguageEnglish,
      AppLanguagePreference.es => l10n.settingsLanguageSpanish,
    };

String _themeOptionLabel(AppLocalizations l10n, AppThemePreference p) =>
    switch (p) {
      AppThemePreference.system => l10n.settingsThemeSystem,
      AppThemePreference.light => l10n.settingsThemeLight,
      AppThemePreference.dark => l10n.settingsThemeDark,
    };

Future<void> _showLanguagePickerSheet(
  BuildContext context,
  AppLocalizations l10n,
  AppLocaleController ctrl,
) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: false,
    isScrollControlled: true,
    builder: (sheetContext) => BottomSheetPinnedTitleScrollView(
      padding: EdgeInsets.zero,
      title: l10n.settingsLanguage,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final option in AppLanguagePreference.values)
            ListTile(
              title: Text(_languageOptionLabel(l10n, option)),
              trailing: ctrl.preference == option
                  ? Icon(
                      Icons.check,
                      color: Theme.of(sheetContext).colorScheme.primary,
                    )
                  : null,
              onTap: () async {
                await ctrl.setPreference(option);
                if (sheetContext.mounted) Navigator.of(sheetContext).pop();
              },
            ),
        ],
      ),
    ),
  );
}

Future<void> _showThemePickerSheet(
  BuildContext context,
  AppLocalizations l10n,
  AppThemeController ctrl,
) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: false,
    isScrollControlled: true,
    builder: (sheetContext) => BottomSheetPinnedTitleScrollView(
      padding: EdgeInsets.zero,
      title: l10n.settingsTheme,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final option in AppThemePreference.values)
            ListTile(
              title: Text(_themeOptionLabel(l10n, option)),
              trailing: ctrl.preference == option
                  ? Icon(
                      Icons.check,
                      color: Theme.of(sheetContext).colorScheme.primary,
                    )
                  : null,
              onTap: () async {
                await ctrl.setPreference(option);
                if (sheetContext.mounted) Navigator.of(sheetContext).pop();
              },
            ),
        ],
      ),
    ),
  );
}

Future<void> _setBiometricUnlockEnabled(
  BuildContext context,
  AppLocalizations l10n,
  AppBiometricUnlockController ctrl,
  bool enabled,
) async {
  if (!enabled) {
    await ctrl.setEnabled(false);
    return;
  }
  await ctrl.refreshAuthenticatorAvailability();
  if (!ctrl.authenticatorAvailable) {
    if (context.mounted) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(l10n.settingsBiometricUnavailable)),
      );
    }
    return;
  }
  final ok = await ctrl.authenticate(l10n.settingsBiometricAuthReason);
  if (!context.mounted) {
    return;
  }
  if (ok) {
    await ctrl.setEnabled(true);
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        getIt<AppBiometricUnlockController>()
            .refreshAuthenticatorAvailability(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: SafeArea(
        child: MaxWidthBody(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
            children: [
              _SectionHeader(l10n.settingsSecuritySection),
              ListenableBuilder(
                listenable: getIt<AppBiometricUnlockController>(),
                builder: (context, _) {
                  final bio = getIt<AppBiometricUnlockController>();
                  return SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    secondary: Icon(
                      Icons.fingerprint_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    title: Text(l10n.settingsBiometricUnlockTitle),
                    subtitle: Text(
                      bio.authenticatorAvailable
                          ? l10n.settingsBiometricUnlockSubtitle
                          : l10n.settingsBiometricUnavailable,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                    value: bio.enabled,
                    onChanged: bio.authenticatorAvailable
                        ? (v) =>
                              _setBiometricUnlockEnabled(context, l10n, bio, v)
                        : null,
                  );
                },
              ),
              const _SectionDivider(),
              _SectionHeader(l10n.settingsAppearance),
              ListenableBuilder(
                listenable: getIt<AppLocaleController>(),
                builder: (context, _) {
                  final ctrl = getIt<AppLocaleController>();
                  return _NavigationTile(
                    icon: Icons.language_outlined,
                    title: l10n.settingsLanguage,
                    subtitle: _languageOptionLabel(l10n, ctrl.preference),
                    onTap: () => _showLanguagePickerSheet(context, l10n, ctrl),
                  );
                },
              ),
              ListenableBuilder(
                listenable: getIt<AppThemeController>(),
                builder: (context, _) {
                  final ctrl = getIt<AppThemeController>();
                  return _NavigationTile(
                    icon: Icons.palette_outlined,
                    title: l10n.settingsTheme,
                    subtitle: _themeOptionLabel(l10n, ctrl.preference),
                    onTap: () => _showThemePickerSheet(context, l10n, ctrl),
                  );
                },
              ),
              const _SectionDivider(),
              _SectionHeader(l10n.settingsDataSection),
              _NavigationTile(
                icon: Icons.storage_outlined,
                title: l10n.settingsOfflineCache,
                subtitle: l10n.settingsOfflineCacheSubtitle,
                onTap: () => context.push('/settings/cache'),
              ),
              const _SectionDivider(),
              _SectionHeader(l10n.settingsAboutSection),
              _NavigationTile(
                icon: Icons.info_outline_rounded,
                title: l10n.settingsAboutApp,
                onTap: () => context.push('/settings/about'),
              ),
              _NavigationTile(
                icon: Icons.star_outline_rounded,
                title: l10n.settingsRateApp,
                trailingIcon: Icons.open_in_new_rounded,
                onTap: () => launchUrl(
                  Uri.parse(_playStoreUrl),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              _NavigationTile(
                icon: Icons.privacy_tip_outlined,
                title: l10n.settingsPrivacyPolicy,
                onTap: () => context.push('/settings/privacy'),
              ),
              _NavigationTile(
                icon: Icons.description_outlined,
                title: l10n.settingsTermsOfUse,
                onTap: () => context.push('/settings/terms'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 16),
    child: Divider(height: 1),
  );
}

class _NavigationTile extends StatelessWidget {
  const _NavigationTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailingIcon = Icons.chevron_right,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final IconData trailingIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: Icon(trailingIcon),
      onTap: onTap,
    );
  }
}
