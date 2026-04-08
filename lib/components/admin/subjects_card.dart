import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/admin/card_header.dart';
import 'package:tech_knowl_edge_connect/services/content/content_admin_service.dart';
import 'package:tech_knowl_edge_connect/components/admin/admin_constants.dart';

class SubjectsCard extends StatelessWidget {
  final ContentAdminService adminService;
  final String? selectedSubjectId;
  final String? statusFilter;
  final VoidCallback onAdd;
  final Function(String id, Map<String, dynamic> data) onEdit;
  final Function(String id) onSelect;
  final Function(String id) onDelete;

  const SubjectsCard({
    super.key,
    required this.adminService,
    required this.selectedSubjectId,
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
          title: 'Fächer',
          onAdd: onAdd,
        ),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: adminService.streamSubjects(),
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
              return const Text('Keine Fächer vorhanden.');
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data();
                final isSelected = doc.id == selectedSubjectId;

                IconData? icon;
                if (data['iconData'] != null) {
                  icon = AdminConstants.getIconFromData(
                      data['iconData'] as Map<String, dynamic>);
                }

                Color? color;
                if (data['color'] != null) {
                  color = Color(data['color']);
                }

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
                          : Border.all(color: cs.outlineVariant.withAlpha(40)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                      selected: isSelected,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: (color ?? cs.primary).withAlpha(26),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: cs.outlineVariant.withAlpha(51),
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            icon ?? Icons.folder,
                            color: color ?? cs.primary,
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
                            icon: Icon(Icons.edit, color: cs.onSurfaceVariant),
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
