import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/task.dart';
import '../data/tasks_repository.dart';

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  throw UnimplementedError('TasksRepository provider was not overridden.');
});

final tasksControllerProvider =
    StateNotifierProvider<TasksController, TasksState>(
  (ref) => TasksController(ref.watch(tasksRepositoryProvider)),
);

class TasksController extends StateNotifier<TasksState> {
  TasksController(this._repository)
      : super(const TasksState(active: [], archived: [])) {
    load();
  }

  final TasksRepository _repository;

  void load() {
    state = TasksState(
      active: _repository.getAll(),
      archived: _repository.getArchived(),
    );
  }

  Future<void> upsert(Task task) async {
    await _repository.upsert(task);
    load();
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
    load();
  }

  Future<void> toggleDone(String id) async {
    await _repository.toggleDone(id);
    load();
  }

  Future<void> archiveTask(String id) async {
    await _repository.archiveTask(id);
    load();
  }
}

class TasksState {
  const TasksState({required this.active, required this.archived});

  final List<Task> active;
  final List<Task> archived;
}
