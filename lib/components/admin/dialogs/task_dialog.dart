import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/admin/admin_constants.dart';
import 'package:tech_knowl_edge_connect/services/content_admin_service.dart';

class TaskDialog extends StatefulWidget {
  final ContentAdminService adminService;
  final String subjectId;
  final String categoryId;
  final String topicId;
  final String unitId;
  final String conceptId;
  final String learningBiteId;
  final String? taskId;
  final Map<String, dynamic>? existingData;
  final Future<void> Function()? onAfterSave;

  const TaskDialog({
    super.key,
    required this.adminService,
    required this.subjectId,
    required this.categoryId,
    required this.topicId,
    required this.unitId,
    required this.conceptId,
    required this.learningBiteId,
    this.taskId,
    this.existingData,
    this.onAfterSave,
  });

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  late TextEditingController _questionController;
  late TextEditingController _answerController;
  late TextEditingController _answersController;
  late String _type;

  @override
  void initState() {
    super.initState();
    _questionController =
        TextEditingController(text: widget.existingData?['question'] ?? '');
    _answerController = TextEditingController(
        text: widget.existingData?['correctAnswer'] ?? '');
    _answersController = TextEditingController(
        text: (widget.existingData?['answers'] as List?)?.join(', ') ?? '');
    _type = widget.existingData?['type'] ?? 'singleChoice';
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    _answersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget.taskId == null ? 'Aufgabe hinzufügen' : 'Aufgabe bearbeiten'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: AdminConstants.taskTypes.contains(_type)
                  ? _type
                  : AdminConstants.taskTypes.first,
              items: AdminConstants.taskTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _type = value);
              },
              decoration: const InputDecoration(labelText: 'Typ'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _questionController,
              decoration: const InputDecoration(labelText: 'Frage'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _answerController,
              decoration: const InputDecoration(labelText: 'Antwort'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _answersController,
              decoration:
                  const InputDecoration(labelText: 'Antworten (kommagetrennt)'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_questionController.text.trim().isEmpty) return;
            try {
              final answers = _answersController.text
                  .split(',')
                  .map((a) => a.trim())
                  .where((a) => a.isNotEmpty)
                  .toList();

              if (widget.taskId == null) {
                await widget.adminService.createTask(
                  subjectId: widget.subjectId,
                  categoryId: widget.categoryId,
                  topicId: widget.topicId,
                  unitId: widget.unitId,
                  conceptId: widget.conceptId,
                  learningBiteId: widget.learningBiteId,
                  type: _type,
                  question: _questionController.text.trim(),
                  correctAnswer: _answerController.text.trim(),
                  answers: answers,
                );
              } else {
                await widget.adminService.updateTask(
                  subjectId: widget.subjectId,
                  categoryId: widget.categoryId,
                  topicId: widget.topicId,
                  unitId: widget.unitId,
                  conceptId: widget.conceptId,
                  learningBiteId: widget.learningBiteId,
                  taskId: widget.taskId!,
                  data: {
                    'type': _type,
                    'question': _questionController.text.trim(),
                    'correctAnswer': _answerController.text.trim(),
                    'answers': answers,
                  },
                );
              }
              if (widget.onAfterSave != null) {
                await widget.onAfterSave!();
              }
              if (!context.mounted) return;
              Navigator.pop(context);
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Fehler: $e')),
                );
              }
            }
          },
          child: const Text('Speichern'),
        ),
      ],
    );
  }
}
