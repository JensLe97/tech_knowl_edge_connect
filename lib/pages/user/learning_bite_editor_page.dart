import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/admin/ai_authoring_card.dart';
import 'package:tech_knowl_edge_connect/components/admin/content_card.dart';
import 'package:tech_knowl_edge_connect/components/admin/card_header.dart';
import 'package:tech_knowl_edge_connect/components/admin/dialogs/content_dialog.dart';
import 'package:tech_knowl_edge_connect/components/admin/dialogs/task_dialog.dart';
import 'package:tech_knowl_edge_connect/components/admin/tasks_card.dart';
import 'package:tech_knowl_edge_connect/components/buttons/dialog_button.dart';
import 'package:tech_knowl_edge_connect/components/user/dialogs/learning_bite_dialog.dart';
import 'package:tech_knowl_edge_connect/components/user/user_constants.dart';
import 'package:tech_knowl_edge_connect/models/learning/learning_bite.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/ai_tech_gen_service.dart';
import 'package:tech_knowl_edge_connect/services/content/content_admin_service.dart';
import 'package:tech_knowl_edge_connect/services/content/content_service.dart';

class LearningBiteEditorPage extends StatefulWidget {
  final String subjectId;
  final String categoryId;
  final String topicId;
  final String unitId;
  final String conceptId;
  final String learningBiteId;
  final String? learningBiteTitle;

  const LearningBiteEditorPage({
    super.key,
    required this.subjectId,
    required this.categoryId,
    required this.topicId,
    required this.unitId,
    required this.conceptId,
    required this.learningBiteId,
    this.learningBiteTitle,
  });

  @override
  State<LearningBiteEditorPage> createState() => _LearningBiteEditorPageState();
}

class _LearningBiteEditorPageState extends State<LearningBiteEditorPage> {
  final ContentAdminService _adminService = ContentAdminService();
  final ContentService _contentService = ContentService();
  final AiTechGenService _aiTechGenService = AiTechGenService();

  Future<void> _markNeedsPublish() async {
    await _adminService.updateLearningBite(
      subjectId: widget.subjectId,
      categoryId: widget.categoryId,
      topicId: widget.topicId,
      unitId: widget.unitId,
      conceptId: widget.conceptId,
      learningBiteId: widget.learningBiteId,
      data: {
        'status': UserConstants.statusPrivate,
      },
    );
  }

  Future<void> _openContentDialog({
    int? index,
    String? initialContent,
    List<String>? allContent,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => ContentDialog(
        adminService: _adminService,
        subjectId: widget.subjectId,
        categoryId: widget.categoryId,
        topicId: widget.topicId,
        unitId: widget.unitId,
        conceptId: widget.conceptId,
        learningBiteId: widget.learningBiteId,
        index: index,
        initialContent: initialContent,
        allContent: allContent,
        onAfterSave: _markNeedsPublish,
      ),
    );
  }

  Future<void> _openTaskDialog({
    String? taskId,
    Map<String, dynamic>? existing,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => TaskDialog(
        adminService: _adminService,
        subjectId: widget.subjectId,
        categoryId: widget.categoryId,
        topicId: widget.topicId,
        unitId: widget.unitId,
        conceptId: widget.conceptId,
        learningBiteId: widget.learningBiteId,
        taskId: taskId,
        existingData: existing,
        onAfterSave: _markNeedsPublish,
      ),
    );
  }

  Future<void> _openMetadataDialog(LearningBite bite) async {
    await showDialog(
      context: context,
      builder: (context) => LearningBiteDialog(
        subjectId: widget.subjectId,
        categoryId: widget.categoryId,
        topicId: widget.topicId,
        unitId: widget.unitId,
        conceptId: widget.conceptId,
        learningBite: bite,
      ),
    );
  }

  Widget _buildStatusPill(BuildContext context, String status) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bgColor;
    Color textColor;
    Color borderColor;

    switch (status) {
      case UserConstants.statusApproved:
        bgColor = Colors.green.withAlpha(38); // 15% opacity
        textColor = isDark ? Colors.green.shade300 : Colors.green.shade700;
        borderColor = Colors.green.withAlpha(76); // 30% opacity
        break;
      case UserConstants.statusRejected:
        bgColor = cs.errorContainer;
        textColor = cs.onErrorContainer;
        borderColor = cs.error.withAlpha(76);
        break;
      case UserConstants.statusPending:
        bgColor = Colors.orange.withAlpha(38);
        textColor = isDark ? Colors.orange.shade300 : Colors.orange.shade800;
        borderColor = Colors.orange.withAlpha(76);
        break;
      default: // statusPrivate or draft
        bgColor = cs.surfaceContainerHighest;
        textColor = cs.onSurfaceVariant;
        borderColor = cs.outlineVariant.withAlpha(128);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        UserConstants.statusLabels[status] ?? status,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Future<void> _confirmDelete({
    required String title,
    required String message,
    required Future<void> Function() onConfirm,
  }) async {
    await showDialog(
      context: context,
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return AlertDialog(
          icon: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.errorContainer.withAlpha(76),
              shape: BoxShape.circle,
              border: Border.all(
                color: cs.error.withAlpha(25),
              ),
            ),
            child: Icon(
              Icons.delete_outline_rounded,
              size: 32,
              color: cs.error,
            ),
          ),
          title: Text(title, textAlign: TextAlign.center),
          content: Text(message, textAlign: TextAlign.center),
          actions: [
            Row(
              children: [
                DialogButton(
                  onTap: () => Navigator.pop(context),
                  text: 'Abbrechen',
                ),
                DialogButton(
                  onTap: () async {
                    Navigator.pop(context);
                    await onConfirm();
                  },
                  text: 'Löschen',
                  isDestructive: true,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder(
      stream: _adminService.streamLearningBite(
        widget.subjectId,
        widget.categoryId,
        widget.topicId,
        widget.unitId,
        widget.conceptId,
        widget.learningBiteId,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final data = snapshot.data?.data();
        if (data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text("Fehler")),
            body: const Center(child: Text('Learning Bite nicht gefunden.')),
          );
        }

        final learningBite = LearningBite.fromMap(data, widget.learningBiteId);
        final status = learningBite.status;
        final authorId = learningBite.authorId;

        if (user == null || authorId == null || authorId != user.uid) {
          return Scaffold(
              appBar: AppBar(title: const Text("Zugriff verweigert")),
              body: const Center(
                  child: Text(
                      'Du kannst nur deine eigenen Learning Bites bearbeiten.')));
        }

        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(learningBite.iconData, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    learningBite.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Details bearbeiten',
                onPressed: () => _openMetadataDialog(learningBite),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                tooltip: 'Learning Bite löschen',
                onPressed: () => _confirmDelete(
                  title: 'Learning Bite löschen?',
                  message:
                      'Möchtest du dieses Learning Bite wirklich löschen? Alle Inhalte und Aufgaben werden ebenfalls gelöscht.',
                  onConfirm: () async {
                    await _contentService.deleteLearningBite(
                      subjectId: widget.subjectId,
                      categoryId: widget.categoryId,
                      topicId: widget.topicId,
                      unitId: widget.unitId,
                      conceptId: widget.conceptId,
                      learningBiteId: widget.learningBiteId,
                    );
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ),
            ],
            centerTitle: true,
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildStatusPill(context, status),
                        const Spacer(),
                        if (status == UserConstants.statusPrivate ||
                            status == UserConstants.statusRejected)
                          ElevatedButton(
                            onPressed: () async {
                              await _adminService.updateLearningBite(
                                subjectId: widget.subjectId,
                                categoryId: widget.categoryId,
                                topicId: widget.topicId,
                                unitId: widget.unitId,
                                conceptId: widget.conceptId,
                                learningBiteId: widget.learningBiteId,
                                data: {
                                  'status': UserConstants.statusPending,
                                },
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Learning Bite zur Prüfung eingereicht.'),
                                  ),
                                );
                              }
                            },
                            child: const Text('Veröffentlichen'),
                          ),
                        if (status == UserConstants.statusPending ||
                            status == UserConstants.statusApproved)
                          TextButton(
                            onPressed: () async {
                              await _markNeedsPublish();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Learning Bite auf Entwurf gesetzt.'),
                                  ),
                                );
                              }
                            },
                            child: const Text('Auf privat setzen'),
                          ),
                      ],
                    ),
                    if (status == UserConstants.statusPending) ...[
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Ein Admin prüft derzeit dieses Learning Bite sowie das übergeordnete Konzept, die Einheit, das Thema, die Kategorie und das Fach.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    const CardHeader(title: 'Datei-Upload & KI-Generierung'),
                    const SizedBox(height: 12),
                    AiAuthoringCard(
                      userId: user.uid,
                      adminService: _adminService,
                      aiTechGenService: _aiTechGenService,
                      selectedSubjectId: widget.subjectId,
                      selectedCategoryId: widget.categoryId,
                      selectedTopicId: widget.topicId,
                      selectedUnitId: widget.unitId,
                      selectedConceptId: widget.conceptId,
                      selectedLearningBiteId: widget.learningBiteId,
                      selectedLearningBiteData: data,
                      onUpdate: () async {
                        await _markNeedsPublish();
                        if (mounted) setState(() {});
                      },
                    ),
                    const SizedBox(height: 32),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ContentCard(
                              adminService: _adminService,
                              selectedSubjectId: widget.subjectId,
                              selectedCategoryId: widget.categoryId,
                              selectedTopicId: widget.topicId,
                              selectedUnitId: widget.unitId,
                              selectedConceptId: widget.conceptId,
                              selectedLearningBiteId: widget.learningBiteId,
                              onAdd: () => _openContentDialog(),
                              onEdit: (index, content, allContent) =>
                                  _openContentDialog(
                                index: index,
                                initialContent: content,
                                allContent: allContent,
                              ),
                              onDelete: (index, allContent) => _confirmDelete(
                                title: 'Inhalt löschen?',
                                message:
                                    'Möchtest du diesen Inhaltsteil wirklich löschen?',
                                onConfirm: () async {
                                  allContent.removeAt(index);
                                  await _adminService.updateLearningBite(
                                    subjectId: widget.subjectId,
                                    categoryId: widget.categoryId,
                                    topicId: widget.topicId,
                                    unitId: widget.unitId,
                                    conceptId: widget.conceptId,
                                    learningBiteId: widget.learningBiteId,
                                    data: {
                                      'content': allContent,
                                      'status': UserConstants.statusPrivate,
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TasksCard(
                              adminService: _adminService,
                              selectedSubjectId: widget.subjectId,
                              selectedCategoryId: widget.categoryId,
                              selectedTopicId: widget.topicId,
                              selectedUnitId: widget.unitId,
                              selectedConceptId: widget.conceptId,
                              selectedLearningBiteId: widget.learningBiteId,
                              onAdd: () => _openTaskDialog(),
                              onEdit: (id, data) =>
                                  _openTaskDialog(taskId: id, existing: data),
                              onDelete: (id) => _confirmDelete(
                                title: 'Aufgabe löschen?',
                                message:
                                    'Möchtest du diese Aufgabe wirklich löschen?',
                                onConfirm: () async {
                                  await _adminService.deleteTask(
                                    subjectId: widget.subjectId,
                                    categoryId: widget.categoryId,
                                    topicId: widget.topicId,
                                    unitId: widget.unitId,
                                    conceptId: widget.conceptId,
                                    learningBiteId: widget.learningBiteId,
                                    taskId: id,
                                  );
                                  await _markNeedsPublish();
                                },
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ContentCard(
                            adminService: _adminService,
                            selectedSubjectId: widget.subjectId,
                            selectedCategoryId: widget.categoryId,
                            selectedTopicId: widget.topicId,
                            selectedUnitId: widget.unitId,
                            selectedConceptId: widget.conceptId,
                            selectedLearningBiteId: widget.learningBiteId,
                            onAdd: () => _openContentDialog(),
                            onEdit: (index, content, allContent) =>
                                _openContentDialog(
                              index: index,
                              initialContent: content,
                              allContent: allContent,
                            ),
                            onDelete: (index, allContent) => _confirmDelete(
                              title: 'Inhalt löschen?',
                              message:
                                  'Möchtest du diesen Inhaltsteil wirklich löschen?',
                              onConfirm: () async {
                                allContent.removeAt(index);
                                await _adminService.updateLearningBite(
                                  subjectId: widget.subjectId,
                                  categoryId: widget.categoryId,
                                  topicId: widget.topicId,
                                  unitId: widget.unitId,
                                  conceptId: widget.conceptId,
                                  learningBiteId: widget.learningBiteId,
                                  data: {
                                    'content': allContent,
                                    'status': UserConstants.statusPrivate,
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                          TasksCard(
                            adminService: _adminService,
                            selectedSubjectId: widget.subjectId,
                            selectedCategoryId: widget.categoryId,
                            selectedTopicId: widget.topicId,
                            selectedUnitId: widget.unitId,
                            selectedConceptId: widget.conceptId,
                            selectedLearningBiteId: widget.learningBiteId,
                            onAdd: () => _openTaskDialog(),
                            onEdit: (id, data) =>
                                _openTaskDialog(taskId: id, existing: data),
                            onDelete: (id) => _confirmDelete(
                              title: 'Aufgabe löschen?',
                              message:
                                  'Möchtest du diese Aufgabe wirklich löschen?',
                              onConfirm: () async {
                                await _adminService.deleteTask(
                                  subjectId: widget.subjectId,
                                  categoryId: widget.categoryId,
                                  topicId: widget.topicId,
                                  unitId: widget.unitId,
                                  conceptId: widget.conceptId,
                                  learningBiteId: widget.learningBiteId,
                                  taskId: id,
                                );
                                await _markNeedsPublish();
                              },
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
