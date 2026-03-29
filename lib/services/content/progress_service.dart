import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tech_knowl_edge_connect/components/user/user_constants.dart';

class UnitBiteProgress {
  final String biteId;
  final String? conceptId;
  final String? journeyId;
  final String? categoryId;
  final String? topicId;
  final String status; // not_started | in_progress | completed
  final int progress; // 0-100
  final int points; // earned points
  final int maxPoints; // total possible points
  final Timestamp? lastUpdated;
  final Timestamp? createdAt;
  final int? currentTaskIndex;
  final Map<String, TaskProgress> tasks;

  UnitBiteProgress({
    required this.biteId,
    this.conceptId,
    this.journeyId,
    this.categoryId,
    this.topicId,
    required this.status,
    required this.progress,
    this.points = 0,
    this.maxPoints = 0,
    this.lastUpdated,
    this.createdAt,
    this.currentTaskIndex,
    this.tasks = const {},
  });

  Map<String, dynamic> toMap() => {
        'biteId': biteId,
        if (conceptId != null) 'conceptId': conceptId,
        if (journeyId != null) 'journeyId': journeyId,
        if (categoryId != null) 'categoryId': categoryId,
        if (topicId != null) 'topicId': topicId,
        'status': status,
        'progress': progress,
        if (points > 0) 'points': points,
        if (maxPoints > 0) 'maxPoints': maxPoints,
        'lastUpdated': lastUpdated ?? FieldValue.serverTimestamp(),
        if (createdAt != null) 'createdAt': createdAt,
        'currentTaskIndex': currentTaskIndex ?? 0,
        'tasks': tasks.map((k, v) => MapEntry(k, v.toMap())),
      };

  factory UnitBiteProgress.fromMap(Map<String, dynamic> map) {
    final rawTasks = map['tasks'] as Map<String, dynamic>?;
    final parsedTasks = rawTasks != null
        ? rawTasks.map((k, v) =>
            MapEntry(k, TaskProgress.fromMap(v as Map<String, dynamic>)))
        : <String, TaskProgress>{};
    return UnitBiteProgress(
      biteId: map['biteId'] as String,
      conceptId: map['conceptId'] as String?,
      journeyId: map['journeyId'] as String?,
      categoryId: map['categoryId'] as String?,
      topicId: map['topicId'] as String?,
      status: map['status'] as String? ?? 'not_started',
      progress: (map['progress'] as num?)?.toInt() ?? 0,
      points: (map['points'] as num?)?.toInt() ?? 0,
      maxPoints: (map['maxPoints'] as num?)?.toInt() ?? 0,
      lastUpdated: map['lastUpdated'] as Timestamp?,
      createdAt: map['createdAt'] as Timestamp?,
      currentTaskIndex: (map['currentTaskIndex'] as num?)?.toInt(),
      tasks: parsedTasks,
    );
  }
}

class TaskProgress {
  final String taskId;
  final String type;
  final String status; // not_started | completed
  final int progress; // 0-100
  final Timestamp? lastUpdated;

  TaskProgress({
    required this.taskId,
    required this.type,
    required this.status,
    required this.progress,
    this.lastUpdated,
  });

  Map<String, dynamic> toMap() => {
        'taskId': taskId,
        'type': type,
        'status': status,
        'progress': progress,
        'lastUpdated': lastUpdated ?? FieldValue.serverTimestamp(),
      };

  factory TaskProgress.fromMap(Map<String, dynamic> map) {
    return TaskProgress(
      taskId: map['taskId'] as String,
      type: map['type'] as String? ?? '',
      status: map['status'] as String? ?? 'not_started',
      progress: (map['progress'] as num?)?.toInt() ?? 0,
      lastUpdated: map['lastUpdated'] as Timestamp?,
    );
  }
}

class UnitProgress {
  final String unitId;
  final String subjectId;
  final String source; // search | ai_generated
  final String status; // not_started | in_progress | completed
  final int progress; // 0-100 aggregate
  final int expectedBiteCount;
  final Map<String, UnitBiteProgress> bites;
  final Timestamp? lastUpdated;

  UnitProgress({
    required this.unitId,
    required this.subjectId,
    required this.source,
    required this.status,
    required this.progress,
    required this.expectedBiteCount,
    required this.bites,
    this.lastUpdated,
  });

  Map<String, dynamic> toMap() => {
        'unitId': unitId,
        'subjectId': subjectId,
        'source': source,
        'status': status,
        'expectedBiteCount': expectedBiteCount,
        'progress': progress,
        'bites': bites.map((k, v) => MapEntry(k, v.toMap())),
        'lastUpdated': lastUpdated ?? FieldValue.serverTimestamp(),
      };

  factory UnitProgress.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final bitesMap = <String, UnitBiteProgress>{};
    final rawBites = data['bites'] as Map<String, dynamic>? ?? {};
    rawBites.forEach((k, v) {
      if (v is Map<String, dynamic>) {
        bitesMap[k] = UnitBiteProgress.fromMap(v);
      }
    });
    return UnitProgress(
      unitId: data['unitId'] as String? ?? doc.id,
      subjectId: data['subjectId'] as String? ?? '',
      source: data['source'] as String? ?? 'search',
      status: data['status'] as String? ?? 'not_started',
      expectedBiteCount:
          (data['expectedBiteCount'] as num?)?.toInt() ?? bitesMap.length,
      progress: (data['progress'] as num?)?.toInt() ??
          _calcProgressFromBites(
              bitesMap, (data['expectedBiteCount'] as num?)?.toInt()),
      bites: bitesMap,
      lastUpdated: data['lastUpdated'] as Timestamp?,
    );
  }

  static int _calcProgressFromBites(Map<String, UnitBiteProgress> bites,
      [int? expectedTotal]) {
    if (bites.isEmpty && (expectedTotal == null || expectedTotal == 0)) {
      return 0;
    }
    final totalProgress =
        bites.values.map((b) => b.progress).fold<int>(0, (a, b) => a + b);
    final denom = (expectedTotal != null && expectedTotal > 0)
        ? expectedTotal
        : bites.length;
    if (denom == 0) return 0;
    return (totalProgress / denom).round();
  }
}

class ProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userProgressColl(String uid) =>
      _firestore.collection('Users').doc(uid).collection('resumeProgress');

  /// Adjust the expected bite count for a user's unit document. `delta` can
  /// be positive (increment) or negative (decrement). This updates
  /// `expectedBiteCount`, recalculates aggregate progress and status.
  Future<void> changeExpectedBiteCount(
      String uid, String unitId, int delta) async {
    final docRef = _userProgressColl(uid).doc(unitId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) {
        return;
      }
      final data = snap.data() as Map<String, dynamic>;
      final bites = Map<String, dynamic>.from(
          data['bites'] as Map<String, dynamic>? ?? {});
      final current = (data['expectedBiteCount'] as num?)?.toInt() ??
          (bites.isEmpty ? 1 : bites.length);
      final updated = (current + delta) < 0 ? 0 : (current + delta);

      final biteValues = bites.values
          .map((e) => (e as Map<String, dynamic>)['progress'] as num? ?? 0)
          .toList();
      final agg = biteValues.isEmpty
          ? 0
          : (biteValues.reduce((a, b) => a + b) /
                  (updated > 0 ? updated : biteValues.length))
              .round();
      tx.update(docRef, {
        'expectedBiteCount': updated,
        'progress': agg >= 100 ? 100 : agg,
        'status': agg >= 100 ? 'completed' : 'in_progress',
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    });
  }

  Stream<List<UnitProgress>> subscribeUserUnits(String uid) {
    return _userProgressColl(uid).snapshots().map((snap) => snap.docs
        .map((d) => UnitProgress.fromDoc(d))
        .where((u) => u.status == 'in_progress')
        .toList());
  }

  /// Attach a standalone bite to a unit. If unitId is null, this will create a
  /// minimal synthetic unit document and attach the bite there. Optionally
  /// include `conceptId` and `tasks` metadata so resume UI doesn't need to
  /// perform collectionGroup lookups at display time.
  Future<void> startOrAttachBite(String uid,
      {required String biteId,
      String? unitId,
      String? subjectId,
      String? categoryId,
      String? topicId,
      String? conceptId,
      String? journeyId,
      Map<String, TaskProgress>? tasks,
      int initialProgress = 0}) async {
    final coll = _userProgressColl(uid);
    String targetUnitId = unitId ?? _firestore.collection('tmp').doc().id;
    final docRef = coll.doc(targetUnitId);

    // Determine an appropriate expected bite count when creating a new
    // unit document: if a content path (subject/category/topic/unit/concept)
    // is provided, count the learning_bites in that concept so progress
    // percentages reflect the full concept size. Fallback to 1 if unknown.
    int computedExpected = 1;
    if (subjectId != null &&
        categoryId != null &&
        topicId != null &&
        unitId != null) {
      try {
        // Count all learning_bites across all concepts within the unit
        final conceptsSnap = await _firestore
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
        int total = 0;
        for (final conceptDoc in conceptsSnap.docs) {
          try {
            final lbSnap =
                await conceptDoc.reference.collection('learning_bites').get();
            for (final doc in lbSnap.docs) {
              final data = doc.data();
              final String? status = data['status'] as String?;
              final String? authorId = data['authorId'] as String?;
              // status and authorId are expected on learning_bites; if missing, this bite is simply not counted.
              // Always count approved bites. Also count unapproved bites if the logged-in user is the author.
              if (status == UserConstants.statusApproved || authorId == uid) {
                total += 1;
              }
            }
          } catch (_) {}
        }
        computedExpected = total > 0 ? total : 1;
      } catch (_) {
        computedExpected = 1;
      }
    } else if (subjectId == null) {
      // For AI sessions, unitId represents a session id. Count all learning
      // bites across all journeys that belong to this session so the
      // expectedBiteCount reflects the full session size.
      try {
        int total = 0;
        final journeysSnap = await _firestore
            .collection('ai_tech_journeys')
            .where('sessionId', isEqualTo: unitId)
            .get();
        for (final journeyDoc in journeysSnap.docs) {
          try {
            final lbSnap =
                await journeyDoc.reference.collection('learning_bites').get();
            total += lbSnap.docs.length;
          } catch (_) {}
        }
        computedExpected = total > 0 ? total : 1;
      } catch (_) {
        computedExpected = 1;
      }
    }

    await _firestore.runTransaction((tx) async {
      final snapshot = await tx.get(docRef);
      if (!snapshot.exists) {
        // If the initial progress already marks the bite/unit as completed,
        // don't create a resumeProgress document — completed units should
        // not remain in the resume collection.
        if (initialProgress >= 100) {
          return;
        }
        tx.set(docRef, {
          'unitId': targetUnitId,
          'subjectId': subjectId ?? '',
          'source': subjectId == null ? 'ai_generated' : 'search',
          'status': 'in_progress',
          'bites': {
            biteId: {
              'biteId': biteId,
              if (conceptId != null) 'conceptId': conceptId,
              if (categoryId != null) 'categoryId': categoryId,
              if (topicId != null) 'topicId': topicId,
              if (journeyId != null) 'journeyId': journeyId,
              'status': 'in_progress',
              'progress': initialProgress,
              'lastUpdated': FieldValue.serverTimestamp(),
              'createdAt': FieldValue.serverTimestamp(),
              'currentTaskIndex': 0,
              'tasks': tasks?.map((k, v) => MapEntry(k, v.toMap())) ?? {},
            }
          },
          'expectedBiteCount': computedExpected,
          'progress': initialProgress,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        return;
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final bites = Map<String, dynamic>.from(
          data['bites'] as Map<String, dynamic>? ?? {});
      final existingBite = Map<String, dynamic>.from(
          bites[biteId] as Map<String, dynamic>? ?? {});
      final wasCompleted =
          ((existingBite['progress'] as num?)?.toInt() ?? 0) >= 100 ||
              (existingBite['status'] as String? ?? '') == 'completed';
      existingBite['biteId'] = biteId;
      // only set status/progress when the bite is not already completed
      if (!wasCompleted) {
        existingBite['status'] =
            initialProgress >= 100 ? 'completed' : 'in_progress';
        existingBite['progress'] = initialProgress;
      }
      existingBite['lastUpdated'] = FieldValue.serverTimestamp();
      existingBite['createdAt'] =
          existingBite['createdAt'] ?? FieldValue.serverTimestamp();
      existingBite['currentTaskIndex'] = existingBite['currentTaskIndex'] ?? 0;
      if (conceptId != null) existingBite['conceptId'] = conceptId;
      if (categoryId != null) existingBite['categoryId'] = categoryId;
      if (topicId != null) existingBite['topicId'] = topicId;
      if (journeyId != null) existingBite['journeyId'] = journeyId;
      if (tasks != null) {
        existingBite['tasks'] = tasks.map((k, v) => MapEntry(k, v.toMap()));
      }
      bites[biteId] = existingBite;
      // recalc progress
      final biteValues = bites.values
          .map((e) => (e as Map<String, dynamic>)['progress'] as num? ?? 0)
          .toList();
      final expected =
          (data['expectedBiteCount'] as num?)?.toInt() ?? biteValues.length;
      final agg = biteValues.isEmpty
          ? 0
          : (biteValues.reduce((a, b) => a + b) /
                  (expected > 0 ? expected : biteValues.length))
              .round();

      tx.update(docRef, {
        'bites': bites,
        'progress': agg >= 100 ? 100 : agg,
        'status': agg >= 100 ? 'completed' : 'in_progress',
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> updateBiteProgress(String uid,
      {required String unitId,
      required String biteId,
      required int progress,
      String status = 'in_progress',
      int? currentTaskIndex,
      int? points,
      int? maxPoints}) async {
    final docRef = _userProgressColl(uid).doc(unitId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) return;
      final data = snap.data() as Map<String, dynamic>;
      final bites = Map<String, dynamic>.from(
          data['bites'] as Map<String, dynamic>? ?? {});
      final existing = Map<String, dynamic>.from(
          bites[biteId] as Map<String, dynamic>? ?? {});
      existing['progress'] = progress;
      existing['status'] = status;
      existing['lastUpdated'] = FieldValue.serverTimestamp();
      if (currentTaskIndex != null) {
        existing['currentTaskIndex'] = currentTaskIndex;
      }
      if (points != null) existing['points'] = points;
      if (maxPoints != null) existing['maxPoints'] = maxPoints;
      bites[biteId] = existing;

      final biteValues = bites.values
          .map((e) => (e as Map<String, dynamic>)['progress'] as num? ?? 0)
          .toList();
      final expected =
          (data['expectedBiteCount'] as num?)?.toInt() ?? biteValues.length;
      final agg = biteValues.isEmpty
          ? 0
          : (biteValues.reduce((a, b) => a + b) /
                  (expected > 0 ? expected : biteValues.length))
              .round();

      tx.update(docRef, {
        'bites': bites,
        'progress': agg >= 100 ? 100 : agg,
        'status': agg >= 100 ? 'completed' : 'in_progress',
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<UnitProgress?> getUnitProgress(String uid, String unitId) async {
    final doc = await _userProgressColl(uid).doc(unitId).get();
    if (!doc.exists) return null;
    return UnitProgress.fromDoc(doc);
  }

  /// Returns bite results (title, points, maxPoints) for all bites belonging
  /// to [journeyId] stored in the user's resumeProgress collection.
  Future<List<Map<String, dynamic>>> getBiteResultsForJourney(
      String uid, String journeyId) async {
    final snap = await _userProgressColl(uid).get();
    final results = <Map<String, dynamic>>[];
    for (final doc in snap.docs) {
      final data = doc.data();
      final bites = data['bites'] as Map<String, dynamic>? ?? {};
      for (final bite in bites.values) {
        if (bite is Map<String, dynamic> &&
            (bite['journeyId'] as String?) == journeyId) {
          final String biteId = (bite['biteId'] as String?) ?? '';
          String title = '';
          try {
            if (biteId.isNotEmpty) {
              final docRef = await _firestore
                  .collection('ai_tech_journeys')
                  .doc(journeyId)
                  .collection('learning_bites')
                  .doc(biteId)
                  .get();
              if (docRef.exists) {
                title = (docRef.data()?['title'] as String?) ?? '';
              }
            }
          } catch (_) {}
          results.add({
            'title': title,
            'biteId': biteId,
            'points': (bite['points'] as num?)?.toInt() ?? 0,
            'maxPoints': (bite['maxPoints'] as num?)?.toInt() ?? 0,
            'status': bite['status'] as String? ?? 'not_started',
          });
        }
      }
    }
    return results;
  }

  /// Set a resume pointer as a document under
  /// `users/{uid}/resumeProgress/{learningBiteId}`. The document contains
  /// the content path fields and a timestamp. This replaces the previous
  /// nested `resumeProgress.{subjectId}` map approach.
  Future<void> setResumePointer(String uid,
      {required String learningBiteId,
      required String subjectId,
      required String categoryId,
      required String topicId,
      required String unitId,
      required String conceptId}) async {
    // Attach the bite into the unit document under users/{uid}/resumeProgress/{unitId}
    // by reusing startOrAttachBite which ensures a unit doc with a `bites` map.
    await startOrAttachBite(uid,
        biteId: learningBiteId,
        unitId: unitId,
        subjectId: subjectId,
        categoryId: categoryId,
        topicId: topicId,
        conceptId: conceptId,
        initialProgress: 0);
  }

  /// Remove a resume pointer (bite entry) from whichever unit document
  /// contains it. If the unit becomes empty, delete the unit document.
  Future<void> removeResumePointer(String uid, String learningBiteId) async {
    final coll = _userProgressColl(uid);
    final snap = await coll.get();
    for (final doc in snap.docs) {
      final data = doc.data();
      final bites = Map<String, dynamic>.from(
          data['bites'] as Map<String, dynamic>? ?? {});
      if (bites.containsKey(learningBiteId)) {
        // If the bite is already completed, keep its entry so progress
        // history and UI checkmarks remain visible. Only remove resume
        // entries for bites that are not completed.
        final existing = Map<String, dynamic>.from(
            bites[learningBiteId] as Map<String, dynamic>? ?? {});
        final wasCompleted =
            ((existing['progress'] as num?)?.toInt() ?? 0) >= 100 ||
                (existing['status'] as String? ?? '') == 'completed';
        if (!wasCompleted) {
          bites.remove(learningBiteId);
          if (bites.isEmpty) {
            await doc.reference.delete();
          } else {
            final biteValues = bites.values
                .map(
                    (e) => (e as Map<String, dynamic>)['progress'] as num? ?? 0)
                .toList();
            final expected = (data['expectedBiteCount'] as num?)?.toInt() ??
                biteValues.length;
            final agg = biteValues.isEmpty
                ? 0
                : (biteValues.reduce((a, b) => a + b) /
                        (expected > 0 ? expected : biteValues.length))
                    .round();
            await doc.reference.update({
              'bites': bites,
              'progress': agg >= 100 ? 100 : agg,
              'status': agg >= 100 ? 'completed' : 'in_progress',
              'lastUpdated': FieldValue.serverTimestamp(),
            });
          }
        } else {
          // preserve completed bite; optionally touch timestamp so listeners
          // see a small update without removing the entry.
          await doc.reference
              .update({'lastUpdated': FieldValue.serverTimestamp()});
        }
        break;
      }
    }
  }
}
