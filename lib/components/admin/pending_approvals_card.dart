import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/services/content_admin_service.dart';
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
    return Card(
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ausstehende Genehmigungen',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Icon(Icons.rule, color: Theme.of(context).colorScheme.primary),
              ],
            ),
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

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HierarchyBreadcrumbs(reference: doc.reference),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text('ID: $id\nAuthor: $authorId'),
                              isThreeLine: true,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.visibility),
                                    tooltip: 'Ansehen',
                                    onPressed: () => onPreview(doc),
                                  ),
                                  IconButton(
                                    icon:
                                        const Icon(Icons.check_circle_outline),
                                    color: Colors.green,
                                    tooltip: 'Genehmigen',
                                    onPressed: () =>
                                        _approve(context, doc.reference),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.highlight_off),
                                    color: Colors.red,
                                    tooltip: 'Ablehnen',
                                    onPressed: () =>
                                        _reject(context, doc.reference),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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

  void _approve(BuildContext context, DocumentReference ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Genehmigen?'),
        content:
            const Text('Möchtest du dieses Learning Bite wirklich genehmigen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () {
              adminService.approveLearningBite(ref);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Learning Bite genehmigt.')),
              );
            },
            child: const Text('Genehmigen'),
          ),
        ],
      ),
    );
  }

  void _reject(BuildContext context, DocumentReference ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ablehnen?'),
        content:
            const Text('Möchtest du dieses Learning Bite wirklich ablehnen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              adminService.rejectLearningBite(ref);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Learning Bite abgelehnt.')),
              );
            },
            child: const Text('Ablehnen'),
          ),
        ],
      ),
    );
  }
}
