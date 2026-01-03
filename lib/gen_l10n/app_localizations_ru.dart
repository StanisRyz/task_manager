// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Задачи';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsThemeTitle => 'Тема';

  @override
  String get settingsThemeLight => 'Светлая';

  @override
  String get settingsThemeDark => 'Тёмная';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageEnglish => 'Английский';

  @override
  String get filtersTitle => 'Фильтры';

  @override
  String get tagsTitle => 'Теги';

  @override
  String get allTags => 'Все теги';

  @override
  String get noTags => 'Теги пока не добавлены';

  @override
  String get apply => 'Применить';

  @override
  String get archiveTitle => 'Архив';

  @override
  String get backToTasks => 'К задачам';

  @override
  String get archiveEmpty => 'Архив пуст';

  @override
  String archivedOn(Object date) {
    return 'Архив: $date';
  }

  @override
  String get tasksTitle => 'Задачи';

  @override
  String get filterTooltip => 'Фильтры';

  @override
  String get sortTooltip => 'Сортировка';

  @override
  String get archiveTooltip => 'Архив';

  @override
  String get settingsTooltip => 'Настройки';

  @override
  String get tasksEmpty => 'Задач пока нет';

  @override
  String get sortAscending => 'По возрастанию срока';

  @override
  String get sortDescending => 'По убыванию срока';

  @override
  String remainingDays(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '# дня',
      many: '# дней',
      few: '# дня',
      one: '# день',
    );
    return 'осталось $_temp0';
  }

  @override
  String dueLabel(Object date, Object remaining) {
    return 'Срок: $date ($remaining)';
  }

  @override
  String get newTask => 'Новая задача';

  @override
  String get markCompletedTitle => 'Отметить выполненной';

  @override
  String get markCompletedMessage => 'Перенести задачу в архив?';

  @override
  String get deleteTaskMessage => 'Вы точно хотите удалить задачу?';

  @override
  String get deleteTaskTooltip => 'Удалить задачу';

  @override
  String get no => 'Нет';

  @override
  String get yes => 'Да';

  @override
  String get taskNewTitle => 'Новая задача';

  @override
  String get taskEditTitle => 'Редактирование';

  @override
  String get titleLabel => 'Название';

  @override
  String get titleRequired => 'Введите название задачи';

  @override
  String get shortDescriptionLabel => 'Краткое описание';

  @override
  String get descriptionLabel => 'Описание';

  @override
  String get statusLabel => 'Статус';

  @override
  String get statusPlanned => 'Запланировано';

  @override
  String get statusInProgress => 'В работе';

  @override
  String get statusDone => 'Выполнено';

  @override
  String get dueDateRequired => 'Укажите срок';

  @override
  String get dueDateInvalid => 'Срок должен быть не раньше завтрашнего дня';

  @override
  String get dueDateTitle => 'Срок';

  @override
  String get dueDateNotSet => 'Срок не установлен';

  @override
  String get clearDate => 'Очистить дату';

  @override
  String get pickDate => 'Выбрать дату';

  @override
  String get tagsLabel => 'Теги (через запятую)';

  @override
  String get attachmentsTitle => 'Вложения';

  @override
  String get addAttachmentFile => 'Добавить файл';

  @override
  String get noAttachments => 'Вложений нет';

  @override
  String get attachmentMissing => 'Файл вложения не найден';

  @override
  String get attachmentOpenFailed => 'Не удалось открыть вложение';

  @override
  String get save => 'Сохранить';
}
