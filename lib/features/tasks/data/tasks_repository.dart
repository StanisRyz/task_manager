import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import 'task.dart';

class TasksRepository {
  TasksRepository(this._box);

  final Box<Task> _box;

  List<Task> getAll() {
    try {
      final tasks = _box.values.where((task) => task.archivedAt == null).toList();
      tasks.sort((a, b) {
        final aDone = a.status == TaskStatus.done;
        final bDone = b.status == TaskStatus.done;
        if (aDone != bDone) {
          return aDone ? 1 : -1;
        }
        final aDue = a.dueAt ?? DateTime(9999);
        final bDue = b.dueAt ?? DateTime(9999);
        final dueCompare = aDue.compareTo(bDue);
        if (dueCompare != 0) {
          return dueCompare;
        }
        return a.createdAt.compareTo(b.createdAt);
      });
      return tasks;
    } catch (error, stackTrace) {
      debugPrint('Не удалось загрузить задачи: $error');
      debugPrintStack(stackTrace: stackTrace);
      return [];
    }
  }

  List<Task> getArchived() {
    try {
      final tasks =
          _box.values.where((task) => task.archivedAt != null).toList();
      tasks.sort((a, b) {
        final aArchived = a.archivedAt ?? DateTime(1970);
        final bArchived = b.archivedAt ?? DateTime(1970);
        return bArchived.compareTo(aArchived);
      });
      return tasks;
    } catch (error, stackTrace) {
      debugPrint('Не удалось загрузить архив: $error');
      debugPrintStack(stackTrace: stackTrace);
      return [];
    }
  }

  Future<void> upsert(Task task) async {
    try {
      await _box.put(task.id, task);
    } catch (error, stackTrace) {
      debugPrint('Не удалось сохранить задачу: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _box.delete(id);
    } catch (error, stackTrace) {
      debugPrint('Не удалось удалить задачу: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> toggleDone(String id) async {
    try {
      final task = _box.get(id);
      if (task == null) {
        return;
      }
      final now = DateTime.now();
      final isDone = task.status == TaskStatus.done;
      final updatedTask = task.copyWith(
        status: isDone ? TaskStatus.planned : TaskStatus.done,
        completedAt: isDone ? null : now,
        updatedAt: now,
      );
      await _box.put(id, updatedTask);
    } catch (error, stackTrace) {
      debugPrint('Не удалось обновить статус: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> archiveTask(String id) async {
    try {
      final task = _box.get(id);
      if (task == null) {
        return;
      }
      final now = DateTime.now();
      final updatedTask = task.copyWith(
        status: TaskStatus.done,
        completedAt: task.completedAt ?? now,
        archivedAt: now,
        updatedAt: now,
      );
      await _box.put(id, updatedTask);
    } catch (error, stackTrace) {
      debugPrint('Не удалось архивировать задачу: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
