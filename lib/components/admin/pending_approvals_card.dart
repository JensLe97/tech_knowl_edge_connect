import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/admin/card_header.dart';
import 'package:tech_knowl_edge_connect/components/admin/dialogs/confirm_action_dialog.dart';
import 'package:tech_knowl_edge_connect/services/content/content_admin_service.dart';
import 'package:tech_knowl_edge_connect/components/admin/hierarchy_breadcrumbs.dart';

class PendingApprovalsCard extends StatelessWidget {
  final ContentAdminService adminService;
  final Function(DocumentSnapshot doc) onPreview;

  const PendingApprovalsCard({
    super.key,
    required this.adminService,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CardHeader(title: 'Ausstehende Genehmigungen'),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: adminService.streamPendingLearningBites(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Fehler: ${snapshot.error}');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Keine ausstehenden Genehmigungen.'),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data();
                final id = doc.id;
                final title = data['title'] ?? 'Ohne Titel';
                final authorId = data['authorId'] ?? 'Unbekannt';

                final cs = Theme.of(context).colorScheme;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainer,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: cs.outlineVariant.withAlpha(40)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HierarchyBreadcrumbs(reference: doc.reference),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        title: Text(title,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('ID: $id\nAuthor: $authorId'),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              style: IconButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12))),
                              icon: Icon(Icons.visibility,
                                  color: cs.onSurfaceVariant),
                              tooltip: 'Ansehen',
                              onPressed: () => onPreview(doc),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              style: IconButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12))),
                              icon: const Icon(Icons.check_circle_outline,
                                  color: Colors.green),
                              tooltip: 'Genehmigen',
                              onPressed: () => _approve(context, doc.reference),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              style: IconButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12))),
                              icon: const Icon(Icons.highlight_off,
                                  color: Colors.red),
                              tooltip: 'Ablehnen',
                              onPressed: () => _reject(context, doc.reference),
                            ),
                          ],
                        ),
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

  void _approve(BuildContext context, DocumentReference ref) {
    showDialog(
      context: context,
      builder: (context) => ConfirmActionDialog(
        title: 'Genehmigen?',
        message: 'Möchtest du dieses Learning Bite wirklich genehmigen?',
        icon: Icons.check_circle_outline,
        actionColor: Colors.green,
        actionContainerColor: Colors.green.withAlpha(100),
        actionText: 'Genehmigen',
        onConfirm: () {
          adminService.approveLearningBite(ref);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Learning Bite genehmigt.')),
          );
        },
      ),
    );
  }

  void _reject(BuildContext context, DocumentReference ref) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => ConfirmActionDialog(
        title: 'Ablehnen?',
        message: 'Möchtest du dieses Learning Bite wirklich ablehnen?',
        icon: Icons.highlight_off,
        actionColor: cs.error,
        actionContainerColor: cs.errorContainer,
        actionText: 'Ablehnen',
        isDestructive: true,
        onConfirm: () {
          adminService.rejectLearningBite(ref);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Learning Bite abgelehnt.')),
          );
        },
      ),
    );
  }
}
