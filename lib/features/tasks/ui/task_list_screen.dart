import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/task.dart';
import '../state/tasks_controller.dart';
import 'task_archive_screen.dart';
import 'task_editor_screen.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksControllerProvider);
    final visibleTasks =
        tasks.where((task) => task.status != TaskStatus.done).toList();
    final dateFormat = DateFormat('dd.MM.yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Задачи'),
        actions: [
          IconButton(
            tooltip: 'Архив',
            icon: const Icon(Icons.archive_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const TaskArchiveScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: visibleTasks.isEmpty
          ? const Center(
              child: Text('Задач пока нет'),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: visibleTasks.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final task = visibleTasks[index];
                final dueLabel = task.dueAt == null
                    ? null
                    : 'Срок: ${dateFormat.format(task.dueAt!)}';

                return Material(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TaskEditorScreen(task: task),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        decoration: task.status == TaskStatus.done
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  task.status.label,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                ),
                                if (dueLabel != null) ...[
                                  const SizedBox(height: 4),
                                  Text(dueLabel),
                                ],
                                if (task.tags.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: -6,
                                    children: task.tags
                                        .map(
                                          (tag) => Chip(
                                            label: Text('#$tag'),
                                            visualDensity: VisualDensity.compact,
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Checkbox(
                            value: task.status == TaskStatus.done,
                            onChanged: (value) async {
                              if (value != true) {
                                return;
                              }
                              final shouldComplete = await showDialog<bool>(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  title: const Text('Отметить выполненной'),
                                  content: const Text(
                                    'Перенести задачу в архив?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(dialogContext).pop(false);
                                      },
                                      child: const Text('Нет'),
                                    ),
                                    FilledButton(
                                      onPressed: () {
                                        Navigator.of(dialogContext).pop(true);
                                      },
                                      child: const Text('Да'),
                                    ),
                                  ],
                                ),
                              );
                              if (shouldComplete == true) {
                                await ref
                                    .read(tasksControllerProvider.notifier)
                                    .toggleDone(task.id);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const TaskEditorScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Новая задача'),
      ),
    );
  }
}
