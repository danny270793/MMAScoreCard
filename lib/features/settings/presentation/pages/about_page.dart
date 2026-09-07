import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app_info/package_info_provider.dart';
import '../../../../core/widgets/max_width_body.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../widgets/developer_info_section.dart';
import '../widgets/legal_section.dart';

class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final packageInfo = ref.watch(packageInfoProvider);

    return Scaffold(
      appBar: AppBar(title: Text(loc.aboutTitle)),
      body: MaxWidthBody(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LegalPageHeader(
                icon: Icons.sports_mma,
                title: loc.appTitle,
                tagline: loc.appTagline,
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.onPrimaryContainer,
              ),
              const SizedBox(height: 8),
              Center(
                child: packageInfo.when(
                  data: (info) => Text(
                    loc.versionLabel(info.version),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                loc.aboutFeaturesHeading,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              AboutBullet(
                icon: Icons.event_outlined,
                text: loc.aboutBulletEvents,
              ),
              AboutBullet(
                icon: Icons.sports_kabaddi_outlined,
                text: loc.aboutBulletFightCards,
              ),
              AboutBullet(
                icon: Icons.badge_outlined,
                text: loc.aboutBulletFighters,
              ),
              const SizedBox(height: 28),
              PolicySection(
                title: loc.aboutDataHeading,
                body: loc.aboutDataBody,
              ),
              const SizedBox(height: 8),
              DeveloperInfoSection(
                heading: loc.contactLabel,
                githubLabel: loc.developerGithub,
                websiteLabel: loc.developerWebsite,
                youtubeLabel: loc.developerYoutube,
                linkedinLabel: loc.developerLinkedin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
