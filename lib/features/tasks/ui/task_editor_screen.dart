import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../common/ui/swipe_back_wrapper.dart';
import '../../../l10n/app_localizations_ext.dart';
import '../data/attachment_storage.dart';
import '../data/task.dart';
import '../state/tasks_controller.dart';
import 'task_status_label.dart';

class TaskEditorScreen extends ConsumerStatefulWidget {
  const TaskEditorScreen({super.key, this.task});

  final Task? task;

  @override
  ConsumerState<TaskEditorScreen> createState() => _TaskEditorScreenState();
}

final _singleLineAllowedCharacters =
    RegExp(r'[\p{L}\p{M}\p{N}\p{P}\p{S}\p{Z}]', unicode: true);
final _multiLineAllowedCharacters =
    RegExp(r'[\p{L}\p{M}\p{N}\p{P}\p{S}\p{Z}\n]', unicode: true);
const _documentExtensions = <String>[
  'pdf',
  'doc',
  'docx',
  'txt',
  'rtf',
  'xls',
  'xlsx',
  'ppt',
  'pptx',
];

enum AttachmentType {
  photo,
  video,
  document,
}

class _TaskEditorScreenState extends ConsumerState<TaskEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dueDateFieldKey = GlobalKey<FormFieldState<DateTime>>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  final _tagsFocusNode = FocusNode();
  final _singleLineFormatter =
      FilteringTextInputFormatter.allow(_singleLineAllowedCharacters);
  final _multiLineFormatter =
      FilteringTextInputFormatter.allow(_multiLineAllowedCharacters);

  late TaskStatus _status;
  DateTime? _dueAt;
  late List<String> _attachments;
  AttachmentType _attachmentType = AttachmentType.photo;

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
      locale: Localizations.localeOf(context),
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

  bool _addAttachmentValue(String value) {
    if (value.isEmpty || _attachments.contains(value)) {
      return false;
    }
    setState(() {
      _attachments.add(value);
    });
    return true;
  }

  Future<void> _pickAttachment(AttachmentType type) async {
    final result = await FilePicker.platform.pickFiles(
      type: type == AttachmentType.document
          ? FileType.custom
          : type == AttachmentType.photo
              ? FileType.image
              : FileType.video,
      allowedExtensions:
          type == AttachmentType.document ? _documentExtensions : null,
    );
    if (result == null) {
      return;
    }
    final selected = result.files.single;
    final storedPath = await storeAttachmentFile(selected);
    if (storedPath == null || storedPath.isEmpty) {
      return;
    }
    _addAttachmentValue(storedPath);
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

  Map<String, int> _collectTagCounts(List<Task> tasks) {
    final counts = <String, int>{};
    for (final task in tasks) {
      for (final tag in task.tags) {
        counts[tag] = (counts[tag] ?? 0) + 1;
      }
    }
    return counts;
  }

  String _currentTagPrefix(String text, int cursor) {
    final safeCursor = cursor.clamp(0, text.length);
    if (safeCursor == 0) {
      return '';
    }
    final lastComma = text.lastIndexOf(',', safeCursor - 1);
    final start = lastComma == -1 ? 0 : lastComma + 1;
    return text.substring(start, safeCursor).trim();
  }

  void _insertTagSuggestion(String suggestion) {
    final text = _tagsController.text;
    final selection = _tagsController.selection;
    final cursor =
        selection.baseOffset == -1 ? text.length : selection.baseOffset;
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
    final nextCursor =
        (before.length + suggestion.length).clamp(0, nextText.length);
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
    final l10n = context.l10n;
    final tasks = ref.watch(tasksControllerProvider);
    final tagCounts = _collectTagCounts(tasks);
    final knownTags = tagCounts.keys.toList()..sort();
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final dateFormat = DateFormat('dd.MM.yyyy', localeTag);
    final dueLabel = _dueAt == null
        ? l10n.dueDateNotSet
        : dateFormat.format(_dueAt!);

    return SwipeBackWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.task == null ? l10n.taskNewTitle : l10n.taskEditTitle,
          ),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: l10n.titleLabel,
                  ),
                  inputFormatters: [
                    _singleLineFormatter,
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.titleRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: l10n.descriptionLabel,
                  ),
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: null,
                  maxLength: 100,
                  inputFormatters: [
                    _multiLineFormatter,
                    LengthLimitingTextInputFormatter(100),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.descriptionRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TaskStatus>(
                  initialValue: _status,
                  decoration: InputDecoration(
                    labelText: l10n.statusLabel,
                  ),
                  items: _statusOptions
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.label(l10n)),
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
                      return l10n.dueDateRequired;
                    }
                    if (!_isDueDateValid(value)) {
                      return l10n.dueDateInvalid;
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
                          title: Text(l10n.dueDateTitle),
                          subtitle: Text(dueLabel),
                          trailing: Wrap(
                            spacing: 8,
                            children: [
                              if (_dueAt != null)
                                IconButton(
                                  tooltip: l10n.clearDate,
                                  onPressed: _clearDueDate,
                                  icon: const Icon(Icons.clear),
                                ),
                              IconButton(
                                tooltip: l10n.pickDate,
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
                                    color: Theme.of(context)
                                        .colorScheme
                                        .error,
                                  ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const Divider(height: 32),
                TextField(
                  controller: _tagsController,
                  autocorrect: false,
                  enableSuggestions: false,
                  autofillHints: const <String>[],
                  decoration: InputDecoration(
                    labelText: l10n.tagsLabel,
                  ),
                  inputFormatters: [
                    _singleLineFormatter,
                  ],
                ),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _tagsController,
                  builder: (context, value, child) {
                    final prefix = _currentTagPrefix(
                      value.text,
                      value.selection.baseOffset,
                    ).toLowerCase();
                    if (prefix.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    final usedTags = _parseTags(value.text).toSet();
                    final suggestions = knownTags
                        .where(
                          (tag) =>
                              tag.toLowerCase().startsWith(prefix) &&
                              !usedTags.contains(tag.toLowerCase()),
                        )
                        .toList();
                    if (suggestions.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Material(
                        elevation: 2,
                        borderRadius: BorderRadius.circular(12),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: suggestions.length,
                          separatorBuilder: (_, _) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final tag = suggestions[index];
                            final count = tagCounts[tag] ?? 0;
                            return ListTile(
                              title: Text('$tag ($count)'),
                              onTap: () => _insertTagSuggestion(tag),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.attachmentsTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<AttachmentType>(
                        initialValue: _attachmentType,
                        decoration: InputDecoration(
                          labelText: l10n.attachmentTypeLabel,
                        ),
                        items: AttachmentType.values
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(
                                  switch (type) {
                                    AttachmentType.photo =>
                                      l10n.attachmentTypePhoto,
                                    AttachmentType.video =>
                                      l10n.attachmentTypeVideo,
                                    AttachmentType.document =>
                                      l10n.attachmentTypeDocument,
                                  },
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _attachmentType = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: () => _pickAttachment(_attachmentType),
                      icon: const Icon(Icons.attach_file),
                      label: Text(l10n.addAttachmentFile),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_attachments.isEmpty)
                  Text(
                    l10n.noAttachments,
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
                  child: Text(l10n.save),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
