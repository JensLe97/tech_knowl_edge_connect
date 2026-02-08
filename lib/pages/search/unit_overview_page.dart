import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/components/learning_bite_tile.dart';
import 'package:tech_knowl_edge_connect/components/user/dialogs/concept_dialog.dart';
import 'package:tech_knowl_edge_connect/components/user/dialogs/learning_bite_dialog.dart';
import 'package:tech_knowl_edge_connect/models/concept.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/unit.dart';
import 'package:tech_knowl_edge_connect/pages/search/learning_bite_page.dart';
import 'package:tech_knowl_edge_connect/pages/user/learning_bite_editor_page.dart';
import 'package:tech_knowl_edge_connect/providers/user_provider.dart';
import 'package:tech_knowl_edge_connect/services/content_service.dart';
import 'package:tech_knowl_edge_connect/services/user_service.dart';

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

class _CompletionDialog extends StatefulWidget {
  final String conceptName;

  const _CompletionDialog({
    required this.conceptName,
  });

  @override
  State<_CompletionDialog> createState() => _CompletionDialogState();
}

class _CompletionDialogState extends State<_CompletionDialog> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.05,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 300),
          child: AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: Padding(
              padding: const EdgeInsets.all(12),
              child: Center(
                child: Text(
                  'Du hast alle Lektionen zum Thema ${widget.conceptName} abgeschlossen!',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
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
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await onConfirm();
            },
            child: const Text('Löschen'),
          ),
        ],
      ),
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
                    const EdgeInsetsDirectional.only(top: 10, bottom: 10),
                title: Text(widget.unit.name),
                background: Stack(children: [
                  OverflowBox(
                    maxWidth: 800,
                    maxHeight: 800,
                    child: FaIcon(
                      widget.unit.iconData,
                      size: 50,
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

                      return ListView.builder(
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
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        concept.name,
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      Row(
                                        children: [
                                          if (canDeleteConcept)
                                            IconButton(
                                              icon: const Icon(Icons.edit),
                                              tooltip: 'Konzept bearbeiten',
                                              onPressed: () => showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    ConceptDialog(
                                                  subjectId: widget.subjectId,
                                                  categoryId: widget.categoryId,
                                                  topicId: widget.topicId,
                                                  unitId: widget.unit.id,
                                                  concept: concept,
                                                ),
                                              ),
                                            ),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.add_circle_outline),
                                            onPressed: () => showDialog(
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
                                            tooltip:
                                                'Neues Learning Bite hinzufügen',
                                          ),
                                          if (canDeleteConcept)
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.delete_outline),
                                              tooltip: 'Konzept löschen',
                                              onPressed: () => _confirmDelete(
                                                title: 'Konzept löschen?',
                                                message:
                                                    'Möchtest du dieses Konzept wirklich löschen? Alle Inhalte darunter werden ebenfalls gelöscht.',
                                                onConfirm: () async {
                                                  await _contentService
                                                      .deleteConcept(
                                                    subjectId: widget.subjectId,
                                                    categoryId:
                                                        widget.categoryId,
                                                    topicId: widget.topicId,
                                                    unitId: widget.unit.id,
                                                    conceptId: concept.id,
                                                  );
                                                },
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                SizedBox(
                                  height: 145,
                                  child: StreamBuilder<List<LearningBite>>(
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

                                      return ListView.builder(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        scrollDirection: Axis.horizontal,
                                        itemCount: learningBites.length,
                                        itemBuilder: (BuildContext context,
                                            int learningBiteIndex) {
                                          final learningBite =
                                              learningBites[learningBiteIndex];
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
                                                      builder: (context) =>
                                                          AlertDialog(
                                                        title: const Text(
                                                            'Keine Inhalte verfügbar'),
                                                        content: const Text(
                                                            'Dieser Learning Bite hat noch keine Inhalte oder Aufgaben. Du kannst ihn über den Bearbeiten-Button ergänzen.'),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context),
                                                            child: const Text(
                                                                'Schließen'),
                                                          ),
                                                          if (canEdit)
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            LearningBiteEditorPage(
                                                                      subjectId:
                                                                          widget
                                                                              .subjectId,
                                                                      categoryId:
                                                                          widget
                                                                              .categoryId,
                                                                      topicId:
                                                                          widget
                                                                              .topicId,
                                                                      unitId: widget
                                                                          .unit
                                                                          .id,
                                                                      conceptId:
                                                                          concept
                                                                              .id,
                                                                      learningBiteId:
                                                                          learningBite
                                                                              .id,
                                                                      learningBiteTitle:
                                                                          learningBite
                                                                              .name,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              child: const Text(
                                                                  'Bearbeiten'),
                                                            ),
                                                        ],
                                                      ),
                                                    );
                                                  }
                                                  return;
                                                }

                                                if (context.mounted) {
                                                  await _userService
                                                      .updateResumeStatus(
                                                          widget.subjectId,
                                                          learningBite.id,
                                                          widget.categoryId,
                                                          widget.topicId,
                                                          widget.unit.id,
                                                          concept.id);

                                                  if (!context.mounted) return;

                                                  Navigator.pop(
                                                      context); // Hide loading
                                                  final result =
                                                      await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            LearningBitePage(
                                                              learningBite:
                                                                  learningBite,
                                                              tasks: tasks,
                                                            )),
                                                  );

                                                  if (result == true) {
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
                                                              widget.subjectId);
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
                                                          builder: (context) =>
                                                              _CompletionDialog(
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
                                        },
                                      );
                                    },
                                  ),
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
