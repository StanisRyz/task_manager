import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/ui/swipe_back_wrapper.dart';
import '../../../l10n/app_localizations_ext.dart';
import '../state/locale_provider.dart';
import '../state/theme_mode_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final languageOptions = [
      _LocaleOption(
        locale: const Locale('ru'),
        label: l10n.languageRussian,
      ),
      _LocaleOption(
        locale: const Locale('en'),
        label: l10n.languageEnglish,
      ),
    ];

    return SwipeBackWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.settingsTitle),
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                l10n.settingsThemeTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            RadioGroup<ThemeMode>(
              groupValue: themeMode,
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                ref.read(themeModeProvider.notifier).state = value;
              },
              child: Column(
                children: [
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.light,
                    title: Text(l10n.settingsThemeLight),
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.dark,
                    title: Text(l10n.settingsThemeDark),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                l10n.settingsLanguage,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonFormField<Locale>(
                initialValue: locale,
                decoration: const InputDecoration(),
                items: languageOptions
                    .map(
                      (option) => DropdownMenuItem(
                        value: option.locale,
                        child: Text(option.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  ref.read(localeProvider.notifier).setLocale(value);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _LocaleOption {
  const _LocaleOption({required this.locale, required this.label});

  final Locale locale;
  final String label;
}
