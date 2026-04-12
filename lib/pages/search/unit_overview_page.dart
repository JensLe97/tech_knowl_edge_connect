import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/tiles/learning_bite_tile.dart';
import 'package:tech_knowl_edge_connect/components/user/dialogs/concept_dialog.dart';
import 'package:tech_knowl_edge_connect/components/user/dialogs/learning_bite_dialog.dart';
import 'package:tech_knowl_edge_connect/components/dialogs/completion_dialog.dart';
import 'package:tech_knowl_edge_connect/components/buttons/dialog_button.dart';
import 'package:tech_knowl_edge_connect/models/content/concept.dart';
import 'package:tech_knowl_edge_connect/models/learning/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/learning/learning_bite_result.dart';
import 'package:tech_knowl_edge_connect/models/content/unit.dart';
import 'package:tech_knowl_edge_connect/pages/search/learning_bite_page.dart';
import 'package:tech_knowl_edge_connect/pages/user/learning_bite_editor_page.dart';
import 'package:tech_knowl_edge_connect/providers/user_provider.dart';
import 'package:tech_knowl_edge_connect/services/content/content_service.dart';
import 'package:tech_knowl_edge_connect/services/user/user_service.dart';

class UnitOverviewPage extends StatefulWidget {
  final String subjectId;
  final String categoryId;
  final String topicId;
  final Unit unit;

  const UnitOverviewPage({
    super.key,
    required this.subjectId,
    required this.categoryId,
    required this.topicId,
    required this.unit,
  });

  @override
  State<UnitOverviewPage> createState() => _UnitOverviewPageState();
}

class _UnitOverviewPageState extends State<UnitOverviewPage> {
  final ContentService _contentService = ContentService();
  final UserService _userService = UserService();

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
              Icons.delete_outline,
              size: 32,
              color: cs.error,
            ),
          ),
          title: Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              )),
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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = UserState.of(context);
    final currentUser = FirebaseAuth.instance.currentUser;
    final completedLearningBiteIds = userState?.userData != null &&
            userState!.userData!.containsKey('completedLearningBiteIds')
        ? List<String>.from(userState.userData!['completedLearningBiteIds'])
        : <String>[];

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        floatingActionButton: FloatingActionButton(
          heroTag: 'unit_overview_fab',
          onPressed: () => showDialog(
            context: context,
            builder: (context) => ConceptDialog(
              subjectId: widget.subjectId,
              categoryId: widget.categoryId,
              topicId: widget.topicId,
              unitId: widget.unit.id,
            ),
          ),
          child: const Icon(Icons.add),
        ),
        body: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              elevation: 0,
              shadowColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding:
                    const EdgeInsetsDirectional.only(top: 10, bottom: 15),
                title: Text(
                  widget.unit.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                background: Stack(children: [
                  OverflowBox(
                    maxWidth: 800,
                    maxHeight: 800,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withAlpha(26),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .outlineVariant
                                .withAlpha(51),
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            widget.unit.iconData,
                            color: Theme.of(context).colorScheme.primary,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
                centerTitle: true,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: StreamBuilder<List<Concept>>(
                    stream: _contentService.getConcepts(widget.subjectId,
                        widget.categoryId, widget.topicId, widget.unit.id),
                    builder: (context, conceptSnapshot) {
                      if (!conceptSnapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final concepts = conceptSnapshot.data!;

                      if (concepts.isEmpty) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Center(
                              child: Text(
                                "Zu dieser Einheit gibt es noch keine Konzepte",
                                style: TextStyle(fontSize: 20),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                          padding: EdgeInsets.zero,
                          physics: const ClampingScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: concepts.length,
                          itemBuilder:
                              (BuildContext context, int conceptIndex) {
                            final concept = concepts[conceptIndex];
                            final canDeleteConcept = currentUser != null &&
                                concept.authorId == currentUser.uid;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        concept.name,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                      ),
                                      Container(
                                        color: Colors.transparent,
                                        child: Row(
                                          children: [
                                            if (canDeleteConcept)
                                              InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                onTap: () => _confirmDelete(
                                                  title: 'Konzept löschen?',
                                                  message:
                                                      'Möchtest du dieses Konzept wirklich löschen? Alle Inhalte darunter werden ebenfalls gelöscht.',
                                                  onConfirm: () async {
                                                    await _contentService
                                                        .deleteConcept(
                                                      subjectId:
                                                          widget.subjectId,
                                                      categoryId:
                                                          widget.categoryId,
                                                      topicId: widget.topicId,
                                                      unitId: widget.unit.id,
                                                      conceptId: concept.id,
                                                    );
                                                  },
                                                ),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primaryContainer
                                                        .withAlpha(76),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    border: Border.all(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary
                                                          .withAlpha(25),
                                                    ),
                                                  ),
                                                  child: Icon(
                                                      Icons.delete_outline,
                                                      size: 24,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary),
                                                ),
                                              ),
                                            if (canDeleteConcept)
                                              const SizedBox(width: 8),
                                            if (canDeleteConcept)
                                              InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                onTap: () => showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      ConceptDialog(
                                                    subjectId: widget.subjectId,
                                                    categoryId:
                                                        widget.categoryId,
                                                    topicId: widget.topicId,
                                                    unitId: widget.unit.id,
                                                    concept: concept,
                                                  ),
                                                ),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primaryContainer
                                                        .withAlpha(76),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    border: Border.all(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary
                                                          .withAlpha(25),
                                                    ),
                                                  ),
                                                  child: Icon(Icons.edit,
                                                      size: 24,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary),
                                                ),
                                              ),
                                            if (canDeleteConcept)
                                              const SizedBox(width: 8),
                                            InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              onTap: () => showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    LearningBiteDialog(
                                                  subjectId: widget.subjectId,
                                                  categoryId: widget.categoryId,
                                                  topicId: widget.topicId,
                                                  unitId: widget.unit.id,
                                                  conceptId: concept.id,
                                                ),
                                              ),
                                              child: Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primaryContainer
                                                      .withAlpha(76),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                        .withAlpha(25),
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Icon(Icons.add,
                                                      size: 24,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                StreamBuilder<List<LearningBite>>(
                                  stream: _contentService.getLearningBites(
                                      widget.subjectId,
                                      widget.categoryId,
                                      widget.topicId,
                                      widget.unit.id,
                                      concept.id),
                                  builder: (context, lbSnapshot) {
                                    if (!lbSnapshot.hasData) {
                                      return const SizedBox.shrink();
                                    }
                                    final learningBites = lbSnapshot.data!;

                                    return SingleChildScrollView(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: learningBites
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                          final learningBiteIndex = entry.key;
                                          final learningBite = entry.value;
                                          final isCompleted =
                                              completedLearningBiteIds
                                                  .contains(learningBite.id);
                                          final currentUser =
                                              FirebaseAuth.instance.currentUser;
                                          final canEdit = currentUser != null &&
                                              learningBite.authorId ==
                                                  currentUser.uid;

                                          return LearningBiteTile(
                                            learningBite: learningBite,
                                            onTap: () async {
                                              // Show loading
                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (context) => const Center(
                                                    child:
                                                        CircularProgressIndicator()),
                                              );

                                              try {
                                                final tasks =
                                                    await _contentService
                                                        .getTasks(
                                                            widget.subjectId,
                                                            widget.categoryId,
                                                            widget.topicId,
                                                            widget.unit.id,
                                                            concept.id,
                                                            learningBite.id);

                                                final hasContent = learningBite
                                                    .content.isNotEmpty;
                                                final hasTasks =
                                                    tasks.isNotEmpty;

                                                if (!hasContent && !hasTasks) {
                                                  if (context.mounted) {
                                                    Navigator.pop(
                                                        context); // Hide loading
                                                    await showDialog(
                                                      context: context,
                                                      builder: (dialogCtx) {
                                                        final cs =
                                                            Theme.of(dialogCtx)
                                                                .colorScheme;
                                                        return AlertDialog(
                                                          icon: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(16),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: cs
                                                                  .secondaryContainer
                                                                  .withAlpha(
                                                                      76),
                                                              shape: BoxShape
                                                                  .circle,
                                                              border:
                                                                  Border.all(
                                                                color: cs
                                                                    .secondary
                                                                    .withAlpha(
                                                                        25),
                                                              ),
                                                            ),
                                                            child: Icon(
                                                              Icons
                                                                  .info_outline,
                                                              size: 32,
                                                              color:
                                                                  cs.secondary,
                                                            ),
                                                          ),
                                                          title: const Text(
                                                            'Keine Inhalte verfügbar',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          content: const Text(
                                                            'Dieses Learning Bite hat noch keine Inhalte oder Aufgaben. Du kannst sie über den Bearbeiten-Button hinzufügen.',
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                          actions: [
                                                            Row(
                                                              children: [
                                                                DialogButton(
                                                                  onTap: () =>
                                                                      Navigator.pop(
                                                                          dialogCtx),
                                                                  text:
                                                                      'Schließen',
                                                                ),
                                                                if (canEdit)
                                                                  DialogButton(
                                                                    onTap:
                                                                        () async {
                                                                      Navigator.pop(
                                                                          dialogCtx);
                                                                      Navigator
                                                                          .push(
                                                                        dialogCtx,
                                                                        MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              LearningBiteEditorPage(
                                                                            subjectId:
                                                                                widget.subjectId,
                                                                            categoryId:
                                                                                widget.categoryId,
                                                                            topicId:
                                                                                widget.topicId,
                                                                            unitId:
                                                                                widget.unit.id,
                                                                            conceptId:
                                                                                concept.id,
                                                                            learningBiteId:
                                                                                learningBite.id,
                                                                            learningBiteTitle:
                                                                                learningBite.name,
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                    text:
                                                                        'Bearbeiten',
                                                                  ),
                                                              ],
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  }
                                                  return;
                                                }

                                                if (context.mounted) {
                                                  // Attach bite to user's progress (create unit entry if missing)
                                                  try {
                                                    final userId = FirebaseAuth
                                                        .instance
                                                        .currentUser
                                                        ?.uid;
                                                    if (userId != null) {
                                                      await _contentService
                                                          .startLearningBiteForUser(
                                                              userId: userId,
                                                              subjectId: widget
                                                                  .subjectId,
                                                              categoryId: widget
                                                                  .categoryId,
                                                              topicId: widget
                                                                  .topicId,
                                                              unitId: widget
                                                                  .unit.id,
                                                              conceptId:
                                                                  concept.id,
                                                              learningBiteId:
                                                                  learningBite
                                                                      .id);
                                                    }
                                                  } catch (_) {}

                                                  await _userService
                                                      .updateResumeStatus(
                                                          widget.subjectId,
                                                          learningBite.id,
                                                          widget.categoryId,
                                                          widget.topicId,
                                                          widget.unit.id,
                                                          concept.id);

                                                  if (!context.mounted) {
                                                    return;
                                                  }

                                                  Navigator.pop(
                                                      context); // Hide loading
                                                  final result = await Navigator
                                                      .push<LearningBiteResult>(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            LearningBitePage(
                                                              learningBite:
                                                                  learningBite,
                                                              tasks: tasks,
                                                            )),
                                                  );

                                                  if (result != null &&
                                                      result.completed) {
                                                    final allCompletedBefore =
                                                        learningBites.every((lb) =>
                                                            completedLearningBiteIds
                                                                .contains(
                                                                    lb.id));
                                                    await _userService
                                                        .markLearningBiteComplete(
                                                            learningBite.id);

                                                    if (learningBiteIndex <
                                                        learningBites.length -
                                                            1) {
                                                      final nextLB =
                                                          learningBites[
                                                              learningBiteIndex +
                                                                  1];
                                                      await _userService
                                                          .updateResumeStatus(
                                                              widget.subjectId,
                                                              nextLB.id,
                                                              widget.categoryId,
                                                              widget.topicId,
                                                              widget.unit.id,
                                                              concept.id);
                                                    } else {
                                                      await _userService
                                                          .removeResumeStatus(
                                                              learningBite.id);
                                                    }

                                                    if (context.mounted) {
                                                      final allCompleted =
                                                          learningBites.every((lb) =>
                                                              lb.id ==
                                                                  learningBite
                                                                      .id ||
                                                              completedLearningBiteIds
                                                                  .contains(
                                                                      lb.id));

                                                      if (allCompleted &&
                                                          !allCompletedBefore) {
                                                        showDialog(
                                                          context: context,
                                                          builder:
                                                              (dialogContext) =>
                                                                  CompletionDialog(
                                                            conceptName:
                                                                concept.name,
                                                          ),
                                                        );
                                                      }
                                                    }
                                                  }
                                                }
                                              } catch (e) {
                                                if (context.mounted) {
                                                  Navigator.pop(
                                                      context); // Hide loading
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                          content: Text(
                                                              'Error loading tasks: $e')));
                                                }
                                              }
                                            },
                                            onEdit: canEdit
                                                ? () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            LearningBiteEditorPage(
                                                          subjectId:
                                                              widget.subjectId,
                                                          categoryId:
                                                              widget.categoryId,
                                                          topicId:
                                                              widget.topicId,
                                                          unitId:
                                                              widget.unit.id,
                                                          conceptId: concept.id,
                                                          learningBiteId:
                                                              learningBite.id,
                                                          learningBiteTitle:
                                                              learningBite.name,
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                : null,
                                            completed: isCompleted,
                                          );
                                        }).toList(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            );
                          });
                    }),
              ),
            )
          ],
        ));
  }
}
