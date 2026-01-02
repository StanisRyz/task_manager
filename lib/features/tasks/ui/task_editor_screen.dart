import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../data/task.dart';
import '../state/tasks_controller.dart';

class TaskEditorScreen extends ConsumerStatefulWidget {
  const TaskEditorScreen({super.key, this.task});

  final Task? task;

  @override
  ConsumerState<TaskEditorScreen> createState() => _TaskEditorScreenState();
}

class _TaskEditorScreenState extends ConsumerState<TaskEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  final _attachmentController = TextEditingController();

  late TaskStatus _status;
  DateTime? _dueAt;
  late List<String> _attachments;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController.text = task?.title ?? '';
    _descriptionController.text = task?.description ?? '';
    _tagsController.text = task?.tags.join(', ') ?? '';
    _status = task?.status ?? TaskStatus.planned;
    _dueAt = task?.dueAt;
    _attachments = List<String>.from(task?.attachments ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _attachmentController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _dueAt ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
      locale: const Locale('ru'),
    );
    if (picked != null) {
      setState(() {
        _dueAt = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  void _clearDueDate() {
    setState(() {
      _dueAt = null;
    });
  }

  void _addAttachment() {
    final value = _attachmentController.text.trim();
    if (value.isEmpty) {
      return;
    }
    if (_attachments.contains(value)) {
      _attachmentController.clear();
      return;
    }
    setState(() {
      _attachments.add(value);
      _attachmentController.clear();
    });
  }

  List<String> _parseTags(String raw) {
    final parts = raw
        .split(',')
        .map((tag) => tag.trim().toLowerCase())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList();
    parts.sort();
    return parts;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final now = DateTime.now();
    final existing = widget.task;
    final status = _status;
    final completedAt = status == TaskStatus.done
        ? existing?.completedAt ?? now
        : null;
    final task = Task(
      id: existing?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      dueAt: _dueAt,
      status: status,
      tags: _parseTags(_tagsController.text),
      attachments: List<String>.from(_attachments),
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      completedAt: completedAt,
    );

    await ref.read(tasksControllerProvider.notifier).upsert(task);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    final dueLabel = _dueAt == null
        ? 'Не задан'
        : dateFormat.format(_dueAt!);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Новая задача' : 'Редактирование'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Название',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите название задачи';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Описание',
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TaskStatus>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Статус',
                ),
                items: TaskStatus.values
                    .map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(status.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _status = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Срок'),
                subtitle: Text(dueLabel),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    if (_dueAt != null)
                      IconButton(
                        tooltip: 'Очистить дату',
                        onPressed: _clearDueDate,
                        icon: const Icon(Icons.clear),
                      ),
                    IconButton(
                      tooltip: 'Выбрать дату',
                      onPressed: _pickDate,
                      icon: const Icon(Icons.event),
                    ),
                  ],
                ),
              ),
              const Divider(height: 32),
              TextField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Теги (через запятую)',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Вложения',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _attachmentController,
                      decoration: const InputDecoration(
                        labelText: 'Добавить вложение (строка)',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _addAttachment,
                    child: const Text('Добавить'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_attachments.isEmpty)
                Text(
                  'Вложений нет',
                  style: Theme.of(context).textTheme.bodySmall,
                )
              else
                Column(
                  children: _attachments
                      .map(
                        (attachment) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(attachment),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () {
                              setState(() {
                                _attachments.remove(attachment);
                              });
                            },
                          ),
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _save,
                child: const Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
