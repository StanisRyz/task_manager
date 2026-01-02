import 'package:hive/hive.dart';

class SettingsRepository {
  SettingsRepository(this._box);

  final Box<String> _box;

  static const _localeKey = 'locale_code';

  String? readLocaleCode() => _box.get(_localeKey);

  Future<void> saveLocaleCode(String code) async {
    await _box.put(_localeKey, code);
  }
}
