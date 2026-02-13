import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tech_knowl_edge_connect/components/learning_material_type.dart';
import 'package:tech_knowl_edge_connect/components/user/user_constants.dart';
import 'package:file_picker/file_picker.dart';

class ContentAdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // --- Subjects ---

  Stream<QuerySnapshot<Map<String, dynamic>>> streamSubjects() {
    return _firestore
        .collection('content_subjects')
        .orderBy('name')
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
        .orderBy('name')
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
        .orderBy('name')
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
        .orderBy('name')
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
        .orderBy('name')
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
        .orderBy('title')
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
        .update({
      ...data,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> deleteLearningBite({
    required String subjectId,
    required String categoryId,
    required String topicId,
    required String unitId,
    required String conceptId,
    required String learningBiteId,
  }) async {
    final tasks = await _firestore
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
        .get();

    for (final task in tasks.docs) {
      await task.reference.delete();
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
        .collection('learning_bites')
        .doc(learningBiteId)
        .delete();
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
