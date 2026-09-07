import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/bottom_sheet_pinned_title.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../application/app_settings_controller.dart';

Future<void> showThemePickerDialog(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _ThemePickerSheet(),
  );
}

class _ThemePickerSheet extends ConsumerWidget {
  const _ThemePickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final currentMode = ref.watch(appSettingsControllerProvider).themeMode;
    final options = <ThemeMode, String>{
      ThemeMode.system: loc.themeSystem,
      ThemeMode.light: loc.themeLight,
      ThemeMode.dark: loc.themeDark,
    };

    return BottomSheetPinnedTitleScrollView(
      padding: EdgeInsets.zero,
      title: loc.chooseThemeTitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final option in options.entries)
            ListTile(
              title: Text(option.value),
              trailing: currentMode == option.key
                  ? Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              onTap: () {
                ref
                    .read(appSettingsControllerProvider.notifier)
                    .setThemeMode(option.key);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }
}
