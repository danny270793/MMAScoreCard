import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../application/app_settings_controller.dart';

Future<void> showLanguagePickerDialog(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => const _LanguagePickerDialog(),
  );
}

class _LanguagePickerDialog extends ConsumerWidget {
  const _LanguagePickerDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(appSettingsControllerProvider).locale;
    final locales = <String, Locale?>{
      'system': null,
      'en': const Locale('en'),
      'es': const Locale('es'),
    };

    return SafeArea(
      top: false,
      child: RadioGroup<String>(
        groupValue: currentLocale?.languageCode ?? 'system',
        onChanged: (code) {
          if (code == null) return;
          ref
              .read(appSettingsControllerProvider.notifier)
              .setLocale(locales[code]);
          Navigator.of(context).pop();
        },
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    loc.chooseLanguageTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              RadioListTile<String>(
                title: Text(loc.languageSystemDefault),
                value: 'system',
              ),
              RadioListTile<String>(
                title: Text(loc.languageEnglish),
                value: 'en',
              ),
              RadioListTile<String>(
                title: Text(loc.languageSpanish),
                value: 'es',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
