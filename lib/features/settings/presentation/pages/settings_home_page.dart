import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/max_width_body.dart';
import '../../../../features/auth/application/auth_controller.dart';
import '../../../../features/auth/application/biometric_controller.dart';
import '../../../../features/auth/domain/auth_service.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../application/app_settings_controller.dart';
import '../widgets/language_picker_dialog.dart';
import '../widgets/theme_picker_dialog.dart';
import 'about_page.dart';
import 'cached_records_page.dart';
import 'privacy_policy_page.dart';
import 'terms_page.dart';

class SettingsHomePage extends ConsumerStatefulWidget {
  const SettingsHomePage({super.key});

  @override
  ConsumerState<SettingsHomePage> createState() => _SettingsHomePageState();
}

class _SettingsHomePageState extends ConsumerState<SettingsHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(biometricControllerProvider.notifier).refreshAvailability();
    });
  }

  String _themeLabel(AppLocalizations loc, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return loc.themeLight;
      case ThemeMode.dark:
        return loc.themeDark;
      case ThemeMode.system:
        return loc.themeSystem;
    }
  }

  String _languageLabel(AppLocalizations loc, Locale? locale) {
    switch (locale?.languageCode) {
      case 'en':
        return loc.languageEnglish;
      case 'es':
        return loc.languageSpanish;
      default:
        return loc.languageSystemDefault;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final settings = ref.watch(appSettingsControllerProvider);
    final auth = ref.watch(authControllerProvider);
    final biometric = ref.watch(biometricControllerProvider);
    final loggedIn = auth.mode == AuthAccessMode.authenticated;
    final user = ref.read(authServiceProvider).currentUser;

    return Scaffold(
      appBar: AppBar(title: Text(loc.settingsTitle)),
      body: MaxWidthBody(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            if (loggedIn) ...[
              _SectionHeader(loc.settingsProfileSection),
              _SettingsTile(
                icon: Icons.person_outline,
                title: loc.changeEmail,
                subtitle: user?.email ?? '',
                onTap: () => _showChangeEmailDialog(context, user),
              ),
              _SettingsTile(
                icon: Icons.lock_outline,
                title: loc.changePassword,
                subtitle: loc.changePasswordSubtitle,
                onTap: () => _showChangePasswordDialog(context),
              ),
              _SectionDivider(),
              _SectionHeader(loc.settingsSecuritySection),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: Icon(
                  Icons.fingerprint,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                title: Text(loc.biometricUnlockTitle),
                subtitle: Text(
                  biometric.available
                      ? loc.biometricUnlockSubtitle
                      : loc.biometricUnavailable,
                ),
                value: biometric.enabled,
                onChanged: biometric.checking
                    ? null
                    : (enabled) => _setBiometricEnabled(enabled),
              ),
              _SectionDivider(),
            ],
            _SectionHeader(loc.settingsAppearanceSection),
            _SettingsTile(
              icon: Icons.brightness_6_outlined,
              title: loc.themeMenuTitle,
              subtitle: _themeLabel(loc, settings.themeMode),
              onTap: () => showThemePickerDialog(context),
            ),
            _SettingsTile(
              icon: Icons.language_outlined,
              title: loc.languageMenuTitle,
              subtitle: _languageLabel(loc, settings.locale),
              onTap: () => showLanguagePickerDialog(context),
            ),
            _SectionDivider(),
            _SectionHeader(loc.settingsDataSection),
            _SettingsTile(
              icon: Icons.storage_outlined,
              title: loc.cachedRecordsMenuTitle,
              subtitle: loc.cachedRecordsMenuSubtitle,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CachedRecordsPage()),
              ),
            ),
            _SectionDivider(),
            _SectionHeader(loc.settingsAboutSection),
            _SettingsTile(
              icon: Icons.info_outline,
              title: loc.aboutMenuTitle,
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const AboutPage())),
            ),
            _SettingsTile(
              icon: Icons.description_outlined,
              title: loc.termsMenuTitle,
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const TermsPage())),
            ),
            _SettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: loc.privacyMenuTitle,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
              ),
            ),
            const SizedBox(height: 16),
            if (auth.error != null) ...[
              SizedBox(
                width: double.infinity,
                child: Material(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      auth.error == 'unexpected'
                          ? loc.unexpectedError
                          : auth.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: loggedIn
                  ? FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                      ),
                      onPressed: auth.isBusy
                          ? null
                          : () => ref
                                .read(authControllerProvider.notifier)
                                .signOut(),
                      icon: const Icon(Icons.logout),
                      label: Text(loc.signOut),
                    )
                  : OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ref.read(authControllerProvider.notifier).showSignIn();
                      },
                      icon: const Icon(Icons.login),
                      label: Text(loc.signIn),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setBiometricEnabled(bool enabled) async {
    final loc = AppLocalizations.of(context)!;
    final controller = ref.read(biometricControllerProvider.notifier);
    if (!enabled) {
      await controller.disable();
      return;
    }
    final available = await controller.refreshAvailability();
    if (!available && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(loc.biometricUnavailable)));
      return;
    }
    await controller.enableWithConfirmation(loc.biometricEnableReason);
  }

  Future<void> _showChangeEmailDialog(
    BuildContext context,
    AuthUser? user,
  ) async {
    final loc = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: user?.email ?? '');
    final formKey = GlobalKey<FormState>();
    final nextEmail = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(loc.changeEmail),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: loc.newEmail),
            validator: (value) {
              final email = value?.trim() ?? '';
              if (email.isEmpty) return loc.fieldRequired;
              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                return loc.invalidEmail;
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(loc.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, controller.text.trim());
              }
            },
            child: Text(loc.save),
          ),
        ],
      ),
    );
    controller.dispose();
    if (nextEmail == null || nextEmail == user?.email || !mounted) return;
    await _updateUser(
      () => ref.read(authServiceProvider).updateEmail(nextEmail),
      loc.emailUpdateSuccess,
    );
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    final password = TextEditingController();
    final confirmation = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final nextPassword = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(loc.changePassword),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: password,
                obscureText: true,
                decoration: InputDecoration(labelText: loc.newPassword),
                validator: (value) =>
                    (value?.length ?? 0) < 6 ? loc.passwordTooShort : null,
              ),
              TextFormField(
                controller: confirmation,
                obscureText: true,
                decoration: InputDecoration(labelText: loc.confirmPassword),
                validator: (value) =>
                    value != password.text ? loc.passwordsDoNotMatch : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(loc.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, password.text);
              }
            },
            child: Text(loc.save),
          ),
        ],
      ),
    );
    password.dispose();
    confirmation.dispose();
    if (nextPassword == null || !mounted) return;
    await _updateUser(
      () => ref.read(authServiceProvider).updatePassword(nextPassword),
      loc.passwordUpdateSuccess,
    );
  }

  Future<void> _updateUser(
    Future<void> Function() update,
    String success,
  ) async {
    final loc = AppLocalizations.of(context)!;
    try {
      await update();
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(success)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().isEmpty ? loc.unexpectedError : error.toString(),
          ),
        ),
      );
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Divider(height: 1),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: scheme.onSurfaceVariant),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
