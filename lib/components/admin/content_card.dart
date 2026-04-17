import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/admin/card_header.dart';
import 'package:tech_knowl_edge_connect/services/content/content_admin_service.dart';

class ContentCard extends StatelessWidget {
  final ContentAdminService adminService;
  final String? selectedSubjectId;
  final String? selectedCategoryId;
  final String? selectedTopicId;
  final String? selectedUnitId;
  final String? selectedConceptId;
  final String? selectedLearningBiteId;
  final VoidCallback onAdd;
  final Function(int index, String content, List<String> allContent) onEdit;
  final Function(int index, List<String> allContent) onDelete;

  const ContentCard({
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
          title: 'Inhalte',
          onAdd: canInteract ? onAdd : null,
        ),
        const SizedBox(height: 12),
        if (!canInteract)
          const Text('Bitte ein Learning Bite auswählen.')
        else
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: adminService.streamLearningBite(
              selectedSubjectId!,
              selectedCategoryId!,
              selectedTopicId!,
              selectedUnitId!,
              selectedConceptId!,
              selectedLearningBiteId!,
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }
              final data = snapshot.data?.data();
              final contentList = List<String>.from(data?['content'] ?? []);
              if (contentList.isEmpty) {
                return const Text('Keine Inhalte vorhanden.');
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: contentList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final content = contentList[index];
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
                              Icons.description,
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
                                'Teil ${index + 1}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                content,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
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
                              onPressed: () => onEdit(
                                index,
                                content,
                                contentList,
                              ),
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
                              onPressed: () => onDelete(
                                index,
                                contentList,
                              ),
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
