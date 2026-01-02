import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  throw UnimplementedError('SettingsRepository provider was not overridden.');
});

final localeProvider = StateNotifierProvider<LocaleController, Locale>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return LocaleController(repository);
});

class LocaleController extends StateNotifier<Locale> {
  LocaleController(this._repository) : super(_initialLocale(_repository));

  final SettingsRepository _repository;

  static Locale _initialLocale(SettingsRepository repository) {
    final code = repository.readLocaleCode();
    if (code == 'en') {
      return const Locale('en');
    }
    return const Locale('ru');
  }

  Future<void> setLocale(Locale locale) async {
    if (state == locale) {
      return;
    }
    state = locale;
    await _repository.saveLocaleCode(locale.languageCode);
  }
}
