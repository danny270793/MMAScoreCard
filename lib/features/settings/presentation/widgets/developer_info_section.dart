import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Contact block for About screens: name, email, photo, and public profiles.
class DeveloperInfoSection extends StatelessWidget {
  const DeveloperInfoSection({
    super.key,
    required this.heading,
    required this.githubLabel,
    required this.websiteLabel,
    required this.youtubeLabel,
    required this.linkedinLabel,
  });

  final String heading;
  final String githubLabel;
  final String websiteLabel;
  final String youtubeLabel;
  final String linkedinLabel;

  static const name = 'Danny Vaca';
  static const email = 'danny270793@icloud.com';
  static const photoUrl = 'https://github.com/danny270793.png?size=200';
  static const githubUrl = 'https://github.com/danny270793';
  static const websiteUrl = 'https://danny270793.github.io/';
  static const youtubeUrl =
      'https://www.youtube.com/channel/UC5MAQWU2s2VESTXaUo-ysgg';
  static const linkedinUrl = 'https://www.linkedin.com/in/danny270793/';

  Future<void> _open(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final links = <(IconData, String, String)>[
      (Icons.code, githubLabel, githubUrl),
      (Icons.language, websiteLabel, websiteUrl),
      (Icons.play_circle_outline, youtubeLabel, youtubeUrl),
      (Icons.work_outline, linkedinLabel, linkedinUrl),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          heading,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: scheme.surfaceContainerHighest,
              backgroundImage: const NetworkImage(photoUrl),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  InkWell(
                    onTap: () => _open('mailto:$email'),
                    child: Text(
                      email,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final link in links)
          InkWell(
            onTap: () => _open(link.$3),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Icon(link.$1, color: scheme.primary),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(link.$2, style: theme.textTheme.bodyLarge),
                        Text(
                          link.$3,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
