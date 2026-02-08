import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/models/task.dart';
import 'package:tech_knowl_edge_connect/services/content_admin_service.dart';

class PreviewDialog extends StatelessWidget {
  final ContentAdminService adminService;
  final String subjectId;
  final String categoryId;
  final String topicId;
  final String unitId;
  final String conceptId;
  final String learningBiteId;
  final Map<String, dynamic> learningBiteData;
  final List<Task> tasks;

  const PreviewDialog({
    super.key,
    required this.adminService,
    required this.subjectId,
    required this.categoryId,
    required this.topicId,
    required this.unitId,
    required this.conceptId,
    required this.learningBiteId,
    required this.learningBiteData,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    final contentParts = List<String>.from(learningBiteData['content'] ?? []);

    return AlertDialog(
      title: Text(learningBiteData['title'] ?? 'Vorschau'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            if (contentParts.isNotEmpty) ...[
              const Text('Inhalte:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              ...contentParts.asMap().entries.map((entry) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Teil ${entry.key + 1}:\n${entry.value}'),
                    ),
                  )),
              const SizedBox(height: 12),
            ],
            if (tasks.isNotEmpty) ...[
              const Text('Aufgaben:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              ...tasks.map(
                (task) => Card(
                  child: ListTile(
                    title: Text(task.question),
                    subtitle: Text(
                        'Antwort: ${task.correctAnswer}\nOptionen: ${task.answers.join(", ")}\nTyp: ${task.type.name}'),
                    isThreeLine: true,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Schließen'),
        ),
      ],
    );
  }
}
