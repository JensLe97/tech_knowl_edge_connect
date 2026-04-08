import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/admin/card_header.dart';
import 'package:tech_knowl_edge_connect/services/content/content_admin_service.dart';
import 'package:tech_knowl_edge_connect/components/admin/admin_constants.dart';

class CategoriesCard extends StatelessWidget {
  final ContentAdminService adminService;
  final String? selectedSubjectId;
  final String? selectedCategoryId;
  final String? statusFilter;
  final VoidCallback? onAdd;
  final Function(String id, Map<String, dynamic> data) onEdit;
  final Function(String id) onSelect;
  final Function(String id) onDelete;

  const CategoriesCard({
    super.key,
    required this.adminService,
    required this.selectedSubjectId,
    required this.selectedCategoryId,
    this.statusFilter,
    required this.onAdd,
    required this.onEdit,
    required this.onSelect,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CardHeader(
          title: 'Kategorien',
          onAdd: onAdd,
        ),
        const SizedBox(height: 8),
        if (selectedSubjectId == null)
          const Text('Bitte zuerst ein Fach auswählen.')
        else
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: adminService.streamCategories(selectedSubjectId!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              var docs = snapshot.data?.docs ?? [];
              if (statusFilter != null) {
                docs = docs
                    .where((doc) => doc.data()['status'] == statusFilter)
                    .toList();
              }

              if (docs.isEmpty) {
                return const Text('Keine Kategorien vorhanden.');
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data();
                  final isSelected = doc.id == selectedCategoryId;
                  final cs = Theme.of(context).colorScheme;
                  return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? cs.primaryContainer.withAlpha(76)
                            : cs.surfaceContainer,
                        borderRadius: BorderRadius.circular(24),
                        border: isSelected
                            ? Border.all(color: cs.primary.withAlpha(38))
                            : Border.all(
                                color: cs.outlineVariant.withAlpha(40)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        selected: isSelected,
                        leading: Container(
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
                              Icons.category,
                              color: cs.primary,
                              size: 24,
                            ),
                          ),
                        ),
                        title: Text(data['name'] ?? 'Unbenannt'),
                        subtitle: Text(
                          'Status: ${AdminConstants.statusLabels[data['status']] ?? data['status'] ?? 'Entwurf'} · v${data['version'] ?? 1}',
                        ),
                        onTap: () => onSelect(doc.id),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              style: IconButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12))),
                              icon:
                                  Icon(Icons.edit, color: cs.onSurfaceVariant),
                              tooltip: 'Bearbeiten',
                              onPressed: () => onEdit(doc.id, data),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              style: IconButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12))),
                              icon: Icon(Icons.delete_outline,
                                  color: cs.onSurfaceVariant),
                              tooltip: 'Löschen',
                              onPressed: () => onDelete(doc.id),
                            ),
                          ],
                        ),
                      ));
                },
              );
            },
          ),
      ],
    );
  }
}
