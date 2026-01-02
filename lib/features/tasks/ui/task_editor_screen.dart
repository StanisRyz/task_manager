import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _dueDateFieldKey = GlobalKey<FormFieldState<DateTime>>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  final _attachmentController = TextEditingController();
  final _tagsFocusNode = FocusNode();

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
    _tagsFocusNode.dispose();
    super.dispose();
  }

  DateTime _tomorrowDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
  }

  bool _isDueDateValid(DateTime? dueAt) {
    if (dueAt == null) {
      return false;
    }
    return !dueAt.isBefore(_tomorrowDate());
  }

  List<TaskStatus> get _statusOptions {
    if (widget.task == null) {
      return [TaskStatus.planned, TaskStatus.inProgress];
    }
    return TaskStatus.values;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final minDate = _tomorrowDate();
    final initial = _dueAt != null && !_dueAt!.isBefore(minDate)
        ? _dueAt!
        : minDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: minDate,
      lastDate: DateTime(now.year + 10),
      locale: const Locale('ru'),
    );
    if (picked != null) {
      setState(() {
        _dueAt = DateTime(picked.year, picked.month, picked.day);
      });
      _dueDateFieldKey.currentState?.didChange(_dueAt);
      _dueDateFieldKey.currentState?.validate();
    }
  }

  void _clearDueDate() {
    setState(() {
      _dueAt = null;
    });
    _dueDateFieldKey.currentState?.didChange(_dueAt);
    _dueDateFieldKey.currentState?.validate();
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

  List<String> _collectTags(List<Task> tasks) {
    final unique = <String>{};
    for (final task in tasks) {
      unique.addAll(task.tags);
    }
    final tags = unique.toList()..sort();
    return tags;
  }

  String _currentTagPrefix(String text, int cursor) {
    final safeCursor = cursor.clamp(0, text.length);
    final lastComma = text.lastIndexOf(',', safeCursor - 1);
    final start = lastComma == -1 ? 0 : lastComma + 1;
    return text.substring(start, safeCursor).trim();
  }

  void _insertTagSuggestion(String suggestion) {
    final text = _tagsController.text;
    final selection = _tagsController.selection;
    final cursor = selection.baseOffset == -1 ? text.length : selection.baseOffset;
    final safeCursor = cursor.clamp(0, text.length);
    final lastComma = text.lastIndexOf(',', safeCursor - 1);
    final start = lastComma == -1 ? 0 : lastComma + 1;
    final nextComma = text.indexOf(',', safeCursor);
    final end = nextComma == -1 ? text.length : nextComma;

    var before = text.substring(0, start);
    var after = text.substring(end);

    if (before.isNotEmpty) {
      before = before.replaceAll(RegExp(r'\s+$'), '');
      if (!before.endsWith(',')) {
        before = '$before,';
      }
      before = '$before ';
    }

    if (after.isNotEmpty) {
      after = after.replaceFirst(RegExp(r'^\s+'), '');
    }

    final nextText = '$before$suggestion$after';
    final nextCursor = (before.length + suggestion.length).clamp(0, nextText.length);
    _tagsController.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(offset: nextCursor),
    );
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
      description: _descriptionController.text.trim(),
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
    final tasks = ref.watch(tasksControllerProvider);
    final knownTags = _collectTags(tasks);
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
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: null,
                maxLength: 100,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(100),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите описание задачи';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TaskStatus>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Статус',
                ),
                items: _statusOptions
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
              FormField<DateTime>(
                key: _dueDateFieldKey,
                initialValue: _dueAt,
                validator: (value) {
                  if (value == null) {
                    return 'Укажите срок';
                  }
                  if (!_isDueDateValid(value)) {
                    return 'Срок должен быть не раньше завтрашнего дня';
                  }
                  return null;
                },
                builder: (state) {
                  final errorText = state.errorText;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      if (errorText != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            errorText,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.error,
                                ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const Divider(height: 32),
              RawAutocomplete<String>(
                textEditingController: _tagsController,
                focusNode: _tagsFocusNode,
                optionsBuilder: (value) {
                  final prefix = _currentTagPrefix(
                    value.text,
                    value.selection.baseOffset,
                  ).toLowerCase();
                  if (prefix.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  final usedTags = _parseTags(value.text).toSet();
                  return knownTags.where(
                    (tag) =>
                        tag.toLowerCase().startsWith(prefix) &&
                        !usedTags.contains(tag.toLowerCase()),
                  );
                },
                onSelected: _insertTagSuggestion,
                fieldViewBuilder: (
                  context,
                  controller,
                  focusNode,
                  onFieldSubmitted,
                ) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Теги (через запятую)',
                    ),
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  if (options.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  final box = context.findRenderObject() as RenderBox?;
                  final width = box?.size.width ?? 200;
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(12),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: width),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          shrinkWrap: true,
                          itemCount: options.length,
                          separatorBuilder: (_, _) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final option = options.elementAt(index);
                            return ListTile(
                              title: Text(option),
                              onTap: () => onSelected(option),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
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
