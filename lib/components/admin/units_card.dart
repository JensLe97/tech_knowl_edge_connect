import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/admin/card_header.dart';
import 'package:tech_knowl_edge_connect/services/content/content_admin_service.dart';
import 'package:tech_knowl_edge_connect/components/admin/admin_constants.dart';

class UnitsCard extends StatelessWidget {
  final ContentAdminService adminService;
  final String? selectedSubjectId;
  final String? selectedCategoryId;
  final String? selectedTopicId;
  final String? selectedUnitId;
  final String? statusFilter;
  final VoidCallback? onAdd;
  final Function(String id, Map<String, dynamic> data) onEdit;
  final Function(String id) onSelect;
  final Function(String id) onDelete;

  const UnitsCard({
    super.key,
    required this.adminService,
    required this.selectedSubjectId,
    required this.selectedCategoryId,
    required this.selectedTopicId,
    required this.selectedUnitId,
    this.statusFilter,
    required this.onAdd,
    required this.onEdit,
    required this.onSelect,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CardHeader(
              title: 'Units',
              onAdd: onAdd,
            ),
            const SizedBox(height: 8),
            if (selectedSubjectId == null ||
                selectedCategoryId == null ||
                selectedTopicId == null)
              const Text('Bitte zuerst ein Topic auswählen.')
            else
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: adminService.streamUnits(
                    selectedSubjectId!, selectedCategoryId!, selectedTopicId!),
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
                    return const Text('Keine Units vorhanden.');
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data();
                      final isSelected = doc.id == selectedUnitId;

                      IconData? icon;
                      if (data['iconData'] != null) {
                        icon = AdminConstants.getIconFromData(
                            data['iconData'] as Map<String, dynamic>);
                      }

                      final cs = Theme.of(context).colorScheme;
                      return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? cs.primaryContainer.withAlpha(76)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(color: cs.primary.withAlpha(38))
                                : Border.all(
                                    color: cs.outlineVariant.withAlpha(38)),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 4),
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
                                  icon ?? Icons.folder_open,
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
                                          borderRadius:
                                              BorderRadius.circular(12))),
                                  icon: Icon(Icons.edit,
                                      color: cs.onSurfaceVariant),
                                  tooltip: 'Bearbeiten',
                                  onPressed: () => onEdit(doc.id, data),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  style: IconButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12))),
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
        ),
      ),
    );
  }
}
