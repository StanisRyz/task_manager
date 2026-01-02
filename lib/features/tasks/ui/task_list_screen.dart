import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/task.dart';
import '../state/tasks_controller.dart';
import 'task_archive_screen.dart';
import 'task_editor_screen.dart';
import 'task_filter_screen.dart';

enum TaskDeadlineSort {
  ascending,
  descending,
}

extension TaskDeadlineSortLabel on TaskDeadlineSort {
  String get label {
    switch (this) {
      case TaskDeadlineSort.ascending:
        return 'По возрастанию срока';
      case TaskDeadlineSort.descending:
        return 'По убыванию срока';
    }
  }
}

final taskSortProvider =
    StateProvider<TaskDeadlineSort>((ref) => TaskDeadlineSort.ascending);

final taskTagFilterProvider = StateProvider<String?>((ref) => null);

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  String _formatRemainingDays(int days) {
    final mod10 = days % 10;
    final mod100 = days % 100;
    if (mod10 == 1 && mod100 != 11) {
      return 'осталось $days день';
    }
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
      return 'осталось $days дня';
    }
    return 'осталось $days дней';
  }

  String _formatDueLabel(DateTime dueAt, DateFormat dateFormat) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(dueAt.year, dueAt.month, dueAt.day);
    final remainingDays = dueDate.difference(today).inDays;
    final safeDays = remainingDays < 0 ? 0 : remainingDays;
    return 'Срок: ${dateFormat.format(dueDate)} '
        '(${_formatRemainingDays(safeDays)})';
  }

  List<Task> _sortTasks(List<Task> tasks, TaskDeadlineSort sort) {
    int compareAscending(DateTime? first, DateTime? second) {
      if (first == null && second == null) {
        return 0;
      }
      if (first == null) {
        return 1;
      }
      if (second == null) {
        return -1;
      }
      return first.compareTo(second);
    }

    int compareDescending(DateTime? first, DateTime? second) {
      if (first == null && second == null) {
        return 0;
      }
      if (first == null) {
        return 1;
      }
      if (second == null) {
        return -1;
      }
      return second.compareTo(first);
    }

    final sorted = List<Task>.from(tasks);
    sorted.sort((a, b) {
      final dueCompare = sort == TaskDeadlineSort.ascending
          ? compareAscending(a.dueAt, b.dueAt)
          : compareDescending(a.dueAt, b.dueAt);
      if (dueCompare != 0) {
        return dueCompare;
      }
      return a.createdAt.compareTo(b.createdAt);
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksControllerProvider);
    final visibleTasks =
        tasks.where((task) => task.status != TaskStatus.done).toList();
    final dateFormat = DateFormat('dd.MM.yyyy');
    final selectedSort = ref.watch(taskSortProvider);
    final selectedTag = ref.watch(taskTagFilterProvider);

    final tagCounts = <String, int>{};
    for (final task in visibleTasks) {
      for (final tag in task.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }
    final sortedTags = tagCounts.keys.toList()..sort();
    if (selectedTag != null && !tagCounts.containsKey(selectedTag)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(taskTagFilterProvider.notifier).state = null;
      });
    }

    final filteredTasks = selectedTag == null
        ? visibleTasks
        : visibleTasks
            .where((task) => task.tags.contains(selectedTag))
            .toList();
    final sortedTasks = _sortTasks(filteredTasks, selectedSort);

    Future<void> openFilterScreen() async {
      final result = await Navigator.of(context).push<String?>(
        MaterialPageRoute(
          builder: (_) => TaskFilterScreen(
            initialTag: selectedTag,
          ),
        ),
      );
      if (result != null || selectedTag != null) {
        ref.read(taskTagFilterProvider.notifier).state = result;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Задачи'),
        actions: [
          IconButton(
            tooltip: 'Фильтры',
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: openFilterScreen,
          ),
          PopupMenuButton<TaskDeadlineSort>(
            tooltip: 'Сортировка',
            icon: const Icon(Icons.swap_vert),
            onSelected: (value) {
              ref.read(taskSortProvider.notifier).state = value;
            },
            itemBuilder: (context) => TaskDeadlineSort.values
                .map(
                  (sort) => PopupMenuItem(
                    value: sort,
                    child: Text(sort.label),
                  ),
                )
                .toList(),
          ),
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
      body: sortedTasks.isEmpty
          ? const Center(
              child: Text('Задач пока нет'),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sortedTasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final task = sortedTasks[index];
          final dueLabel = task.dueAt == null
              ? null
              : _formatDueLabel(task.dueAt!, dateFormat);

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
                                  color:
                                      Theme.of(context).colorScheme.primary,
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
