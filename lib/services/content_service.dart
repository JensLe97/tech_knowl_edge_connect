import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tech_knowl_edge_connect/components/user/user_constants.dart';
import 'package:tech_knowl_edge_connect/models/category.dart';
import 'package:tech_knowl_edge_connect/models/concept.dart';
import 'package:tech_knowl_edge_connect/models/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/subject.dart';
import 'package:tech_knowl_edge_connect/models/task.dart';
import 'package:tech_knowl_edge_connect/models/topic.dart';
import 'package:tech_knowl_edge_connect/models/unit.dart';

class ContentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Subjects ---
  Stream<List<Subject>> getSubjects() {
    final globalStream = _firestore
        .collection('content_subjects')
        .where('status', isEqualTo: UserConstants.statusApproved)
        .snapshots()
        .map((snapshot) {
      final subjects = snapshot.docs.map((doc) {
        return Subject.fromMap(doc.data(), doc.id);
      }).toList();
      subjects.sort((a, b) => a.name.compareTo(b.name));
      return subjects;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return globalStream.map((list) {
        list.sort((a, b) => a.name.compareTo(b.name));
        return list;
      });
    }

    final userStream = _firestore
        .collection('content_subjects')
        .where('authorId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      final subjects = snapshot.docs.map((doc) {
        return Subject.fromMap(doc.data(), doc.id);
      }).toList();
      subjects.sort((a, b) => a.name.compareTo(b.name));
      return subjects;
    });

    return _combineStreams(globalStream, userStream).map((lists) {
      final global = lists[0];
      final personal = lists[1];
      final Map<String, Subject> combinedMap = {};
      for (var s in global) {
        combinedMap[s.id] = s;
      }
      for (var s in personal) {
        combinedMap[s.id] = s;
      }
      final sortedList = combinedMap.values.toList();
      sortedList
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return sortedList;
    });
  }

  // --- Categories ---
  Stream<List<Category>> getCategories(String subjectId) {
    final globalStream = _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .where('status', isEqualTo: UserConstants.statusApproved)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Category.fromMap(doc.data(), doc.id);
      }).toList();
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return globalStream;

    final userStream = _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .where('authorId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Category.fromMap(doc.data(), doc.id);
      }).toList();
    });

    return _combineStreams(globalStream, userStream).map((lists) {
      final global = lists[0];
      final personal = lists[1];
      final Map<String, Category> combinedMap = {};
      for (var s in global) {
        combinedMap[s.id] = s;
      }
      for (var s in personal) {
        combinedMap[s.id] = s;
      }
      final sortedList = combinedMap.values.toList();
      sortedList
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return sortedList;
    });
  }

  // --- Topics ---
  Stream<List<Topic>> getTopics(String subjectId, String categoryId) {
    final globalStream = _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .collection('topics')
        .where('status', isEqualTo: UserConstants.statusApproved)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Topic.fromMap(doc.data(), doc.id);
      }).toList();
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return globalStream;

    final userStream = _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .collection('topics')
        .where('authorId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Topic.fromMap(doc.data(), doc.id);
      }).toList();
    });

    return _combineStreams(globalStream, userStream).map((lists) {
      final global = lists[0];
      final personal = lists[1];
      final Map<String, Topic> combinedMap = {};
      for (var s in global) {
        combinedMap[s.id] = s;
      }
      for (var s in personal) {
        combinedMap[s.id] = s;
      }
      final sortedList = combinedMap.values.toList();
      sortedList
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return sortedList;
    });
  }

  // --- Units ---
  Stream<List<Unit>> getUnits(
      String subjectId, String categoryId, String topicId) {
    final globalStream = _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .collection('topics')
        .doc(topicId)
        .collection('units')
        .where('status', isEqualTo: UserConstants.statusApproved)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Unit.fromMap(doc.data(), doc.id);
      }).toList();
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return globalStream;

    final userStream = _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .collection('topics')
        .doc(topicId)
        .collection('units')
        .where('authorId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Unit.fromMap(doc.data(), doc.id);
      }).toList();
    });

    return _combineStreams(globalStream, userStream).map((lists) {
      final global = lists[0];
      final personal = lists[1];
      final Map<String, Unit> combinedMap = {};
      for (var s in global) {
        combinedMap[s.id] = s;
      }
      for (var s in personal) {
        combinedMap[s.id] = s;
      }
      final sortedList = combinedMap.values.toList();
      sortedList
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return sortedList;
    });
  }

  // --- Concepts ---
  Stream<List<Concept>> getConcepts(
      String subjectId, String categoryId, String topicId, String unitId) {
    final globalStream = _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .collection('topics')
        .doc(topicId)
        .collection('units')
        .doc(unitId)
        .collection('concepts')
        .where('status', isEqualTo: UserConstants.statusApproved)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Concept.fromMap(doc.data(), doc.id);
      }).toList();
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return globalStream;

    final userStream = _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .collection('topics')
        .doc(topicId)
        .collection('units')
        .doc(unitId)
        .collection('concepts')
        .where('authorId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Concept.fromMap(doc.data(), doc.id);
      }).toList();
    });

    return _combineStreams(globalStream, userStream).map((lists) {
      final global = lists[0];
      final personal = lists[1];
      final Map<String, Concept> combinedMap = {};
      for (var s in global) {
        combinedMap[s.id] = s;
      }
      for (var s in personal) {
        combinedMap[s.id] = s;
      }
      final sortedList = combinedMap.values.toList();
      sortedList
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return sortedList;
    });
  }

  // --- Learning Bites ---
  Stream<List<LearningBite>> getLearningBites(String subjectId,
      String categoryId, String topicId, String unitId, String conceptId) {
    final globalStream = _firestore
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
        .where('status', isEqualTo: UserConstants.statusApproved)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return LearningBite.fromMap(doc.data(), doc.id);
      }).toList();
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return globalStream;

    final userStream = _firestore
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
        .where('authorId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return LearningBite.fromMap(doc.data(), doc.id);
      }).toList();
    });

    return _combineStreams(globalStream, userStream).map((lists) {
      final global = lists[0];
      final personal = lists[1];
      final Map<String, LearningBite> combinedMap = {};
      for (var s in global) {
        combinedMap[s.id] = s;
      }
      for (var s in personal) {
        combinedMap[s.id] = s;
      }
      final sortedList = combinedMap.values.toList();
      sortedList
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return sortedList;
    });
  }

  // Fetch all learning bites created by a specific user (Private, Pending, etc.)
  Stream<List<LearningBite>> getUserLearningBites(String userId) {
    return _firestore
        .collectionGroup('learning_bites')
        .where('authorId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return LearningBite.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Fetch all pending learning bites for admins to review
  Stream<List<LearningBite>> getPendingLearningBites() {
    return _firestore
        .collectionGroup('learning_bites')
        .where('status', isEqualTo: UserConstants.statusPending)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return LearningBite.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Add a new user-generated learning bite
  Future<void> addLearningBite(
      String subjectId,
      String categoryId,
      String topicId,
      String unitId,
      String conceptId,
      LearningBite bite) async {
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
        .add(bite.toMap());
  }

  // --- Update Methods ---

  Future<void> updateSubject(
      String subjectId, Map<String, dynamic> data) async {
    await _firestore.collection('content_subjects').doc(subjectId).update(data);
  }

  Future<void> updateCategory(
      String subjectId, String categoryId, Map<String, dynamic> data) async {
    await _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .update(data);
  }

  Future<void> updateTopic(String subjectId, String categoryId, String topicId,
      Map<String, dynamic> data) async {
    await _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .collection('topics')
        .doc(topicId)
        .update(data);
  }

  Future<void> updateUnit(String subjectId, String categoryId, String topicId,
      String unitId, Map<String, dynamic> data) async {
    await _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .collection('topics')
        .doc(topicId)
        .collection('units')
        .doc(unitId)
        .update(data);
  }

  Future<void> updateConcept(
      String subjectId,
      String categoryId,
      String topicId,
      String unitId,
      String conceptId,
      Map<String, dynamic> data) async {
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
        .update(data);
  }

  Future<void> updateLearningBite(
      String subjectId,
      String categoryId,
      String topicId,
      String unitId,
      String conceptId,
      String learningBiteId,
      Map<String, dynamic> data) async {
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
        .update(data);
  }

  // --- Delete Methods for Hierarchy (User-owned) ---

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

    for (final lb in learningBites.docs) {
      await deleteLearningBite(
        subjectId: subjectId,
        categoryId: categoryId,
        topicId: topicId,
        unitId: unitId,
        conceptId: conceptId,
        learningBiteId: lb.id,
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
        conceptId: concept.id,
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
        .delete();
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
        unitId: unit.id,
      );
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
        subjectId: subjectId,
        categoryId: categoryId,
        topicId: topic.id,
      );
    }

    await _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .delete();
  }

  Future<void> deleteSubject({
    required String subjectId,
  }) async {
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

  // Update status (e.g., Approve/Reject by Admin, or make Public by User)
  Future<void> updateLearningBiteStatus(String path, String newStatus) async {
    // Note: path must be the full document path
    await _firestore.doc(path).update({'status': newStatus});
  }

  // --- Add Methods for Hierarchy ---

  Future<void> addSubject(Subject subject) async {
    await _firestore.collection('content_subjects').add(subject.toMap());
  }

  Future<void> addCategory(String subjectId, Category category) async {
    await _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .add(category.toMap());
  }

  Future<void> addTopic(
      String subjectId, String categoryId, Topic topic) async {
    await _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .collection('topics')
        .add(topic.toMap());
  }

  Future<void> addUnit(
      String subjectId, String categoryId, String topicId, Unit unit) async {
    await _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .collection('topics')
        .doc(topicId)
        .collection('units')
        .add(unit.toMap());
  }

  Future<void> addConcept(String subjectId, String categoryId, String topicId,
      String unitId, Concept concept) async {
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
        .add(concept.toMap());
  }

  // --- Tasks ---
  Future<List<Task>> getTasks(
    String subjectId,
    String categoryId,
    String topicId,
    String unitId,
    String conceptId,
    String learningBiteId,
  ) async {
    final snapshot = await _firestore
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

    return snapshot.docs.map((doc) {
      return Task.fromMap(doc.data(), doc.id);
    }).toList();
  }

  // --- Single Item Fetchers (for Resume/Navigation) ---
  Future<Subject> getSubject(String subjectId) async {
    final doc =
        await _firestore.collection('content_subjects').doc(subjectId).get();
    return Subject.fromMap(doc.data()!, doc.id);
  }

  Future<Category> getCategory(String subjectId, String categoryId) async {
    final doc = await _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .get();
    return Category.fromMap(doc.data()!, doc.id);
  }

  Future<Topic> getTopic(
      String subjectId, String categoryId, String topicId) async {
    final doc = await _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .collection('topics')
        .doc(topicId)
        .get();
    return Topic.fromMap(doc.data()!, doc.id);
  }

  Future<Unit> getUnit(String subjectId, String categoryId, String topicId,
      String unitId) async {
    final doc = await _firestore
        .collection('content_subjects')
        .doc(subjectId)
        .collection('categories')
        .doc(categoryId)
        .collection('topics')
        .doc(topicId)
        .collection('units')
        .doc(unitId)
        .get();
    return Unit.fromMap(doc.data()!, doc.id);
  }

  Future<Concept> getConcept(String subjectId, String categoryId,
      String topicId, String unitId, String conceptId) async {
    final doc = await _firestore
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
        .get();
    return Concept.fromMap(doc.data()!, doc.id);
  }

  Future<LearningBite> getLearningBite(
      String subjectId,
      String categoryId,
      String topicId,
      String unitId,
      String conceptId,
      String learningBiteId) async {
    final doc = await _firestore
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
        .get();
    return LearningBite.fromMap(doc.data()!, doc.id);
  }

  // Helper to combine two streams of lists so that the output updates whenever *either* input updates.
  Stream<List<List<T>>> _combineStreams<T>(
      Stream<List<T>> stream1, Stream<List<T>> stream2) {
    // ignore: close_sinks
    final controller = StreamController<List<List<T>>>();
    List<T> list1 = [];
    List<T> list2 = [];
    bool hasEmitted1 = false;
    bool hasEmitted2 = false;

    void update() {
      if (hasEmitted1 && hasEmitted2 && !controller.isClosed) {
        controller.add([list1, list2]);
      }
    }

    StreamSubscription? sub1;
    StreamSubscription? sub2;

    controller.onListen = () {
      sub1 = stream1.listen((data) {
        list1 = data;
        hasEmitted1 = true;
        update();
      }, onError: controller.addError);

      sub2 = stream2.listen((data) {
        list2 = data;
        hasEmitted2 = true;
        update();
      }, onError: controller.addError);
    };

    controller.onCancel = () async {
      await sub1?.cancel();
      await sub2?.cancel();
    };

    return controller.stream;
  }
}
