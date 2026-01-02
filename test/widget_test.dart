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

  setUp(() async {
    await box.clear();
  });

  tearDownAll(() async {
    await box.close();
    await tempDir.delete(recursive: true);
  });

  testWidgets('Task list screen sorts and filters by tag',
      (WidgetTester tester) async {
    final repository = TasksRepository(box);
    final now = DateTime.now();

    await repository.upsert(
      Task(
        id: '1',
        title: 'Первая',
        description: 'Описание 1',
        dueAt: DateTime(now.year, now.month, now.day + 3),
        status: TaskStatus.planned,
        tags: const ['работа'],
        attachments: const [],
        createdAt: now,
        updatedAt: now,
        completedAt: null,
      ),
    );
    await repository.upsert(
      Task(
        id: '2',
        title: 'Вторая',
        description: 'Описание 2',
        dueAt: DateTime(now.year, now.month, now.day + 1),
        status: TaskStatus.planned,
        tags: const ['дом'],
        attachments: const [],
        createdAt: now.add(const Duration(minutes: 1)),
        updatedAt: now.add(const Duration(minutes: 1)),
        completedAt: null,
      ),
    );
    await repository.upsert(
      Task(
        id: '3',
        title: 'Третья',
        description: 'Описание 3',
        dueAt: DateTime(now.year, now.month, now.day + 5),
        status: TaskStatus.planned,
        tags: const ['работа'],
        attachments: const [],
        createdAt: now.add(const Duration(minutes: 2)),
        updatedAt: now.add(const Duration(minutes: 2)),
        completedAt: null,
      ),
    );

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

    final secondPosition = tester.getTopLeft(find.text('Вторая')).dy;
    final firstPosition = tester.getTopLeft(find.text('Первая')).dy;
    final thirdPosition = tester.getTopLeft(find.text('Третья')).dy;
    expect(secondPosition < firstPosition, isTrue);
    expect(firstPosition < thirdPosition, isTrue);

    await tester.tap(find.byIcon(Icons.swap_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('По убыванию срока').last);
    await tester.pumpAndSettle();

    final secondPositionDesc = tester.getTopLeft(find.text('Вторая')).dy;
    final firstPositionDesc = tester.getTopLeft(find.text('Первая')).dy;
    final thirdPositionDesc = tester.getTopLeft(find.text('Третья')).dy;
    expect(thirdPositionDesc < firstPositionDesc, isTrue);
    expect(firstPositionDesc < secondPositionDesc, isTrue);

    await tester.tap(find.byIcon(Icons.filter_alt_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('работа (2)').last);
    await tester.tap(find.text('Применить'));
    await tester.pumpAndSettle();

    expect(find.text('Первая'), findsOneWidget);
    expect(find.text('Третья'), findsOneWidget);
    expect(find.text('Вторая'), findsNothing);

    await tester.tap(find.byIcon(Icons.filter_alt_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Все теги').last);
    await tester.tap(find.text('Применить'));
    await tester.pumpAndSettle();

    expect(find.text('Вторая'), findsOneWidget);
  });
}
