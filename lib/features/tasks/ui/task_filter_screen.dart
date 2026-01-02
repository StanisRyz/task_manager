import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/task.dart';
import '../state/tasks_controller.dart';

class TaskFilterScreen extends ConsumerStatefulWidget {
  const TaskFilterScreen({super.key, required this.initialTag});

  final String? initialTag;

  @override
  ConsumerState<TaskFilterScreen> createState() => _TaskFilterScreenState();
}

class _TaskFilterScreenState extends ConsumerState<TaskFilterScreen> {
  String? _selectedTag;

  @override
  void initState() {
    super.initState();
    _selectedTag = widget.initialTag;
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(tasksControllerProvider);
    final visibleTasks =
        tasks.where((task) => task.status != TaskStatus.done).toList();
    final tagCounts = <String, int>{};
    for (final task in visibleTasks) {
      for (final tag in task.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }
    final sortedTags = tagCounts.keys.toList()..sort();
    if (_selectedTag != null && !tagCounts.containsKey(_selectedTag)) {
      _selectedTag = null;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Фильтры'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RadioGroup<String?>(
                groupValue: _selectedTag,
                onChanged: (value) {
                  setState(() {
                    _selectedTag = value;
                  });
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Теги',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    const RadioListTile<String?>(
                      value: null,
                      title: Text('Все теги'),
                    ),
                    if (sortedTags.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Теги пока не добавлены'),
                      )
                    else
                      ...sortedTags.map(
                        (tag) => RadioListTile<String?>(
                          value: tag,
                          title: Text('$tag (${tagCounts[tag] ?? 0})'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop(_selectedTag);
                  },
                  child: const Text('Применить'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
