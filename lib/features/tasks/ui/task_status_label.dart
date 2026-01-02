import 'package:task_manager/gen_l10n/app_localizations.dart';

import '../data/task.dart';

extension TaskStatusLabel on TaskStatus {
  String label(AppLocalizations l10n) {
    switch (this) {
      case TaskStatus.planned:
        return l10n.statusPlanned;
      case TaskStatus.inProgress:
        return l10n.statusInProgress;
      case TaskStatus.done:
        return l10n.statusDone;
    }
  }
}
