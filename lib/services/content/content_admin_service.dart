import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tech_knowl_edge_connect/components/library/learning_material_type.dart';
import 'package:tech_knowl_edge_connect/components/user/user_constants.dart';
import 'package:file_picker/file_picker.dart';

class ContentAdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // --- Subjects ---

  Stream<QuerySnapshot<Map<String, dynamic>>> streamSubjects() {
    return _firestore
        .collection('content_subjects')
        .orderBy('createdAt')
        .snapshots();
  }

  Future<DocumentReference<Map<String, dynamic>>> createSubject({
    required String name,
    required String status,
    required int version,
    required String userId,
    required int color,
    required Map<String, dynamic> iconData,
  }) async {
    final docRef = _firestore.collection('content_subjects').doc();
    await docRef.set({
      'name': name,
      'status': status,
      'version': version,
      'color': color,
      'iconData': iconData,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
      'createdBy': userId,
      'updatedBy': userId,
    });
    return docRef;
  }

  Future<void> updateSubject({
    required String subjectId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection('content_subjects').doc(subjectId).update({
      ...data,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> deleteSubject({
    required String subjectId,
  }) async {
    // Delete subcollections recursively (categories)
    final categories = await _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .get();

    for (final category in categories.docs) {
      await deleteCategory(subjectId: subjectId, categoryId: category.id);
    }

    await _firestore.collection('content_subjects').doc(subjectId).delete();
  }

  // --- Categories ---

  Stream<QuerySnapshot<Map<String, dynamic>>> streamCategories(
      String subjectId) {
    return _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .orderBy('createdAt')
        .snapshots();
  }

  Future<DocumentReference<Map<String, dynamic>>> createCategory({
    required String subjectId,
    required String name,
    required String status,
    required int version,
    required String userId,
  }) async {
    final docRef = _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc();
    await docRef.set({
      'name': name,
      'status': status,
      'version': version,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
      'createdBy': userId,
      'updatedBy': userId,
    });
    return docRef;
  }

  Future<void> updateCategory({
    required String subjectId,
    required String categoryId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .update({
      ...data,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> deleteCategory({
    required String subjectId,
    required String categoryId,
  }) async {
    final topics = await _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .collection('topics')
        .get();

    for (final topic in topics.docs) {
      await deleteTopic(
          subjectId: subjectId, categoryId: categoryId, topicId: topic.id);
    }

    await _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .delete();
  }

  // --- Topics ---

  Stream<QuerySnapshot<Map<String, dynamic>>> streamTopics(
    String subjectId,
    String categoryId,
  ) {
    return _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .collection('topics')
        .orderBy('createdAt')
        .snapshots();
  }

  Future<DocumentReference<Map<String, dynamic>>> createTopic({
    required String subjectId,
    required String categoryId,
    required String name,
    required String status,
    required int version,
    required String userId,
  }) async {
    final docRef = _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .collection('topics')
        .doc();
    await docRef.set({
      'name': name,
      'status': status,
      'version': version,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
      'createdBy': userId,
      'updatedBy': userId,
    });
    return docRef;
  }

  Future<void> updateTopic({
    required String subjectId,
    required String categoryId,
    required String topicId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .collection('topics')
        .doc(topicId)
        .update({
      ...data,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> deleteTopic({
    required String subjectId,
    required String categoryId,
    required String topicId,
  }) async {
    final units = await _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .collection('topics')
        .doc(topicId)
        .collection('units')
        .get();

    for (final unit in units.docs) {
      await deleteUnit(
          subjectId: subjectId,
          categoryId: categoryId,
          topicId: topicId,
          unitId: unit.id);
    }

    await _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .collection('topics')
        .doc(topicId)
        .delete();
  }

  // --- Units ---

  Stream<QuerySnapshot<Map<String, dynamic>>> streamUnits(
    String subjectId,
    String categoryId,
    String topicId,
  ) {
    return _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .collection('topics')
        .doc(topicId)
        .collection('units')
        .orderBy('createdAt')
        .snapshots();
  }

  Future<DocumentReference<Map<String, dynamic>>> createUnit({
    required String subjectId,
    required String categoryId,
    required String topicId,
    required String name,
    required String status,
    required int version,
    required String userId,
    required Map<String, dynamic> iconData,
  }) async {
    final docRef = _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .collection('topics')
        .doc(topicId)
        .collection('units')
        .doc();
    await docRef.set({
      'name': name,
      'status': status,
      'version': version,
      'iconData': iconData,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
      'createdBy': userId,
      'updatedBy': userId,
    });
    return docRef;
  }

  Future<void> updateUnit({
    required String subjectId,
    required String categoryId,
    required String topicId,
    required String unitId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .collection('topics')
        .doc(topicId)
        .collection('units')
        .doc(unitId)
        .update({
      ...data,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> deleteUnit({
    required String subjectId,
    required String categoryId,
    required String topicId,
    required String unitId,
  }) async {
    final concepts = await _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .collection('topics')
        .doc(topicId)
        .collection('units')
        .doc(unitId)
        .collection('concepts')
        .get();

    for (final concept in concepts.docs) {
      await deleteConcept(
          subjectId: subjectId,
          categoryId: categoryId,
          topicId: topicId,
          unitId: unitId,
          conceptId: concept.id);
    }

    await _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .collection('topics')
        .doc(topicId)
        .collection('units')
        .doc(unitId)
        .delete();
  }

  // --- Concepts ---

  Stream<QuerySnapshot<Map<String, dynamic>>> streamConcepts(
    String subjectId,
    String categoryId,
    String topicId,
    String unitId,
  ) {
    return _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .collection('topics')
        .doc(topicId)
        .collection('units')
        .doc(unitId)
        .collection('concepts')
        .orderBy('createdAt')
        .snapshots();
  }

  Future<DocumentReference<Map<String, dynamic>>> createConcept({
    required String subjectId,
    required String categoryId,
    required String topicId,
    required String unitId,
    required String name,
    required String status,
    required int version,
    required String userId,
  }) async {
    final docRef = _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .collection('topics')
        .doc(topicId)
        .collection('units')
        .doc(unitId)
        .collection('concepts')
        .doc();
    await docRef.set({
      'name': name,
      'status': status,
      'version': version,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
      'createdBy': userId,
      'updatedBy': userId,
    });
    return docRef;
  }

  Future<void> updateConcept({
    required String subjectId,
    required String categoryId,
    required String topicId,
    required String unitId,
    required String conceptId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .collection('topics')
        .doc(topicId)
        .collection('units')
        .doc(unitId)
        .collection('concepts')
        .doc(conceptId)
        .update({
      ...data,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> deleteConcept({
    required String subjectId,
    required String categoryId,
    required String topicId,
    required String unitId,
    required String conceptId,
  }) async {
    final learningBites = await _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .collection('topics')
        .doc(topicId)
        .collection('units')
        .doc(unitId)
        .collection('concepts')
        .doc(conceptId)
        .collection('learning_bites')
        .get();

    for (final learningBite in learningBites.docs) {
      await deleteLearningBite(
        subjectId: subjectId,
        categoryId: categoryId,
        topicId: topicId,
        unitId: unitId,
        conceptId: conceptId,
        learningBiteId: learningBite.id,
      );
    }

    await _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .collection('topics')
        .doc(topicId)
        .collection('units')
        .doc(unitId)
        .collection('concepts')
        .doc(conceptId)
        .delete();
  }

  // --- Learning Bites ---

  Stream<QuerySnapshot<Map<String, dynamic>>> streamLearningBites(
    String subjectId,
    String categoryId,
    String topicId,
    String unitId,
    String conceptId,
  ) {
    return _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .collection('topics')
        .doc(topicId)
        .collection('units')
        .doc(unitId)
        .collection('concepts')
        .doc(conceptId)
        .collection('learning_bites')
        .orderBy('createdAt')
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamLearningBite(
    String subjectId,
    String categoryId,
    String topicId,
    String unitId,
    String conceptId,
    String learningBiteId,
  ) {
    return _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .collection('topics')
        .doc(topicId)
        .collection('units')
        .doc(unitId)
        .collection('concepts')
        .doc(conceptId)
        .collection('learning_bites')
        .doc(learningBiteId)
        .snapshots();
  }

  Future<DocumentReference<Map<String, dynamic>>> createLearningBite({
    required String subjectId,
    required String categoryId,
    required String topicId,
    required String unitId,
    required String conceptId,
    required String title,
    required List<String> content,
    required String type,
    required String status,
    required int version,
    required String userId,
    required Map<String, dynamic> iconData,
  }) async {
    final docRef = _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .collection('topics')
        .doc(topicId)
        .collection('units')
        .doc(unitId)
        .collection('concepts')
        .doc(conceptId)
        .collection('learning_bites')
        .doc();
    await docRef.set({
      'title': title,
      'content': content,
      'type': type,
      'status': status,
      'version': version,
      'iconData': iconData,
      'resources': [],
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
      'createdBy': userId,
      'updatedBy': userId,
    });

    if (status == UserConstants.statusApproved) {
      try {
        // Find all users who are currently tracking progress for this unit
        // and increment their expectedBiteCount to reflect the new bite.
        final usersSnap = await _firestore.collection('Users').get();
        final batch = _firestore.batch();
        for (final userDoc in usersSnap.docs) {
          final resumeDocRef =
              userDoc.reference.collection('resumeProgress').doc(unitId);
          final resumeSnap = await resumeDocRef.get();
          if (resumeSnap.exists) {
            final data = resumeSnap.data();
            if (data != null) {
              final currentExpected =
                  (data['expectedBiteCount'] as num?)?.toInt() ?? 0;
              final updated = currentExpected + 1;
              final bites = Map<String, dynamic>.from(
                  data['bites'] as Map<String, dynamic>? ?? {});
              final biteValues = bites.values
                  .map((e) =>
                      (e as Map<String, dynamic>)['progress'] as num? ?? 0)
                  .toList();
              final agg = biteValues.isEmpty
                  ? 0
                  : (biteValues.reduce((a, b) => a + b) /
                          (updated > 0 ? updated : biteValues.length))
                      .round();
              batch.update(resumeDocRef, {
                'expectedBiteCount': updated,
                'progress': agg >= 100 ? 100 : agg,
                'status': agg >= 100 ? 'completed' : 'in_progress',
                'lastUpdated': FieldValue.serverTimestamp(),
              });
            }
          }
        }
        await batch.commit();
      } catch (_) {}
    }

    return docRef;
  }

  Future<void> updateLearningBite({
    required String subjectId,
    required String categoryId,
    required String topicId,
    required String unitId,
    required String conceptId,
    required String learningBiteId,
    required Map<String, dynamic> data,
  }) async {
    final docRef = _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .collection('topics')
        .doc(topicId)
        .collection('units')
        .doc(unitId)
        .collection('concepts')
        .doc(conceptId)
        .collection('learning_bites')
        .doc(learningBiteId);

    final docSnap = await docRef.get();
    final oldStatus = docSnap.data()?['status'];
    final newStatus = data['status'] ?? oldStatus;
    final authorId =
        docSnap.data()?['authorId']; // Only present for user-created bites

    await docRef.update({
      ...data,
      'updatedAt': Timestamp.now(),
    });

    if (oldStatus != newStatus) {
      if (newStatus == UserConstants.statusApproved) {
        // Was not approved, now is approved -> +1 count
        try {
          final usersSnap = await _firestore.collection('Users').get();
          final batch = _firestore.batch();
          for (final userDoc in usersSnap.docs) {
            // The original user author already had this counted, skip them.
            // Admin creators didn't see it when it was pending, so don't skip them.
            if (authorId != null && userDoc.id == authorId) continue;

            final resumeDocRef =
                userDoc.reference.collection('resumeProgress').doc(unitId);
            final resumeSnap = await resumeDocRef.get();
            if (resumeSnap.exists) {
              final resumeData = resumeSnap.data();
              if (resumeData != null) {
                final currentExpected =
                    (resumeData['expectedBiteCount'] as num?)?.toInt() ?? 0;
                final updated = currentExpected + 1;
                final bites = Map<String, dynamic>.from(
                    resumeData['bites'] as Map<String, dynamic>? ?? {});
                final biteValues = bites.values
                    .map((e) =>
                        (e as Map<String, dynamic>)['progress'] as num? ?? 0)
                    .toList();
                final agg = biteValues.isEmpty
                    ? 0
                    : (biteValues.reduce((a, b) => a + b) /
                            (updated > 0 ? updated : biteValues.length))
                        .round();
                batch.update(resumeDocRef, {
                  'expectedBiteCount': updated,
                  'progress': agg >= 100 ? 100 : agg,
                  'status': agg >= 100 ? 'completed' : 'in_progress',
                  'lastUpdated': FieldValue.serverTimestamp(),
                });
              }
            }
          }
          await batch.commit();
        } catch (_) {}
      } else if (oldStatus == UserConstants.statusApproved) {
        // Was approved, now is not approved -> -1 count and remove from progress
        try {
          final usersSnap = await _firestore.collection('Users').get();
          final batch = _firestore.batch();
          for (final userDoc in usersSnap.docs) {
            // The original user author can still see it, so skip subtracting for them.
            if (authorId != null && userDoc.id == authorId) continue;

            final resumeDocRef =
                userDoc.reference.collection('resumeProgress').doc(unitId);
            final resumeSnap = await resumeDocRef.get();
            if (resumeSnap.exists) {
              final resumeData = resumeSnap.data();
              if (resumeData != null) {
                final bites = Map<String, dynamic>.from(
                    resumeData['bites'] as Map<String, dynamic>? ?? {});
                final bool hasBite = bites.containsKey(learningBiteId);
                if (hasBite) {
                  bites.remove(learningBiteId);
                }
                if (bites.isEmpty) {
                  batch.delete(resumeDocRef);
                } else {
                  final biteValues = bites.values
                      .map((e) =>
                          (e as Map<String, dynamic>)['progress'] as num? ?? 0)
                      .toList();
                  final currentExpected =
                      (resumeData['expectedBiteCount'] as num?)?.toInt() ??
                          (biteValues.length + (hasBite ? 1 : 0));
                  final expectedAfter =
                      (currentExpected - 1) < 0 ? 0 : (currentExpected - 1);
                  final denom =
                      expectedAfter > 0 ? expectedAfter : biteValues.length;
                  final agg = biteValues.isEmpty
                      ? 0
                      : (biteValues.reduce((a, b) => a + b) / denom).round();
                  batch.update(resumeDocRef, {
                    'bites': bites,
                    'expectedBiteCount': expectedAfter,
                    'progress': agg >= 100 ? 100 : agg,
                    'status': agg >= 100 ? 'completed' : 'in_progress',
                    'lastUpdated': FieldValue.serverTimestamp(),
                  });
                }
              }
            }
            batch.update(userDoc.reference, {
              'completedLearningBiteIds':
                  FieldValue.arrayRemove([learningBiteId]),
            });
          }
          await batch.commit();
        } catch (_) {}
      }
    }
  }

  Future<void> deleteLearningBite({
    required String subjectId,
    required String categoryId,
    required String topicId,
    required String unitId,
    required String conceptId,
    required String learningBiteId,
  }) async {
    final biteRef = _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .collection('topics')
        .doc(topicId)
        .collection('units')
        .doc(unitId)
        .collection('concepts')
        .doc(conceptId)
        .collection('learning_bites')
        .doc(learningBiteId);

    final biteSnap = await biteRef.get();
    final wasApproved =
        biteSnap.data()?['status'] == UserConstants.statusApproved;
    final authorId = biteSnap.data()?['authorId'];

    final tasks = await biteRef.collection('tasks').get();

    for (final task in tasks.docs) {
      await task.reference.delete();
    }

    await biteRef.delete();

    try {
      // Find all users tracking this unit and decrement expected bite count.
      // If they had progress for this specific bite, remove it.
      final usersSnap = await _firestore.collection('Users').get();
      final batch = _firestore.batch();
      for (final userDoc in usersSnap.docs) {
        // If not approved, ONLY the user author saw it. If it was admin created, NO ONE saw it in progress list.
        if (!wasApproved) {
          if (authorId != null && userDoc.id == authorId) {
            // proceed
          } else {
            continue;
          }
        }

        final resumeDocRef =
            userDoc.reference.collection('resumeProgress').doc(unitId);
        final resumeSnap = await resumeDocRef.get();
        if (resumeSnap.exists) {
          final data = resumeSnap.data();
          if (data != null) {
            final bites = Map<String, dynamic>.from(
                data['bites'] as Map<String, dynamic>? ?? {});
            final bool hasBite = bites.containsKey(learningBiteId);
            if (hasBite) {
              bites.remove(learningBiteId);
            }
            if (bites.isEmpty) {
              batch.delete(resumeDocRef);
            } else {
              final biteValues = bites.values
                  .map((e) =>
                      (e as Map<String, dynamic>)['progress'] as num? ?? 0)
                  .toList();
              final currentExpected =
                  (data['expectedBiteCount'] as num?)?.toInt() ??
                      (biteValues.length + (hasBite ? 1 : 0));
              final expectedAfter =
                  (currentExpected - 1) < 0 ? 0 : (currentExpected - 1);
              final denom =
                  expectedAfter > 0 ? expectedAfter : biteValues.length;
              final agg = biteValues.isEmpty
                  ? 0
                  : (biteValues.reduce((a, b) => a + b) / denom).round();
              batch.update(resumeDocRef, {
                'bites': bites,
                'expectedBiteCount': expectedAfter,
                'progress': agg >= 100 ? 100 : agg,
                'status': agg >= 100 ? 'completed' : 'in_progress',
                'lastUpdated': FieldValue.serverTimestamp(),
              });
            }
          }
        }

        // Also remove from completed learning bites array
        batch.update(userDoc.reference, {
          'completedLearningBiteIds': FieldValue.arrayRemove([learningBiteId]),
        });
      }
      await batch.commit();
    } catch (_) {}
  }

  // --- Tasks ---

  Stream<QuerySnapshot<Map<String, dynamic>>> streamTasks(
    String subjectId,
    String categoryId,
    String topicId,
    String unitId,
    String conceptId,
    String learningBiteId,
  ) {
    return _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .collection('topics')
        .doc(topicId)
        .collection('units')
        .doc(unitId)
        .collection('concepts')
        .doc(conceptId)
        .collection('learning_bites')
        .doc(learningBiteId)
        .collection('tasks')
        .orderBy('createdAt')
        .snapshots();
  }

  Future<DocumentReference<Map<String, dynamic>>> createTask({
    required String subjectId,
    required String categoryId,
    required String topicId,
    required String unitId,
    required String conceptId,
    required String learningBiteId,
    required String type,
    required String question,
    required String correctAnswer,
    required List<String> answers,
  }) async {
    final docRef = _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .collection('topics')
        .doc(topicId)
        .collection('units')
        .doc(unitId)
        .collection('concepts')
        .doc(conceptId)
        .collection('learning_bites')
        .doc(learningBiteId)
        .collection('tasks')
        .doc();

    await docRef.set({
      'type': type,
      'question': question,
      'correctAnswer': correctAnswer,
      'answers': answers,
      'createdAt': Timestamp.now(),
    });
    return docRef;
  }

  Future<void> updateTask({
    required String subjectId,
    required String categoryId,
    required String topicId,
    required String unitId,
    required String conceptId,
    required String learningBiteId,
    required String taskId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .collection('topics')
        .doc(topicId)
        .collection('units')
        .doc(unitId)
        .collection('concepts')
        .doc(conceptId)
        .collection('learning_bites')
        .doc(learningBiteId)
        .collection('tasks')
        .doc(taskId)
        .update(data);
  }

  Future<void> deleteTask({
    required String subjectId,
    required String categoryId,
    required String topicId,
    required String unitId,
    required String conceptId,
    required String learningBiteId,
    required String taskId,
  }) async {
    await _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .collection('topics')
        .doc(topicId)
        .collection('units')
        .doc(unitId)
        .collection('concepts')
        .doc(conceptId)
        .collection('learning_bites')
        .doc(learningBiteId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  Future<List<Map<String, dynamic>>> uploadFiles({
    required String userId,
    required List<PlatformFile> files,
    Map<String, dynamic>? metadata,
  }) async {
    final List<Map<String, dynamic>> resources = [];
    for (final file in files) {
      final extension = file.extension ?? '';
      final mimeType = LearningMaterialType.getMimeType(extension);
      final storagePath =
          'admin_uploads/$userId/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final ref = _storage.ref().child(storagePath);
      final bytes = file.bytes;
      if (bytes == null) {
        continue;
      }
      final uploadTask = await ref.putData(
        bytes,
        SettableMetadata(contentType: mimeType),
      );
      final url = await uploadTask.ref.getDownloadURL();
      resources.add({
        'name': file.name,
        'url': url,
        'mimeType': mimeType,
        'size': file.size,
        'createdAt': Timestamp.now(),
        if (metadata != null) ...metadata,
      });
    }
    return resources;
  }

  // --- Pending Approvals ---

  Stream<QuerySnapshot<Map<String, dynamic>>> streamPendingLearningBites() {
    return _firestore
        .collectionGroup('learning_bites')
        .where('status', isEqualTo: UserConstants.statusPending)
        .orderBy('createdAt')
        .snapshots();
  }

  Future<void> approveLearningBite(DocumentReference reference) async {
    await reference.update({
      'status': UserConstants.statusApproved,
      'approvedAt': Timestamp.now(),
    });
  }

  Future<void> rejectLearningBite(DocumentReference reference) async {
    await reference.update({
      'status': UserConstants.statusRejected,
      'rejectedAt': Timestamp.now(),
    });
  }
}
