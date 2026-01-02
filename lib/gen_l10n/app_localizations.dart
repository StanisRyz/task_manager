import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'Задачи'**
  String get appTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settingsTitle;

  /// No description provided for @settingsThemeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Тема'**
  String get settingsThemeTitle;

  /// No description provided for @settingsThemeLight.
  ///
  /// In ru, this message translates to:
  /// **'Светлая'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In ru, this message translates to:
  /// **'Тёмная'**
  String get settingsThemeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get settingsLanguage;

  /// No description provided for @languageRussian.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get languageRussian;

  /// No description provided for @languageEnglish.
  ///
  /// In ru, this message translates to:
  /// **'Английский'**
  String get languageEnglish;

  /// No description provided for @filtersTitle.
  ///
  /// In ru, this message translates to:
  /// **'Фильтры'**
  String get filtersTitle;

  /// No description provided for @tagsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Теги'**
  String get tagsTitle;

  /// No description provided for @allTags.
  ///
  /// In ru, this message translates to:
  /// **'Все теги'**
  String get allTags;

  /// No description provided for @noTags.
  ///
  /// In ru, this message translates to:
  /// **'Теги пока не добавлены'**
  String get noTags;

  /// No description provided for @apply.
  ///
  /// In ru, this message translates to:
  /// **'Применить'**
  String get apply;

  /// No description provided for @archiveTitle.
  ///
  /// In ru, this message translates to:
  /// **'Архив'**
  String get archiveTitle;

  /// No description provided for @backToTasks.
  ///
  /// In ru, this message translates to:
  /// **'К задачам'**
  String get backToTasks;

  /// No description provided for @archiveEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Архив пуст'**
  String get archiveEmpty;

  /// No description provided for @archivedOn.
  ///
  /// In ru, this message translates to:
  /// **'Архив: {date}'**
  String archivedOn(Object date);

  /// No description provided for @tasksTitle.
  ///
  /// In ru, this message translates to:
  /// **'Задачи'**
  String get tasksTitle;

  /// No description provided for @filterTooltip.
  ///
  /// In ru, this message translates to:
  /// **'Фильтры'**
  String get filterTooltip;

  /// No description provided for @sortTooltip.
  ///
  /// In ru, this message translates to:
  /// **'Сортировка'**
  String get sortTooltip;

  /// No description provided for @archiveTooltip.
  ///
  /// In ru, this message translates to:
  /// **'Архив'**
  String get archiveTooltip;

  /// No description provided for @settingsTooltip.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settingsTooltip;

  /// No description provided for @tasksEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Задач пока нет'**
  String get tasksEmpty;

  /// No description provided for @sortAscending.
  ///
  /// In ru, this message translates to:
  /// **'По возрастанию срока'**
  String get sortAscending;

  /// No description provided for @sortDescending.
  ///
  /// In ru, this message translates to:
  /// **'По убыванию срока'**
  String get sortDescending;

  /// No description provided for @remainingDays.
  ///
  /// In ru, this message translates to:
  /// **'осталось {days, plural, one{# день} few{# дня} many{# дней} other{# дня}}'**
  String remainingDays(num days);

  /// No description provided for @dueLabel.
  ///
  /// In ru, this message translates to:
  /// **'Срок: {date} ({remaining})'**
  String dueLabel(Object date, Object remaining);

  /// No description provided for @newTask.
  ///
  /// In ru, this message translates to:
  /// **'Новая задача'**
  String get newTask;

  /// No description provided for @markCompletedTitle.
  ///
  /// In ru, this message translates to:
  /// **'Отметить выполненной'**
  String get markCompletedTitle;

  /// No description provided for @markCompletedMessage.
  ///
  /// In ru, this message translates to:
  /// **'Перенести задачу в архив?'**
  String get markCompletedMessage;

  /// No description provided for @deleteTaskMessage.
  ///
  /// In ru, this message translates to:
  /// **'Вы точно хотите удалить задачу?'**
  String get deleteTaskMessage;

  /// No description provided for @deleteTaskTooltip.
  ///
  /// In ru, this message translates to:
  /// **'Удалить задачу'**
  String get deleteTaskTooltip;

  /// No description provided for @no.
  ///
  /// In ru, this message translates to:
  /// **'Нет'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In ru, this message translates to:
  /// **'Да'**
  String get yes;

  /// No description provided for @taskNewTitle.
  ///
  /// In ru, this message translates to:
  /// **'Новая задача'**
  String get taskNewTitle;

  /// No description provided for @taskEditTitle.
  ///
  /// In ru, this message translates to:
  /// **'Редактирование'**
  String get taskEditTitle;

  /// No description provided for @titleLabel.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get titleLabel;

  /// No description provided for @titleRequired.
  ///
  /// In ru, this message translates to:
  /// **'Введите название задачи'**
  String get titleRequired;

  /// No description provided for @shortDescriptionLabel.
  ///
  /// In ru, this message translates to:
  /// **'Краткое описание'**
  String get shortDescriptionLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In ru, this message translates to:
  /// **'Описание'**
  String get descriptionLabel;

  /// No description provided for @descriptionRequired.
  ///
  /// In ru, this message translates to:
  /// **'Введите описание задачи'**
  String get descriptionRequired;

  /// No description provided for @descriptionOrShortRequired.
  ///
  /// In ru, this message translates to:
  /// **'Введите краткое описание или описание'**
  String get descriptionOrShortRequired;

  /// No description provided for @statusLabel.
  ///
  /// In ru, this message translates to:
  /// **'Статус'**
  String get statusLabel;

  /// No description provided for @statusPlanned.
  ///
  /// In ru, this message translates to:
  /// **'Запланировано'**
  String get statusPlanned;

  /// No description provided for @statusInProgress.
  ///
  /// In ru, this message translates to:
  /// **'В работе'**
  String get statusInProgress;

  /// No description provided for @statusDone.
  ///
  /// In ru, this message translates to:
  /// **'Выполнено'**
  String get statusDone;

  /// No description provided for @dueDateRequired.
  ///
  /// In ru, this message translates to:
  /// **'Укажите срок'**
  String get dueDateRequired;

  /// No description provided for @dueDateInvalid.
  ///
  /// In ru, this message translates to:
  /// **'Срок должен быть не раньше завтрашнего дня'**
  String get dueDateInvalid;

  /// No description provided for @dueDateTitle.
  ///
  /// In ru, this message translates to:
  /// **'Срок'**
  String get dueDateTitle;

  /// No description provided for @dueDateNotSet.
  ///
  /// In ru, this message translates to:
  /// **'Срок не установлен'**
  String get dueDateNotSet;

  /// No description provided for @clearDate.
  ///
  /// In ru, this message translates to:
  /// **'Очистить дату'**
  String get clearDate;

  /// No description provided for @pickDate.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать дату'**
  String get pickDate;

  /// No description provided for @tagsLabel.
  ///
  /// In ru, this message translates to:
  /// **'Теги (через запятую)'**
  String get tagsLabel;

  /// No description provided for @attachmentsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Вложения'**
  String get attachmentsTitle;

  /// No description provided for @attachmentTypeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Тип вложения'**
  String get attachmentTypeLabel;

  /// No description provided for @attachmentTypePhoto.
  ///
  /// In ru, this message translates to:
  /// **'Фото'**
  String get attachmentTypePhoto;

  /// No description provided for @attachmentTypeVideo.
  ///
  /// In ru, this message translates to:
  /// **'Видео'**
  String get attachmentTypeVideo;

  /// No description provided for @attachmentTypeDocument.
  ///
  /// In ru, this message translates to:
  /// **'Документ'**
  String get attachmentTypeDocument;

  /// No description provided for @addAttachmentFile.
  ///
  /// In ru, this message translates to:
  /// **'Добавить файл'**
  String get addAttachmentFile;

  /// No description provided for @noAttachments.
  ///
  /// In ru, this message translates to:
  /// **'Вложений нет'**
  String get noAttachments;

  /// No description provided for @attachmentMissing.
  ///
  /// In ru, this message translates to:
  /// **'Файл вложения не найден'**
  String get attachmentMissing;

  /// No description provided for @attachmentOpenFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось открыть вложение'**
  String get attachmentOpenFailed;

  /// No description provided for @save.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get save;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
