import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'features/tasks/data/task.dart';
import 'features/tasks/data/tasks_repository.dart';
import 'features/tasks/state/tasks_controller.dart';
import 'startup/startup_reset.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TaskStatusAdapter());
  Hive.registerAdapter(TaskAdapter());
  final box = await Hive.openBox<Task>('tasks');
  await resetTasksOnStartup(box);

  runApp(
    ProviderScope(
      overrides: [
        tasksRepositoryProvider.overrideWithValue(TasksRepository(box)),
      ],
      child: const TaskManagerApp(),
    ),
  );
}
