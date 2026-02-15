import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/admin/card_header.dart';
import 'package:tech_knowl_edge_connect/services/content_admin_service.dart';
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const Divider(),
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

                    return ListTile(
                      selected: isSelected,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      leading: CircleAvatar(
                        backgroundColor:
                            color ?? Theme.of(context).primaryColor,
                        child: Icon(
                          icon ?? Icons.folder,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(data['name'] ?? 'Unbenannt'),
                      subtitle: Text(
                        'Status: ${AdminConstants.statusLabels[data['status']] ?? data['status'] ?? 'Draft'} · v${data['version'] ?? 1}',
                      ),
                      onTap: () => onSelect(doc.id),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            tooltip: 'Bearbeiten',
                            onPressed: () => onEdit(doc.id, data),
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: 'Löschen',
                            onPressed: () => onDelete(doc.id),
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
