import 'package:flutter/material.dart';

import '../../../../core/widgets/max_width_body.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../widgets/legal_section.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(loc.privacyTitle)),
      body: MaxWidthBody(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LegalPageHeader(
                icon: Icons.privacy_tip_outlined,
                title: loc.privacyTitle,
                tagline: loc.privacyTagline,
                backgroundColor: scheme.tertiaryContainer,
                foregroundColor: scheme.onTertiaryContainer,
              ),
              const SizedBox(height: 28),
              PolicySection(
                title: loc.privacyDataTitle,
                body: loc.privacyDataBody,
              ),
              PolicySection(
                title: loc.privacyInfraTitle,
                body: loc.privacyInfraBody,
              ),
              PolicyCallout(
                title: loc.privacySharingTitle,
                body: loc.privacySharingBody,
              ),
              PolicySection(
                title: loc.privacyNoticeTitle,
                body: loc.privacyNoticeBody,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
