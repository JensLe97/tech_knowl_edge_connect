import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tech_knowl_edge_connect/models/ai_tech/session_type.dart';
import 'package:tech_knowl_edge_connect/models/ai_tech/ai_tech_message.dart';
import 'package:tech_knowl_edge_connect/models/ai_tech/ai_tech_session.dart';
import 'package:tech_knowl_edge_connect/services/content/progress_service.dart';

class AiTechService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final ProgressService _progressService = ProgressService();

  // --- Journey ---

  Future<void> createJourneyWithId(
      String journeyId, Map<String, dynamic> journeyData) async {
    final journeyRef = firestore.collection('ai_tech_journeys').doc(journeyId);
    await journeyRef.set(journeyData);
  }

  /// Create a new learning journey document
  Future<void> createLearningJourneyDoc({
    required String journeyId,
    required String userId,
    required String goal,
    required List<String> preferredSubjects,
    required int length,
    required String sessionId,
    String? userMessage,
    String? instruction,
    String? context,
  }) async {
    final journeyRef = firestore.collection('ai_tech_journeys').doc(journeyId);
    await journeyRef.set({
      'id': journeyId,
      'userId': userId,
      'goal': goal,
      'preferredSubjects': preferredSubjects,
      'length': length,
      'sessionId': sessionId,
      'createdAt': DateTime.now(),
      'status': 'pending',
      if (userMessage != null) 'userMessage': userMessage,
      if (instruction != null && instruction.isNotEmpty)
        'instruction': instruction,
      if (context != null && context.isNotEmpty) 'context': context,
    });
  }

  /// Update a learning journey document
  Future<void> updateLearningJourneyDoc({
    required String journeyId,
    required Map<String, dynamic> updateData,
  }) async {
    final journeyRef = firestore.collection('ai_tech_journeys').doc(journeyId);
    await journeyRef.update(updateData);
  }

  /// Stream all journeys for a session
  Stream<QuerySnapshot<Map<String, dynamic>>> streamJourneys(String sessionId) {
    return firestore
        .collection('ai_tech_journeys')
        .where('sessionId', isEqualTo: sessionId)
        .snapshots();
  }

  /// Get a journey document by ID
  Future<Map<String, dynamic>?> getJourneyById(String journeyId) async {
    final docSnap =
        await firestore.collection('ai_tech_journeys').doc(journeyId).get();
    if (docSnap.exists) {
      return docSnap.data() as Map<String, dynamic>;
    }
    return null;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getJourney(String journeyId) {
    return firestore.collection('ai_tech_journeys').doc(journeyId).snapshots();
  }

  // --- Learning Bites ---

  Future<DocumentReference<Map<String, dynamic>>> createLearningBite({
    required String journeyId,
    required String title,
    required List<String> content,
    required String type,
    required String status,
    required int version,
    required String userId,
    required Map<String, dynamic> iconData,
  }) async {
    final docRef = firestore
        .collection('ai_tech_journeys')
        .doc(journeyId)
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

  /// Stream all learning bites for a journey
  Stream<QuerySnapshot<Map<String, dynamic>>> streamLearningBites(
      String journeyId) {
    return firestore
        .collection('ai_tech_journeys')
        .doc(journeyId)
        .collection('learning_bites')
        .orderBy('createdAt')
        .snapshots();
  }

  /// Stream a learning bite document by journeyId and learningBiteId
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamLearningBite(
      String journeyId, String learningBiteId) {
    return firestore
        .collection('ai_tech_journeys')
        .doc(journeyId)
        .collection('learning_bites')
        .doc(learningBiteId)
        .snapshots();
  }

  /// Get all learning bites for a journey
  Future<List<Map<String, dynamic>>> getLearningBitesForJourney(
      String journeyId) async {
    final bitesSnap = await firestore
        .collection('ai_tech_journeys')
        .doc(journeyId)
        .collection('learning_bites')
        .get();
    return bitesSnap.docs.map((doc) => doc.data()).toList();
  }

  /// Returns bite results (title, points, maxPoints) stored in the user's
  /// resumeProgress for the given journey. These reflect actual user scores.
  Future<List<Map<String, dynamic>>> getBiteResultsForJourney(
      String userId, String journeyId) async {
    return _progressService.getBiteResultsForJourney(userId, journeyId);
  }

  // --- Tasks ---

  /// Adds a learning bite and its tasks to a journey in Firestore
  Future<void> addLearningBiteWithTasks({
    required String journeyId,
    required Map<String, dynamic> bite,
    required List<Map<String, dynamic>> tasks,
    String? userId,
  }) async {
    final biteRef = firestore
        .collection('ai_tech_journeys')
        .doc(journeyId)
        .collection('learning_bites')
        .doc();
    await biteRef.set({
      'title': bite['title'],
      'content': bite['content'],
      'type': bite['type'],
      'status': bite['status'],
      'version': bite['version'],
      'iconData': bite['iconData'],
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
    for (final task in tasks) {
      await biteRef.collection('tasks').add({
        'type': task['type'],
        'question': task['question'],
        'correctAnswer': task['correctAnswer'],
        'answers': task['answers'],
        'createdAt': Timestamp.now(),
      });
    }
    // If a userId was provided (typical when creating journeys for a user),
    // increment their unit's expected bite count so progress uses the
    // updated total.
    if (userId != null) {
      try {
        // Prefer incrementing the session-level unit expected count. If the
        // journey has a `sessionId` field, use that as the unitId; otherwise
        // fall back to the journeyId.
        String targetUnit = journeyId;
        try {
          final journeyDoc = await firestore
              .collection('ai_tech_journeys')
              .doc(journeyId)
              .get();
          if (journeyDoc.exists) {
            final sessionId = (journeyDoc.data()?['sessionId'] as String?);
            if (sessionId != null && sessionId.isNotEmpty) {
              targetUnit = sessionId;
            }
          }
        } catch (_) {}
        await _progressService.changeExpectedBiteCount(userId, targetUnit, 1);
      } catch (_) {}
    }
  }

  /// Add learning bite tasks to a journey
  Future<void> addLearningBiteTasks({
    required String journeyId,
    required List<Map<String, dynamic>> tasks,
  }) async {
    final tasksRef = firestore
        .collection('ai_tech_journeys')
        .doc(journeyId)
        .collection('learning_bites')
        .doc()
        .collection('tasks');
    for (final task in tasks) {
      await tasksRef.add(task);
    }
  }

  /// Stream tasks for a learning bite by journeyId and learningBiteId
  Stream<QuerySnapshot<Map<String, dynamic>>> streamTasks(
      String journeyId, String learningBiteId) {
    return firestore
        .collection('ai_tech_journeys')
        .doc(journeyId)
        .collection('learning_bites')
        .doc(learningBiteId)
        .collection('tasks')
        .orderBy('createdAt')
        .snapshots();
  }

  // --- Messages ---

  /// Add a message to a session transcript
  Future<void> addMessage(String sessionId, AiTechMessage message) async {
    final msgRef = firestore
        .collection('ai_tech_sessions')
        .doc(sessionId)
        .collection('messages')
        .doc();
    await msgRef.set(message.toMap());
    // Update session's lastTimestamp to the message timestamp
    try {
      await firestore
          .collection('ai_tech_sessions')
          .doc(sessionId)
          .update({'lastTimestamp': message.ts});
    } catch (e) {
      // ignore errors updating lastTimestamp to avoid breaking message writes
    }
  }

  Future<List<AiTechMessage>> getSessionMessages(String sessionId) async {
    final snap = await firestore
        .collection('ai_tech_sessions')
        .doc(sessionId)
        .collection('messages')
        .orderBy('ts', descending: false)
        .get();
    return snap.docs.map((doc) => AiTechMessage.fromMap(doc.data())).toList();
  }

  Stream<QuerySnapshot> streamMessages(String sessionId, String userId) {
    return firestore
        .collection('ai_tech_sessions')
        .doc(sessionId)
        .collection('messages')
        // .where(Filter('senderId', isEqualTo: userId))
        .orderBy('ts', descending: false)
        .snapshots();
  }

  // --- Session ---

  // --- AI Tech Sessions ---
  Stream<QuerySnapshot<Map<String, dynamic>>> streamSessions(String userId) {
    return FirebaseFirestore.instance
        .collection('ai_tech_sessions')
        .where('userId', isEqualTo: userId)
        .orderBy('lastTimestamp', descending: true)
        .snapshots();
  }

  /// Fetch a session document and return its display title (`unit` or `title`).
  Future<String?> fetchSessionTitle(String sessionId) async {
    try {
      final snap =
          await firestore.collection('ai_tech_sessions').doc(sessionId).get();
      if (!snap.exists) return null;
      final data = snap.data();
      return (data?['unit'] as String?) ?? (data?['title'] as String?);
    } catch (_) {
      return null;
    }
  }

  /// Stream the session's display title (`unit` or `title`). Emits empty string
  /// when no title is present.
  Stream<String> streamSessionTitle(String sessionId) {
    return firestore
        .collection('ai_tech_sessions')
        .doc(sessionId)
        .snapshots()
        .map((snap) {
      try {
        return (snap.data()?['unit'] as String?) ??
            (snap.data()?['title'] as String?) ??
            '';
      } catch (_) {
        return '';
      }
    }).distinct();
  }

  /// Stream a content unit title by watching collectionGroup('units') and
  /// returning the name/title for the matching unit id. Emits empty string
  /// when not found.
  Stream<String> streamContentUnitTitle(String unitId) {
    return firestore.collectionGroup('units').snapshots().map((snap) {
      try {
        for (final doc in snap.docs) {
          if (doc.id == unitId) {
            final data = doc.data() as Map<String, dynamic>?;
            return (data?['name'] as String?) ??
                (data?['title'] as String?) ??
                '';
          }
        }
      } catch (_) {}
      return '';
    }).distinct();
  }

  /// Convenience method: return a stream that yields the authoritative title
  /// for a unit. If `subjectId` is empty, treat the unit as a session and
  /// stream the session title; otherwise stream the content unit title.
  Stream<String> streamUnitTitle(
      {required String unitId, required String subjectId}) {
    if (subjectId.isEmpty) {
      return streamSessionTitle(unitId);
    }
    return streamContentUnitTitle(unitId);
  }

  /// Start a new AI Tech session (study, review, or journey)
  Future<String> startSession({
    required SessionType type,
    required String concept,
    String? learningBiteId,
  }) async {
    final sessionRef = firestore.collection('ai_tech_sessions').doc();
    final session = AiTechSession(
      sessionId: sessionRef.id,
      userId: auth.currentUser!.uid,
      startAt: DateTime.now(),
      lastTimestamp: DateTime.now(),
      sessionType: type,
      unit: concept,
    );
    await sessionRef.set(session.toMap());
    return sessionRef.id;
  }

  Future<void> endSession(String sessionId) async {
    final sessionRef = firestore.collection('ai_tech_sessions').doc(sessionId);
    await sessionRef.update({'endAt': DateTime.now()});
  }

  /// Update the `unit` (title) field of an existing session document.
  Future<void> updateSessionUnit(String sessionId, String unit) async {
    await firestore
        .collection('ai_tech_sessions')
        .doc(sessionId)
        .update({'unit': unit});
  }

  /// Delete a session and its messages (deletes messages in batches)
  Future<void> deleteSession(String sessionId, {String? userId}) async {
    // Delete uploaded attachment files from Storage
    if (userId != null) {
      try {
        final storageRef = FirebaseStorage.instance
            .ref('ai_tech_attachments/$userId/$sessionId');
        final listed = await storageRef.listAll();
        await Future.wait(listed.items.map((item) => item.delete()));
      } catch (_) {}
    }

    final sessionRef = firestore.collection('ai_tech_sessions').doc(sessionId);
    final messagesColl = sessionRef.collection('messages');
    const int batchSize = 500;
    // Delete messages in batches to avoid large writes
    while (true) {
      final snap = await messagesColl.limit(batchSize).get();
      if (snap.docs.isEmpty) break;
      final batch = firestore.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      if (snap.docs.length < batchSize) break;
    }
    // Delete related journeys for this session
    final journeysQuery = await firestore
        .collection('ai_tech_journeys')
        .where('sessionId', isEqualTo: sessionId)
        .get();
    for (final jdoc in journeysQuery.docs) {
      final journeyRef = jdoc.reference;
      final learningBitesColl = journeyRef.collection('learning_bites');
      // collect bite ids for downstream cleanup
      final List<String> journeyBiteIds = [];
      // Delete learning bites and their tasks in batches
      while (true) {
        final lbSnap = await learningBitesColl.limit(batchSize).get();
        if (lbSnap.docs.isEmpty) break;
        // For each learning bite, delete nested tasks fully and then the bite doc
        for (final lb in lbSnap.docs) {
          journeyBiteIds.add(lb.id);
          final tasksColl = lb.reference.collection('tasks');
          while (true) {
            final tSnap = await tasksColl.limit(batchSize).get();
            if (tSnap.docs.isEmpty) break;
            final tBatch = firestore.batch();
            for (final tdoc in tSnap.docs) {
              tBatch.delete(tdoc.reference);
            }
            await tBatch.commit();
            if (tSnap.docs.length < batchSize) break;
          }
          // delete the learning bite itself
          await lb.reference.delete();
        }
        if (lbSnap.docs.length < batchSize) break;
      }
      // Attempt to remove references to these learning bites for the session owner
      if (userId != null && journeyBiteIds.isNotEmpty) {
        try {
          final userDocRef = firestore.collection('Users').doc(userId);
          await userDocRef.update({
            'completedLearningBiteIds': FieldValue.arrayRemove(journeyBiteIds)
          });

          final resumeColl = userDocRef.collection('resumeProgress');
          final resumeSnap = await resumeColl.get();
          for (final rdoc in resumeSnap.docs) {
            final data = rdoc.data();
            final bites = Map<String, dynamic>.from(
                data['bites'] as Map<String, dynamic>? ?? {});
            bool mutated = false;
            for (final bid in journeyBiteIds) {
              if (bites.containsKey(bid)) {
                bites.remove(bid);
                mutated = true;
              }
            }
            if (mutated) {
              if (bites.isEmpty) {
                await rdoc.reference.delete();
              } else {
                final biteValues = bites.values
                    .map((e) =>
                        (e as Map<String, dynamic>)['progress'] as num? ?? 0)
                    .toList();
                final expected = (data['expectedBiteCount'] as num?)?.toInt() ??
                    biteValues.length;
                final agg = biteValues.isEmpty
                    ? 0
                    : (biteValues.reduce((a, b) => a + b) /
                            (expected > 0 ? expected : biteValues.length))
                        .round();
                await rdoc.reference.update({
                  'bites': bites,
                  'progress': agg,
                  'status': agg >= 100 ? 'completed' : 'in_progress',
                  'lastUpdated': FieldValue.serverTimestamp(),
                });
              }
            }
          }
        } catch (_) {}
      }
      // delete the journey doc
      await journeyRef.delete();
    }

    // finally delete the session document
    await sessionRef.delete();
  }
}
