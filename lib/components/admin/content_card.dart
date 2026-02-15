import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/admin/card_header.dart';
import 'package:tech_knowl_edge_connect/services/content_admin_service.dart';

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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CardHeader(
              title: 'Inhalte',
              onAdd: canInteract ? onAdd : null,
            ),
            const SizedBox(height: 8),
            if (!canInteract)
              const Text('Bitte einen Learning Bite auswählen.')
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
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
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
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final content = contentList[index];
                      return ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 4),
                        title: Text(
                          'Teil ${index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: 'Bearbeiten',
                              onPressed: () => onEdit(
                                index,
                                content,
                                contentList,
                              ),
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              tooltip: 'Löschen',
                              onPressed: () => onDelete(
                                index,
                                contentList,
                              ),
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
