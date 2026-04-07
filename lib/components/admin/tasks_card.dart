import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/admin/card_header.dart';
import 'package:tech_knowl_edge_connect/services/content/content_admin_service.dart';
import 'package:tech_knowl_edge_connect/components/admin/admin_constants.dart';

class TasksCard extends StatelessWidget {
  final ContentAdminService adminService;
  final String? selectedSubjectId;
  final String? selectedCategoryId;
  final String? selectedTopicId;
  final String? selectedUnitId;
  final String? selectedConceptId;
  final String? selectedLearningBiteId;
  final VoidCallback? onAdd;
  final Function(String id, Map<String, dynamic> data) onEdit;
  final Function(String id) onDelete;

  const TasksCard({
    super.key,
    required this.adminService,
    required this.selectedSubjectId,
    required this.selectedCategoryId,
    required this.selectedTopicId,
    required this.selectedUnitId,
    required this.selectedConceptId,
    required this.selectedLearningBiteId,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final canInteract = selectedSubjectId != null &&
        selectedCategoryId != null &&
        selectedTopicId != null &&
        selectedUnitId != null &&
        selectedConceptId != null &&
        selectedLearningBiteId != null;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CardHeader(
          title: 'Aufgaben',
          onAdd: canInteract ? onAdd : null,
        ),
        const SizedBox(height: 12),
        if (!canInteract)
          const Text('Bitte Lerninhalt auswählen.')
        else
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: adminService.streamTasks(
              selectedSubjectId!,
              selectedCategoryId!,
              selectedTopicId!,
              selectedUnitId!,
              selectedConceptId!,
              selectedLearningBiteId!,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return const Text('Keine Aufgaben vorhanden.');
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data();
                  final answers = List<String>.from(data['answers'] ?? []);
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainer,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: cs.outlineVariant.withAlpha(40),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: cs.primary.withAlpha(26),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: cs.outlineVariant.withAlpha(51),
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.quiz,
                              color: cs.primary,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['question'] ?? 'Keine Frage',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Antwort: ${data['correctAnswer'] ?? 'Keine Antwort'}${answers.isEmpty ? '' : '\nOptionen: ${answers.join(", ")}'}\nTyp: ${AdminConstants.taskTypeLabels[data['type']] ?? data['type'] ?? 'unbekannt'}',
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon:
                                  Icon(Icons.edit, color: cs.onSurfaceVariant),
                              tooltip: 'Bearbeiten',
                              style: IconButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => onEdit(doc.id, data),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline,
                                  color: cs.onSurfaceVariant),
                              tooltip: 'Löschen',
                              style: IconButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => onDelete(doc.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
      ],
    );
  }
}
