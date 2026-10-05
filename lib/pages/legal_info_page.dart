import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:mmascorecard/l10n/app_localizations.dart';
import 'package:mmascorecard/widgets/developer_info_section.dart';

import '../widgets/max_width_body.dart';

/// Static information screens linked from Settings → About.
enum LegalInfoKind { about, privacy, terms }

String _legalInfoAppBarTitle(AppLocalizations l10n, LegalInfoKind kind) =>
    switch (kind) {
      LegalInfoKind.about => l10n.settingsAboutApp,
      LegalInfoKind.privacy => l10n.settingsPrivacyPolicy,
      LegalInfoKind.terms => l10n.settingsTermsOfUse,
    };

class LegalInfoPage extends StatefulWidget {
  const LegalInfoPage({super.key, required this.kind});

  final LegalInfoKind kind;

  @override
  State<LegalInfoPage> createState() => _LegalInfoPageState();
}

class _LegalInfoPageState extends State<LegalInfoPage> {
  static const double _appBarTitleScrollThreshold = 32;

  late final ScrollController _scrollController;
  bool _showAppBarTitle = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final next = _scrollController.offset > _appBarTitleScrollThreshold;
    if (next != _showAppBarTitle) {
      setState(() => _showAppBarTitle = next);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = _legalInfoAppBarTitle(l10n, widget.kind);

    return Scaffold(
      appBar: AppBar(title: _showAppBarTitle ? Text(title) : null),
      body: SafeArea(
        child: MaxWidthBody(
          child: switch (widget.kind) {
            LegalInfoKind.about => _AboutBody(
              l10n: l10n,
              scrollController: _scrollController,
            ),
            LegalInfoKind.privacy => _PrivacyBody(
              l10n: l10n,
              scrollController: _scrollController,
            ),
            LegalInfoKind.terms => _TermsBody(
              l10n: l10n,
              scrollController: _scrollController,
            ),
          },
        ),
      ),
    );
  }
}

class _AboutBody extends StatelessWidget {
  const _AboutBody({required this.l10n, required this.scrollController});

  final AppLocalizations l10n;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/launcher-ios.png',
                width: 88,
                height: 88,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.appTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.settingsAboutTagline,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 20),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                );
              }
              final info = snapshot.data!;
              final label = l10n.settingsAboutVersionLabel;
              final v = info.version;
              final b = info.buildNumber;
              final line = b.isNotEmpty ? '$label $v ($b)' : '$label $v';
              return Text(
                line,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              );
            },
          ),
          const SizedBox(height: 28),
          Text(
            l10n.settingsAboutFeaturesHeading,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          _AboutBullet(
            icon: Icons.event_outlined,
            text: l10n.settingsAboutBulletEvents,
          ),
          _AboutBullet(
            icon: Icons.sports_kabaddi_outlined,
            text: l10n.settingsAboutBulletFightCards,
          ),
          _AboutBullet(
            icon: Icons.badge_outlined,
            text: l10n.settingsAboutBulletFighters,
          ),
          const SizedBox(height: 28),
          Text(
            l10n.settingsAboutDataHeading,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          SelectableText(
            l10n.settingsAboutDataBody,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.45,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 28),
          DeveloperInfoSection(
            heading: l10n.settingsAboutDeveloperHeading,
            githubLabel: l10n.settingsAboutDeveloperGithub,
            websiteLabel: l10n.settingsAboutDeveloperWebsite,
            youtubeLabel: l10n.settingsAboutDeveloperYoutube,
            linkedinLabel: l10n.settingsAboutDeveloperLinkedin,
          ),
        ],
      ),
    );
  }
}

class _PrivacyBody extends StatelessWidget {
  const _PrivacyBody({required this.l10n, required this.scrollController});

  final AppLocalizations l10n;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: CircleAvatar(
              radius: 36,
              backgroundColor: scheme.tertiaryContainer,
              child: Icon(
                Icons.privacy_tip_outlined,
                size: 36,
                color: scheme.onTertiaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.settingsPrivacyPolicy,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.settingsPrivacyTagline,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 28),
          _PolicySection(
            title: l10n.settingsPrivacyDataTitle,
            body: l10n.settingsPrivacyDataBody,
          ),
          _PolicySection(
            title: l10n.settingsPrivacyInfraTitle,
            body: l10n.settingsPrivacyInfraBody,
          ),
          _PolicyCallout(
            title: l10n.settingsPrivacySharingTitle,
            body: l10n.settingsPrivacySharingBody,
          ),
          _PolicySection(
            title: l10n.settingsPrivacyNoticeTitle,
            body: l10n.settingsPrivacyNoticeBody,
          ),
        ],
      ),
    );
  }
}

class _TermsBody extends StatelessWidget {
  const _TermsBody({required this.l10n, required this.scrollController});

  final AppLocalizations l10n;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: CircleAvatar(
              radius: 36,
              backgroundColor: scheme.secondaryContainer,
              child: Icon(
                Icons.article_outlined,
                size: 36,
                color: scheme.onSecondaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.settingsTermsOfUse,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.settingsTermsTagline,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 28),
          _PolicySection(
            title: l10n.settingsTermsAcceptanceTitle,
            body: l10n.settingsTermsAcceptanceBody,
          ),
          _PolicySection(
            title: l10n.settingsTermsAccountTitle,
            body: l10n.settingsTermsAccountBody,
          ),
          _PolicyCallout(
            title: l10n.settingsTermsDisclaimerTitle,
            body: l10n.settingsTermsDisclaimerBody,
            icon: Icons.info_outline,
          ),
          _PolicySection(
            title: l10n.settingsTermsLiabilityTitle,
            body: l10n.settingsTermsLiabilityBody,
          ),
          _PolicySection(
            title: l10n.settingsTermsResponsibilitiesTitle,
            body: l10n.settingsTermsResponsibilitiesBody,
          ),
          _PolicySection(
            title: l10n.settingsTermsNoticeTitle,
            body: l10n.settingsTermsNoticeBody,
          ),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            body,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.45,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicyCallout extends StatelessWidget {
  const _PolicyCallout({
    required this.title,
    required this.body,
    this.icon = Icons.shield_outlined,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 24, color: scheme.primary),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SelectableText(
                      body,
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutBullet extends StatelessWidget {
  const _AboutBullet({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: scheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: SelectableText(
              text,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
