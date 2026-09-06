import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../application/app_settings_controller.dart';

Future<void> showThemePickerDialog(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => const _ThemePickerDialog(),
  );
}

class _ThemePickerDialog extends ConsumerWidget {
  const _ThemePickerDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final currentMode = ref.watch(appSettingsControllerProvider).themeMode;

    return SafeArea(
      top: false,
      child: RadioGroup<ThemeMode>(
        groupValue: currentMode,
        onChanged: (value) {
          if (value == null) return;
          ref.read(appSettingsControllerProvider.notifier).setThemeMode(value);
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
                    loc.chooseThemeTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              RadioListTile<ThemeMode>(
                title: Text(loc.themeSystem),
                value: ThemeMode.system,
              ),
              RadioListTile<ThemeMode>(
                title: Text(loc.themeLight),
                value: ThemeMode.light,
              ),
              RadioListTile<ThemeMode>(
                title: Text(loc.themeDark),
                value: ThemeMode.dark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
