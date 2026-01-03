// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tasks';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsThemeTitle => 'Theme';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageRussian => 'Russian';

  @override
  String get languageEnglish => 'English';

  @override
  String get filtersTitle => 'Filters';

  @override
  String get tagsTitle => 'Tags';

  @override
  String get allTags => 'All tags';

  @override
  String get noTags => 'No tags added yet';

  @override
  String get apply => 'Apply';

  @override
  String get archiveTitle => 'Archive';

  @override
  String get backToTasks => 'Back to tasks';

  @override
  String get archiveEmpty => 'Archive is empty';

  @override
  String archivedOn(Object date) {
    return 'Archived: $date';
  }

  @override
  String get tasksTitle => 'Tasks';

  @override
  String get searchPlaceholder => 'Search…';

  @override
  String get filterTooltip => 'Filters';

  @override
  String get sortTooltip => 'Sort';

  @override
  String get archiveTooltip => 'Archive';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get tasksEmpty => 'No tasks yet';

  @override
  String get sortAscending => 'Ascending by due date';

  @override
  String get sortDescending => 'Descending by due date';

  @override
  String remainingDays(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '# days left',
      one: '# day left',
    );
    return '$_temp0';
  }

  @override
  String dueLabel(Object date, Object remaining) {
    return 'Due: $date ($remaining)';
  }

  @override
  String get newTask => 'New task';

  @override
  String get markCompletedTitle => 'Mark as done';

  @override
  String get markCompletedMessage => 'Move the task to the archive?';

  @override
  String get deleteTaskMessage => 'Are you sure you want to delete the task?';

  @override
  String get deleteTaskTooltip => 'Delete task';

  @override
  String get no => 'No';

  @override
  String get yes => 'Yes';

  @override
  String get taskNewTitle => 'New task';

  @override
  String get taskEditTitle => 'Edit task';

  @override
  String get titleLabel => 'Title';

  @override
  String get titleRequired => 'Enter a task title';

  @override
  String get shortDescriptionLabel => 'Short description';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get statusLabel => 'Status';

  @override
  String get statusPlanned => 'Planned';

  @override
  String get statusInProgress => 'In progress';

  @override
  String get statusDone => 'Done';

  @override
  String get dueDateRequired => 'Select a due date';

  @override
  String get dueDateInvalid => 'Due date must be no earlier than tomorrow';

  @override
  String get dueDateTitle => 'Due date';

  @override
  String get dueDateNotSet => 'No due date';

  @override
  String get clearDate => 'Clear date';

  @override
  String get pickDate => 'Pick date';

  @override
  String get tagsLabel => 'Tags (comma-separated)';

  @override
  String get attachmentsTitle => 'Attachments';

  @override
  String get addAttachmentFile => 'Add file';

  @override
  String get noAttachments => 'No attachments';

  @override
  String get attachmentMissing => 'Attachment file is missing';

  @override
  String get attachmentOpenFailed => 'Could not open the attachment';

  @override
  String get save => 'Save';

  @override
  String get taskColorTitle => 'Task color';

  @override
  String get confirm => 'Confirm';
}
