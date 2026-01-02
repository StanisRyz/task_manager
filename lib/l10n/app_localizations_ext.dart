import 'package:flutter/widgets.dart';
import 'package:task_manager/gen_l10n/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension AppLocalizationsThemeLabels on AppLocalizations {
  String get settingsThemeTitle {
    switch (localeName) {
      case 'ru':
        return 'Тема';
      default:
        return 'Theme';
    }
  }

  String get settingsThemeLight {
    switch (localeName) {
      case 'ru':
        return 'Светлая';
      default:
        return 'Light';
    }
  }
}
