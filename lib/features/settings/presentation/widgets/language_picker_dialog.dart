import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/bottom_sheet_pinned_title.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../application/app_settings_controller.dart';

Future<void> showLanguagePickerDialog(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _LanguagePickerSheet(),
  );
}

class _LanguagePickerSheet extends ConsumerWidget {
  const _LanguagePickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(appSettingsControllerProvider).locale;
    final selected = currentLocale?.languageCode ?? 'system';
    final options = <String, String>{
      'system': loc.languageSystemDefault,
      'en': loc.languageEnglish,
      'es': loc.languageSpanish,
    };
    final locales = <String, Locale?>{
      'system': null,
      'en': const Locale('en'),
      'es': const Locale('es'),
    };

    return BottomSheetPinnedTitleScrollView(
      padding: EdgeInsets.zero,
      title: loc.chooseLanguageTitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final option in options.entries)
            ListTile(
              title: Text(option.value),
              trailing: selected == option.key
                  ? Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              onTap: () {
                ref
                    .read(appSettingsControllerProvider.notifier)
                    .setLocale(locales[option.key]);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }
}
