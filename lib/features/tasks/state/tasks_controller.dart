import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/task.dart';
import '../data/tasks_repository.dart';

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  throw UnimplementedError('TasksRepository provider was not overridden.');
});

final tasksControllerProvider = StateNotifierProvider<TasksController, List<Task>>(
  (ref) => TasksController(ref.watch(tasksRepositoryProvider)),
);

class TasksController extends StateNotifier<List<Task>> {
  TasksController(this._repository) : super([]) {
    load();
  }

  final TasksRepository _repository;

  void load() {
    state = _repository.getAll();
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
}
