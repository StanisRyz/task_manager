import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../features/tasks/data/task.dart';

Future<void> resetTasksOnStartup(Box<Task> box) async {
  try {
    await box.clear();
  } catch (error, stackTrace) {
    debugPrint('Не удалось очистить задачи при запуске: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}
