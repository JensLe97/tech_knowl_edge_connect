import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/admin/card_header.dart';
import 'package:tech_knowl_edge_connect/services/content_admin_service.dart';
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
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data();
                      final isSelected = doc.id == selectedUnitId;

                      IconData? icon;
                      if (data['iconData'] != null) {
                        final map = data['iconData'];
                        icon = IconData(
                          map['codePoint'],
                          fontFamily: map['fontFamily'],
                          fontPackage: map['fontPackage'],
                        );
                      }

                      return ListTile(
                        selected: isSelected,
                        leading: CircleAvatar(
                          child: Icon(icon ?? Icons.folder_open),
                        ),
                        title: Text(data['name'] ?? 'Unbenannt'),
                        subtitle: Text(
                          'Status: ${AdminConstants.statusLabels[data['status']] ?? data['status'] ?? 'Draft'} · v${data['version'] ?? 1}',
                        ),
                        onTap: () => onSelect(doc.id),
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: 'Bearbeiten',
                              onPressed: () => onEdit(doc.id, data),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              tooltip: 'Löschen',
                              onPressed: () => onDelete(doc.id),
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
