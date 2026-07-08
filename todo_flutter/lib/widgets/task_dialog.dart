import 'package:flutter/material.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';

class TaskDialogResult {
  final String title;
  final String priority;
  final DateTime? dueDate;
  final String category;
  final String? notes;

  TaskDialogResult({
    required this.title,
    required this.priority,
    required this.dueDate,
    required this.category,
    required this.notes,
  });
}

// Shows Add/Edit task dialog. Pass `existingTask` to edit, leave null to add new.
Future<TaskDialogResult?> showTaskDialog(
  BuildContext context, {
  Task? existingTask,
  List<String> suggestedCategories = const ['General', 'Work', 'Personal', 'Shopping'],
}) {
  return showDialog<TaskDialogResult>(
    context: context,
    builder: (context) => _TaskDialog(
      existingTask: existingTask,
      suggestedCategories: suggestedCategories,
    ),
  );
}

class _TaskDialog extends StatefulWidget {
  final Task? existingTask;
  final List<String> suggestedCategories;

  const _TaskDialog({this.existingTask, required this.suggestedCategories});

  @override
  State<_TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<_TaskDialog> {
  late TextEditingController _titleController;
  late TextEditingController _categoryController;
  late TextEditingController _notesController;
  late String _priority;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingTask?.title ?? '');
    _categoryController =
        TextEditingController(text: widget.existingTask?.category ?? 'General');
    _notesController = TextEditingController(text: widget.existingTask?.notes ?? '');
    _priority = widget.existingTask?.priority ?? 'medium';
    _dueDate = widget.existingTask?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) return;
    Navigator.pop(
      context,
      TaskDialogResult(
        title: _titleController.text.trim(),
        priority: _priority,
        dueDate: _dueDate,
        category: _categoryController.text.trim().isEmpty
            ? 'General'
            : _categoryController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .bodyMedium
          ?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingTask != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Edit Task' : 'New Task',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'What needs to be done?',
                ),
              ),
              const SizedBox(height: 18),
              _sectionLabel('Priority'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['low', 'medium', 'high'].map((p) {
                  final selected = _priority == p;
                  final color = AppColors.priorityColor(p);
                  return ChoiceChip(
                    label: Text(p[0].toUpperCase() + p.substring(1)),
                    selected: selected,
                    selectedColor: color.withOpacity(0.22),
                    side: BorderSide(color: selected ? color : Colors.grey.shade300),
                    avatar: CircleAvatar(backgroundColor: color, radius: 5),
                    onSelected: (_) => setState(() => _priority = p),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              _sectionLabel('Category'),
              const SizedBox(height: 8),
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(hintText: 'e.g. Work, Personal'),
              ),
              if (widget.suggestedCategories.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: widget.suggestedCategories.map((c) {
                    return ActionChip(
                      label: Text(c, style: const TextStyle(fontSize: 12)),
                      onPressed: () => setState(() => _categoryController.text = c),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 18),
              _sectionLabel('Due Date'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today_outlined, size: 17),
                      label: Text(
                        _dueDate == null
                            ? 'Set date'
                            : '${_dueDate!.year}-${_dueDate!.month.toString().padLeft(2, '0')}-${_dueDate!.day.toString().padLeft(2, '0')}',
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _pickDate,
                    ),
                  ),
                  if (_dueDate != null)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _dueDate = null),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              _sectionLabel('Notes (optional)'),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Any extra details...'),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: Text(isEditing ? 'Save' : 'Add Task'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
