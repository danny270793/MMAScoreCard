import 'package:flutter/material.dart';

import '../../../../core/widgets/max_width_body.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../widgets/legal_section.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(loc.termsTitle)),
      body: MaxWidthBody(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LegalPageHeader(
                icon: Icons.article_outlined,
                title: loc.termsTitle,
                tagline: loc.termsTagline,
                backgroundColor: scheme.secondaryContainer,
                foregroundColor: scheme.onSecondaryContainer,
              ),
              const SizedBox(height: 28),
              PolicySection(
                title: loc.termsAcceptanceTitle,
                body: loc.termsAcceptanceBody,
              ),
              PolicySection(
                title: loc.termsAccountTitle,
                body: loc.termsAccountBody,
              ),
              PolicyCallout(
                title: loc.termsDisclaimerTitle,
                body: loc.termsDisclaimerBody,
                icon: Icons.info_outline,
              ),
              PolicySection(
                title: loc.termsLiabilityTitle,
                body: loc.termsLiabilityBody,
              ),
              PolicySection(
                title: loc.termsResponsibilitiesTitle,
                body: loc.termsResponsibilitiesBody,
              ),
              PolicySection(
                title: loc.termsNoticeTitle,
                body: loc.termsNoticeBody,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
