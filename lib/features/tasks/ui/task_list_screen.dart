import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/gen_l10n/app_localizations.dart';

import '../../settings/ui/settings_screen.dart';
import '../../../l10n/app_localizations_ext.dart';
import '../data/task.dart';
import '../state/tasks_controller.dart';
import 'task_archive_screen.dart';
import 'task_editor_screen.dart';
import 'task_filter_screen.dart';
import 'task_status_label.dart';

enum TaskDeadlineSort {
  ascending,
  descending,
}

extension TaskDeadlineSortLabel on TaskDeadlineSort {
  String label(AppLocalizations l10n) {
    switch (this) {
      case TaskDeadlineSort.ascending:
        return l10n.sortAscending;
      case TaskDeadlineSort.descending:
        return l10n.sortDescending;
    }
  }
}

final taskSortProvider =
    StateProvider<TaskDeadlineSort>((ref) => TaskDeadlineSort.ascending);

final taskTagFilterProvider = StateProvider<String?>((ref) => null);

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  String _formatRemainingDays(
    AppLocalizations l10n,
    int days,
    NumberFormat numberFormat,
  ) {
    final formatted = numberFormat.format(days);
    return l10n.remainingDays(days).replaceAll('#', formatted);
  }

  String _formatDueLabel(
    AppLocalizations l10n,
    DateTime dueAt,
    DateFormat dateFormat,
    NumberFormat numberFormat,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(dueAt.year, dueAt.month, dueAt.day);
    final remainingDays = dueDate.difference(today).inDays;
    final safeDays = remainingDays < 0 ? 0 : remainingDays;
    return l10n.dueLabel(
      dateFormat.format(dueDate),
      _formatRemainingDays(l10n, safeDays, numberFormat),
    );
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
    final l10n = context.l10n;
    final tasks = ref.watch(tasksControllerProvider);
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    final cardColor = isDark
        ? scheme.surfaceContainerHighest
        : scheme.surfaceContainerLow;
    final visibleTasks =
        tasks.where((task) => task.status != TaskStatus.done).toList();
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final dateFormat = DateFormat('dd.MM.yyyy', localeTag);
    final numberFormat = NumberFormat.decimalPattern(localeTag);
    final selectedSort = ref.watch(taskSortProvider);
    final selectedTag = ref.watch(taskTagFilterProvider);

    Future<void> confirmDelete(Task task) async {
      final shouldDelete = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          content: Text(l10n.deleteTaskMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.no),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.yes),
            ),
          ],
        ),
      );
      if (shouldDelete == true) {
        await ref.read(tasksControllerProvider.notifier).delete(task.id);
      }
    }

    final tagCounts = <String, int>{};
    for (final task in visibleTasks) {
      for (final tag in task.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }
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
        title: Text(l10n.tasksTitle),
        actions: [
          IconButton(
            key: const Key('open-filter-button'),
            tooltip: l10n.filterTooltip,
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: openFilterScreen,
          ),
          PopupMenuButton<TaskDeadlineSort>(
            key: const Key('sort-menu-button'),
            tooltip: l10n.sortTooltip,
            icon: const Icon(Icons.swap_vert),
            onSelected: (value) {
              ref.read(taskSortProvider.notifier).state = value;
            },
            itemBuilder: (context) => TaskDeadlineSort.values
                .map(
                  (sort) => PopupMenuItem(
                    value: sort,
                    child: Text(sort.label(l10n)),
                  ),
                )
                .toList(),
          ),
          IconButton(
            tooltip: l10n.archiveTooltip,
            icon: const Icon(Icons.archive_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const TaskArchiveScreen(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: l10n.settingsTooltip,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: sortedTasks.isEmpty
          ? Center(
              child: Text(l10n.tasksEmpty),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sortedTasks.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final task = sortedTasks[index];
                final dueLabel = task.dueAt == null
                    ? l10n.dueDateNotSet
                    : _formatDueLabel(
                        l10n,
                        task.dueAt!,
                        dateFormat,
                        numberFormat,
                      );

                return Material(
                  color: cardColor,
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
                                        decoration: task.status ==
                                                TaskStatus.done
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  task.status.label(l10n),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(dueLabel),
                                if (task.tags.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: -6,
                                    children: task.tags
                                        .map(
                                          (tag) => Chip(
                                            label: Text('#$tag'),
                                            visualDensity:
                                                VisualDensity.compact,
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check),
                                onPressed: () async {
                                  final shouldComplete =
                                      await showDialog<bool>(
                                    context: context,
                                    builder: (dialogContext) => AlertDialog(
                                      title: Text(l10n.markCompletedTitle),
                                      content: Text(l10n.markCompletedMessage),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(dialogContext)
                                                .pop(false);
                                          },
                                          child: Text(l10n.no),
                                        ),
                                        FilledButton(
                                          onPressed: () {
                                            Navigator.of(dialogContext)
                                                .pop(true);
                                          },
                                          child: Text(l10n.yes),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (shouldComplete == true) {
                                    await ref
                                        .read(
                                          tasksControllerProvider.notifier,
                                        )
                                        .toggleDone(task.id);
                                  }
                                },
                              ),
                              IconButton(
                                tooltip: l10n.deleteTaskTooltip,
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => confirmDelete(task),
                              ),
                            ],
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
          ref.read(taskTagFilterProvider.notifier).state = null;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const TaskEditorScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.newTask),
      ),
    );
  }
}
