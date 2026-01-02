import 'package:hive/hive.dart';

enum TaskStatus {
  planned,
  inProgress,
  done,
}

class Task {
  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueAt,
    required this.status,
    required this.tags,
    required this.attachments,
    required this.createdAt,
    required this.updatedAt,
    required this.completedAt,
  });

  final String id;
  final String title;
  final String? description;
  final DateTime? dueAt;
  final TaskStatus status;
  final List<String> tags;
  final List<String> attachments;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueAt,
    TaskStatus? status,
    List<String>? tags,
    List<String>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueAt: dueAt ?? this.dueAt,
      status: status ?? this.status,
      tags: tags ?? List<String>.from(this.tags),
      attachments: attachments ?? List<String>.from(this.attachments),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class TaskStatusAdapter extends TypeAdapter<TaskStatus> {
  @override
  final int typeId = 2;

  @override
  TaskStatus read(BinaryReader reader) {
    final index = reader.readByte();
    return TaskStatus.values[index];
  }

  @override
  void write(BinaryWriter writer, TaskStatus obj) {
    writer.writeByte(obj.index);
  }
}

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 1;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return Task(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      dueAt: fields[3] as DateTime?,
      status: fields[4] as TaskStatus,
      tags: (fields[5] as List).cast<String>(),
      attachments: (fields[6] as List).cast<String>(),
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
      completedAt: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.dueAt)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.tags)
      ..writeByte(6)
      ..write(obj.attachments)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.completedAt);
  }
}
