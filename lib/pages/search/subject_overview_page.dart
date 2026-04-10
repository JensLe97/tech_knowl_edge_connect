import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/buttons/dialog_button.dart';
import 'package:tech_knowl_edge_connect/components/tiles/unit_tile.dart';
import 'package:tech_knowl_edge_connect/components/user/dialogs/category_dialog.dart';
import 'package:tech_knowl_edge_connect/components/user/dialogs/subject_dialog.dart';
import 'package:tech_knowl_edge_connect/components/user/dialogs/topic_dialog.dart';
import 'package:tech_knowl_edge_connect/components/user/dialogs/unit_dialog.dart';
import 'package:tech_knowl_edge_connect/models/content/category.dart';
import 'package:tech_knowl_edge_connect/models/content/subject.dart';
import 'package:tech_knowl_edge_connect/models/content/topic.dart';
import 'package:tech_knowl_edge_connect/models/content/unit.dart';
import 'package:tech_knowl_edge_connect/pages/search/unit_overview_page.dart';
import 'package:tech_knowl_edge_connect/services/content/content_service.dart';

class SubjectOverviewPage extends StatefulWidget {
  final Subject subject;
  const SubjectOverviewPage({
    super.key,
    required this.subject,
  });

  @override
  State<SubjectOverviewPage> createState() => _SubjectOverviewPageState();
}

class _SubjectOverviewPageState extends State<SubjectOverviewPage> {
  final ContentService _contentService = ContentService();

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
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('content_subjects')
          .doc(widget.subject.id)
          .snapshots(),
      builder: (context, snapshot) {
        Subject currentSubject = widget.subject;
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.data() != null) {
          currentSubject =
              Subject.fromMap(snapshot.data!.data()!, snapshot.data!.id);
        }
        return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            floatingActionButton: FloatingActionButton(
              heroTag: 'subject_overview_fab',
              onPressed: () => showDialog(
                context: context,
                builder: (context) => CategoryDialog(
                  subjectId: currentSubject.id,
                ),
              ),
              child: const Icon(Icons.add),
            ),
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 144,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  actions: [
                    if (currentUser != null &&
                        currentSubject.authorId == currentUser.uid) ...[
                      Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => showDialog(
                                context: context,
                                builder: (context) => SubjectDialog(
                                  subject: currentSubject,
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
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withAlpha(25),
                                  ),
                                ),
                                child: Center(
                                  child: Icon(Icons.edit,
                                      size: 24,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _confirmDelete(
                                title: 'Fach löschen?',
                                message:
                                    'Möchtest du dieses Fach wirklich löschen? Alle Inhalte darunter werden ebenfalls gelöscht.',
                                onConfirm: () async {
                                  await _contentService.deleteSubject(
                                    subjectId: currentSubject.id,
                                  );
                                  if (context.mounted) Navigator.pop(context);
                                },
                              ),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                      .withAlpha(76),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withAlpha(25),
                                  ),
                                ),
                                child: Center(
                                  child: Icon(Icons.delete_outline,
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
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding:
                        const EdgeInsetsDirectional.only(top: 10, bottom: 15),
                    title: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        currentSubject.name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
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
                              color: currentSubject.color.withAlpha(26),
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
                                currentSubject.iconData,
                                color: currentSubject.color,
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
                    child: StreamBuilder<List<Category>>(
                      stream: _contentService.getCategories(currentSubject.id),
                      builder: (context, categorySnapshot) {
                        if (categorySnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (categorySnapshot.hasError) {
                          final err = categorySnapshot.error;
                          debugPrint('Category stream error: $err');
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Center(
                                child: Text(
                                  'Fehler beim Laden der Kategorien: $err',
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          );
                        }

                        final categories = categorySnapshot.data ?? [];

                        if (categories.isEmpty) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Center(
                                child: Text(
                                  "Zu diesem Fach gibt es noch keine Lerninhalte",
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
                          itemCount: categories.length,
                          itemBuilder:
                              (BuildContext context, int categoryIndex) {
                            final category = categories[categoryIndex];
                            final canDeleteCategory = currentUser != null &&
                                category.authorId == currentUser.uid;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (categoryIndex > 0)
                                  const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        category.name,
                                        style: TextStyle(
                                          fontSize: 22,
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
                                            if (canDeleteCategory)
                                              InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                onTap: () => _confirmDelete(
                                                  title: 'Kategorie löschen?',
                                                  message:
                                                      'Möchtest du diese Kategorie wirklich löschen? Alle Inhalte darunter werden ebenfalls gelöscht.',
                                                  onConfirm: () async {
                                                    await _contentService
                                                        .deleteCategory(
                                                      subjectId:
                                                          currentSubject.id,
                                                      categoryId: category.id,
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
                                            if (canDeleteCategory)
                                              const SizedBox(width: 8),
                                            if (canDeleteCategory)
                                              InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                onTap: () => showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      CategoryDialog(
                                                    subjectId:
                                                        currentSubject.id,
                                                    category: category,
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
                                            if (canDeleteCategory)
                                              const SizedBox(width: 8),
                                            InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              onTap: () => showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    TopicDialog(
                                                  subjectId: currentSubject.id,
                                                  categoryId: category.id,
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
                                const SizedBox(height: 8),
                                StreamBuilder<List<Topic>>(
                                  stream: _contentService.getTopics(
                                      currentSubject.id, category.id),
                                  builder: (context, topicSnapshot) {
                                    if (!topicSnapshot.hasData) {
                                      return const SizedBox.shrink();
                                    }
                                    final topics = topicSnapshot.data!;

                                    return ListView.builder(
                                      padding: EdgeInsets.zero,
                                      physics: const ClampingScrollPhysics(),
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount: topics.length,
                                      itemBuilder: (BuildContext context,
                                          int topicIndex) {
                                        final topic = topics[topicIndex];
                                        final canDeleteTopic = currentUser !=
                                                null &&
                                            topic.authorId == currentUser.uid;
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    topic.name,
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface,
                                                    ),
                                                  ),
                                                  Container(
                                                    color: Colors.transparent,
                                                    child: Row(
                                                      children: [
                                                        if (canDeleteTopic)
                                                          InkWell(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                            onTap: () =>
                                                                _confirmDelete(
                                                              title:
                                                                  'Thema löschen?',
                                                              message:
                                                                  'Möchtest du dieses Thema wirklich löschen? Alle Inhalte darunter werden ebenfalls gelöscht.',
                                                              onConfirm:
                                                                  () async {
                                                                await _contentService
                                                                    .deleteTopic(
                                                                  subjectId:
                                                                      currentSubject
                                                                          .id,
                                                                  categoryId:
                                                                      category
                                                                          .id,
                                                                  topicId:
                                                                      topic.id,
                                                                );
                                                              },
                                                            ),
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primaryContainer
                                                                    .withAlpha(
                                                                        76),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12),
                                                                border:
                                                                    Border.all(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary
                                                                      .withAlpha(
                                                                          25),
                                                                ),
                                                              ),
                                                              child: Icon(
                                                                  Icons
                                                                      .delete_outline,
                                                                  size: 24,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary),
                                                            ),
                                                          ),
                                                        if (canDeleteTopic)
                                                          const SizedBox(
                                                              width: 8),
                                                        if (canDeleteTopic)
                                                          InkWell(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                            onTap: () =>
                                                                showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) =>
                                                                      TopicDialog(
                                                                subjectId:
                                                                    currentSubject
                                                                        .id,
                                                                categoryId:
                                                                    category.id,
                                                                topic: topic,
                                                              ),
                                                            ),
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primaryContainer
                                                                    .withAlpha(
                                                                        76),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12),
                                                                border:
                                                                    Border.all(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary
                                                                      .withAlpha(
                                                                          25),
                                                                ),
                                                              ),
                                                              child: Icon(
                                                                  Icons.edit,
                                                                  size: 24,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary),
                                                            ),
                                                          ),
                                                        if (canDeleteTopic)
                                                          const SizedBox(
                                                              width: 8),
                                                        InkWell(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                          onTap: () =>
                                                              showDialog(
                                                            context: context,
                                                            builder:
                                                                (context) =>
                                                                    UnitDialog(
                                                              subjectId:
                                                                  currentSubject
                                                                      .id,
                                                              categoryId:
                                                                  category.id,
                                                              topicId: topic.id,
                                                            ),
                                                          ),
                                                          child: Container(
                                                            width: 40,
                                                            height: 40,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primaryContainer
                                                                  .withAlpha(
                                                                      76),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                              border:
                                                                  Border.all(
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primary
                                                                    .withAlpha(
                                                                        25),
                                                              ),
                                                            ),
                                                            child: Center(
                                                              child: Icon(
                                                                Icons.add,
                                                                size: 24,
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primary,
                                                              ),
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
                                            StreamBuilder<List<Unit>>(
                                              stream: _contentService.getUnits(
                                                  currentSubject.id,
                                                  category.id,
                                                  topic.id),
                                              builder: (context, unitSnapshot) {
                                                if (!unitSnapshot.hasData) {
                                                  return const SizedBox
                                                      .shrink();
                                                }
                                                final units =
                                                    unitSnapshot.data!;

                                                return SingleChildScrollView(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12),
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: units.map((unit) {
                                                      final canDeleteUnit =
                                                          currentUser != null &&
                                                              unit.authorId ==
                                                                  currentUser
                                                                      .uid;
                                                      return UnitTile(
                                                        unit: unit,
                                                        onTap: () =>
                                                            navigateToUnitPage(
                                                          currentSubject.id,
                                                          category.id,
                                                          topic.id,
                                                          unit,
                                                        ),
                                                        onEdit: canDeleteUnit
                                                            ? () => showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) =>
                                                                          UnitDialog(
                                                                    subjectId:
                                                                        currentSubject
                                                                            .id,
                                                                    categoryId:
                                                                        category
                                                                            .id,
                                                                    topicId:
                                                                        topic
                                                                            .id,
                                                                    unit: unit,
                                                                  ),
                                                                )
                                                            : null,
                                                        onDelete: canDeleteUnit
                                                            ? () =>
                                                                _confirmDelete(
                                                                  title:
                                                                      'Einheit löschen?',
                                                                  message:
                                                                      'Möchtest du diese Einheit wirklich löschen? Alle Inhalte darunter werden ebenfalls gelöscht.',
                                                                  onConfirm:
                                                                      () async {
                                                                    await _contentService
                                                                        .deleteUnit(
                                                                      subjectId:
                                                                          currentSubject
                                                                              .id,
                                                                      categoryId:
                                                                          category
                                                                              .id,
                                                                      topicId:
                                                                          topic
                                                                              .id,
                                                                      unitId:
                                                                          unit.id,
                                                                    );
                                                                  },
                                                                )
                                                            : null,
                                                      );
                                                    }).toList(),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                )
              ],
            ));
      },
    );
  }

  void navigateToUnitPage(
      String subjectId, String categoryId, String topicId, Unit unit) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UnitOverviewPage(
            subjectId: subjectId,
            categoryId: categoryId,
            topicId: topicId,
            unit: unit,
          ),
        ));
  }
}
