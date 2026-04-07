import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/services/content/content_admin_service.dart';
import 'package:tech_knowl_edge_connect/components/buttons/dialog_button.dart';

class ContentDialog extends StatefulWidget {
  final ContentAdminService adminService;
  final String subjectId;
  final String categoryId;
  final String topicId;
  final String unitId;
  final String conceptId;
  final String learningBiteId;
  final int? index;
  final String? initialContent;
  final List<String>? allContent;
  final Future<void> Function()? onAfterSave;

  const ContentDialog({
    super.key,
    required this.adminService,
    required this.subjectId,
    required this.categoryId,
    required this.topicId,
    required this.unitId,
    required this.conceptId,
    required this.learningBiteId,
    this.index,
    this.initialContent,
    this.allContent,
    this.onAfterSave,
  });

  @override
  State<ContentDialog> createState() => _ContentDialogState();
}

class _ContentDialogState extends State<ContentDialog> {
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _contentController =
        TextEditingController(text: widget.initialContent ?? '');
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.description,
          size: 32,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        widget.index == null
            ? 'Inhaltsteil hinzufügen'
            : 'Inhaltsteil bearbeiten',
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Inhalt (Text)',
                border: OutlineInputBorder(),
                hintText: 'Hier den Lerninhalt eingeben...',
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            DialogButton(
              text: 'Abbrechen',
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(width: 8),
            DialogButton(
              text: 'Speichern',
              onTap: () async {
                if (_contentController.text.trim().isEmpty) return;

                try {
                  // If creating new, we need to fetch current list if not provided
                  List<String> currentContent = widget.allContent != null
                      ? List<String>.from(widget.allContent!)
                      : [];

                  if (widget.allContent == null) {
                    final snapshot = await widget.adminService
                        .streamLearningBite(
                          widget.subjectId,
                          widget.categoryId,
                          widget.topicId,
                          widget.unitId,
                          widget.conceptId,
                          widget.learningBiteId,
                        )
                        .first;
                    currentContent =
                        List<String>.from(snapshot.data()?['content'] ?? []);
                  }

                  if (widget.index == null) {
                    // Add new
                    currentContent.add(_contentController.text.trim());
                  } else {
                    // Update existing
                    if (widget.index! < currentContent.length) {
                      currentContent[widget.index!] =
                          _contentController.text.trim();
                    }
                  }

                  await widget.adminService.updateLearningBite(
                    subjectId: widget.subjectId,
                    categoryId: widget.categoryId,
                    topicId: widget.topicId,
                    unitId: widget.unitId,
                    conceptId: widget.conceptId,
                    learningBiteId: widget.learningBiteId,
                    data: {'content': currentContent},
                  );

                  if (widget.onAfterSave != null) {
                    await widget.onAfterSave!();
                  }

                  if (!context.mounted) return;
                  Navigator.pop(context);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Fehler: $e')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
