import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tech_knowl_edge_connect/components/unit_tile.dart';
import 'package:tech_knowl_edge_connect/components/user/dialogs/category_dialog.dart';
import 'package:tech_knowl_edge_connect/components/user/dialogs/subject_dialog.dart';
import 'package:tech_knowl_edge_connect/components/user/dialogs/topic_dialog.dart';
import 'package:tech_knowl_edge_connect/components/user/dialogs/unit_dialog.dart';
import 'package:tech_knowl_edge_connect/models/category.dart';
import 'package:tech_knowl_edge_connect/models/subject.dart';
import 'package:tech_knowl_edge_connect/models/topic.dart';
import 'package:tech_knowl_edge_connect/models/unit.dart';
import 'package:tech_knowl_edge_connect/pages/search/unit_overview_page.dart';
import 'package:tech_knowl_edge_connect/services/content_service.dart';

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
                SliverAppBar.large(
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  actions: [
                    if (currentUser != null &&
                        currentSubject.authorId == currentUser.uid) ...[
                      IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Fach bearbeiten',
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) => SubjectDialog(
                            subject: currentSubject,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Fach löschen',
                        onPressed: () => _confirmDelete(
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
                      ),
                    ],
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding:
                        const EdgeInsetsDirectional.only(top: 10, bottom: 10),
                    title: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(currentSubject.name),
                    ),
                    background: Stack(children: [
                      OverflowBox(
                        maxWidth: 800,
                        maxHeight: 800,
                        child: FaIcon(
                          currentSubject.iconData,
                          color: currentSubject.color,
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
                    child: StreamBuilder<List<Category>>(
                      stream: _contentService.getCategories(currentSubject.id),
                      builder: (context, categorySnapshot) {
                        if (categorySnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        final categories = categorySnapshot.data ?? [];

                        if (categories.isEmpty) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15),
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
                                const SizedBox(height: 20),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        category.name,
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                      Row(
                                        children: [
                                          if (canDeleteCategory)
                                            IconButton(
                                              icon: const Icon(Icons.edit),
                                              tooltip: 'Kategorie bearbeiten',
                                              onPressed: () => showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    CategoryDialog(
                                                  subjectId: currentSubject.id,
                                                  category: category,
                                                ),
                                              ),
                                            ),
                                          IconButton(
                                            icon: const Icon(Icons.add),
                                            onPressed: () => showDialog(
                                              context: context,
                                              builder: (context) => TopicDialog(
                                                subjectId: currentSubject.id,
                                                categoryId: category.id,
                                              ),
                                            ),
                                            tooltip: 'Neues Thema hinzufügen',
                                          ),
                                          if (canDeleteCategory)
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.delete_outline),
                                              tooltip: 'Kategorie löschen',
                                              onPressed: () => _confirmDelete(
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
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                StreamBuilder<List<Topic>>(
                                  stream: _contentService.getTopics(
                                      currentSubject.id, category.id),
                                  builder: (context, topicSnapshot) {
                                    if (!topicSnapshot.hasData) {
                                      return const SizedBox.shrink();
                                    }
                                    final topics = topicSnapshot.data!;

                                    return ListView.builder(
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
                                            const SizedBox(height: 10),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 20, right: 20),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    topic.name,
                                                    style: const TextStyle(
                                                        fontSize: 20),
                                                  ),
                                                  Row(
                                                    children: [
                                                      if (canDeleteTopic)
                                                        IconButton(
                                                          icon: const Icon(
                                                              Icons.edit),
                                                          tooltip:
                                                              'Thema bearbeiten',
                                                          onPressed: () =>
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
                                                        ),
                                                      IconButton(
                                                        icon: const Icon(Icons
                                                            .add_circle_outline),
                                                        onPressed: () =>
                                                            showDialog(
                                                          context: context,
                                                          builder: (context) =>
                                                              UnitDialog(
                                                            subjectId:
                                                                currentSubject
                                                                    .id,
                                                            categoryId:
                                                                category.id,
                                                            topicId: topic.id,
                                                          ),
                                                        ),
                                                        tooltip:
                                                            'Neue Einheit hinzufügen',
                                                      ),
                                                      if (canDeleteTopic)
                                                        IconButton(
                                                          icon: const Icon(Icons
                                                              .delete_outline),
                                                          tooltip:
                                                              'Thema löschen',
                                                          onPressed: () =>
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
                                                                    category.id,
                                                                topicId:
                                                                    topic.id,
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
                                              child: StreamBuilder<List<Unit>>(
                                                stream:
                                                    _contentService.getUnits(
                                                        currentSubject.id,
                                                        category.id,
                                                        topic.id),
                                                builder:
                                                    (context, unitSnapshot) {
                                                  if (!unitSnapshot.hasData) {
                                                    return const SizedBox
                                                        .shrink();
                                                  }
                                                  final units =
                                                      unitSnapshot.data!;

                                                  return ListView.builder(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10),
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    shrinkWrap: true,
                                                    itemCount: units.length,
                                                    itemBuilder:
                                                        (BuildContext context,
                                                            int unitIndex) {
                                                      final unit =
                                                          units[unitIndex];
                                                      final canDeleteUnit =
                                                          currentUser != null &&
                                                              unit.authorId ==
                                                                  currentUser
                                                                      .uid;
                                                      return Row(
                                                        children: [
                                                          UnitTile(
                                                            unit: unit,
                                                            onTap: () =>
                                                                navigateToUnitPage(
                                                              currentSubject.id,
                                                              category.id,
                                                              topic.id,
                                                              unit,
                                                            ),
                                                            onEdit:
                                                                canDeleteUnit
                                                                    ? () =>
                                                                        showDialog(
                                                                          context:
                                                                              context,
                                                                          builder: (context) =>
                                                                              UnitDialog(
                                                                            subjectId:
                                                                                currentSubject.id,
                                                                            categoryId:
                                                                                category.id,
                                                                            topicId:
                                                                                topic.id,
                                                                            unit:
                                                                                unit,
                                                                          ),
                                                                        )
                                                                    : null,
                                                            onDelete:
                                                                canDeleteUnit
                                                                    ? () =>
                                                                        _confirmDelete(
                                                                          title:
                                                                              'Einheit löschen?',
                                                                          message:
                                                                              'Möchtest du diese Einheit wirklich löschen? Alle Inhalte darunter werden ebenfalls gelöscht.',
                                                                          onConfirm:
                                                                              () async {
                                                                            await _contentService.deleteUnit(
                                                                              subjectId: currentSubject.id,
                                                                              categoryId: category.id,
                                                                              topicId: topic.id,
                                                                              unitId: unit.id,
                                                                            );
                                                                          },
                                                                        )
                                                                    : null,
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
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
