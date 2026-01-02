import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:task_manager/app.dart';
import 'package:task_manager/features/tasks/data/task.dart';
import 'package:task_manager/features/tasks/data/tasks_repository.dart';
import 'package:task_manager/features/tasks/state/tasks_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Box<Task> box;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('task_manager_test');
    Hive.init(tempDir.path);
    Hive.registerAdapter(TaskStatusAdapter());
    Hive.registerAdapter(TaskAdapter());
    box = await Hive.openBox<Task>('tasks_test');
  });

  tearDownAll(() async {
    await box.close();
    await tempDir.delete(recursive: true);
  });

  testWidgets('Task list screen renders title and FAB',
      (WidgetTester tester) async {
    final repository = TasksRepository(box);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tasksRepositoryProvider.overrideWithValue(repository),
        ],
        child: const TaskManagerApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Задачи'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
