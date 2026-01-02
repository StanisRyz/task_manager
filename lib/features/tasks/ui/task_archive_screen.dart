import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations_ext.dart';
import '../data/task.dart';
import '../state/tasks_controller.dart';
import 'task_editor_screen.dart';
import 'task_status_label.dart';

class TaskArchiveScreen extends ConsumerWidget {
  const TaskArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final archived = ref.watch(tasksControllerProvider).archived;
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    final cardColor = isDark
        ? scheme.surfaceContainerHighest
        : scheme.surfaceContainerLow;
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final dateFormat = DateFormat('dd.MM.yyyy', localeTag);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.archiveTitle),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(l10n.backToTasks),
          ),
        ],
      ),
      body: archived.isEmpty
          ? Center(
              child: Text(l10n.archiveEmpty),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: archived.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final task = archived[index];
                final archivedLabel = task.completedAt == null
                    ? null
                    : l10n.archivedOn(
                        dateFormat.format(task.completedAt!),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            task.status.label(l10n),
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          if (archivedLabel != null) ...[
                            const SizedBox(height: 4),
                            Text(archivedLabel),
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
                  ),
                );
              },
            ),
    );
  }
}

extension TaskArchiveFilter on List<Task> {
  List<Task> get archived =>
      where((task) => task.status == TaskStatus.done).toList();
}
