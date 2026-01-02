import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations_ext.dart';
import '../state/locale_provider.dart';
import '../state/theme_mode_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(l10n.settingsThemeDark),
            value: isDark,
            onChanged: (value) {
              ref.read(themeModeProvider.notifier).state =
                  value ? ThemeMode.dark : ThemeMode.light;
            },
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.settingsLanguage,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          RadioGroup<Locale>(
            groupValue: locale,
            onChanged: (value) {
              ref.read(localeProvider.notifier).setLocale(value);
            },
            child: Column(
              children: [
                RadioListTile<Locale>(
                  value: const Locale('ru'),
                  title: Text(l10n.languageRussian),
                ),
                RadioListTile<Locale>(
                  value: const Locale('en'),
                  title: Text(l10n.languageEnglish),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
