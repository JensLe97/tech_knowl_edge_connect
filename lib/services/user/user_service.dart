import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:tech_knowl_edge_connect/models/user/report_reason.dart';
import 'package:tech_knowl_edge_connect/services/content/progress_service.dart';
import 'package:tech_knowl_edge_connect/services/content/content_service.dart';

class UserService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ProgressService _progressService = ProgressService();
  final ContentService _contentService = ContentService();

  Future<void> blockUser(String receiverId) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(_firebaseAuth.currentUser!.uid)
        .update({
      'blockedUsers': FieldValue.arrayUnion([receiverId]),
    });
  }

  Stream<List<String>> getCompletedLearningBites() {
    return FirebaseFirestore.instance
        .collection('Users')
        .doc(_firebaseAuth.currentUser!.uid)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();
      if (data == null || !data.containsKey('completedLearningBiteIds')) {
        return [];
      }
      return List<String>.from(data['completedLearningBiteIds']);
    });
  }

  Future<void> markLearningBiteComplete(String learningBiteId) async {
    final uid = _firebaseAuth.currentUser!.uid;
    // Ensure any resumeProgress entries for this user mark the bite as completed

    // 1) Scan user's resumeProgress docs for any unit that already references this bite
    final resumeColl = FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .collection('resumeProgress');
    final snap = await resumeColl.get();
    bool attached = false;
    for (final doc in snap.docs) {
      final data = doc.data();
      final bites = (data['bites'] as Map<String, dynamic>?) ?? {};
      if (bites.containsKey(learningBiteId)) {
        // update bite progress to completed
        try {
          await _progressService.updateBiteProgress(uid,
              unitId: doc.id,
              biteId: learningBiteId,
              progress: 100,
              status: 'completed');
        } catch (e) {
          if (kDebugMode) {
            print('Failed to update bite progress: $e');
          }
        }
        attached = true;
      }
    }

    // 2) If not attached, try to find the content path and attach it to the unit as completed
    if (!attached) {
      try {
        final path = await _contentService.findLearningBitePath(learningBiteId);
        if (path != null) {
          final subjectId = path['subjectId']!;
          final categoryId = path['categoryId']!;
          final topicId = path['topicId']!;
          final unitId = path['unitId']!;
          final conceptId = path['conceptId']!;
          // fetch title if possible
          String? biteTitle;
          try {
            final lb = await _contentService.getLearningBite(subjectId,
                categoryId, topicId, unitId, conceptId, learningBiteId);
            biteTitle = lb.name;
          } catch (e) {
            if (kDebugMode) {
              print('Could not fetch bite title: $e');
            }
          }
          try {
            await _progressService.startOrAttachBite(uid,
                biteId: learningBiteId,
                biteTitle: biteTitle,
                unitId: unitId,
                subjectId: subjectId,
                categoryId: categoryId,
                topicId: topicId,
                conceptId: conceptId,
                unitTitle: '',
                initialProgress: 100);
          } catch (e) {
            if (kDebugMode) {
              print('Failed to start or attach bite: $e');
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Failed to find learning bite path: $e');
        }
      }
    }
    // 3) If still not attached, try to locate the bite in any AI journeys and
    // attach it to the journey unit (preferred). This avoids creating a
    // synthetic standalone unit document and prevents duplicate units.
    if (!attached) {
      try {
        final cgSnap = await FirebaseFirestore.instance
            .collectionGroup('learning_bites')
            .where(FieldPath.documentId, isEqualTo: learningBiteId)
            .get();
        for (final d in cgSnap.docs) {
          final path = d.reference.path;
          final segments = path.split('/');
          final idx = segments.indexOf('ai_tech_journeys');
          if (idx != -1 && segments.length > idx + 1) {
            final journeyId = segments[idx + 1];
            // prefer attaching to the session-level unit (sessionId) if the journey
            // document contains it; otherwise fall back to journeyId
            String targetUnitId = journeyId;
            String? unitTitle;
            try {
              final jdoc = await FirebaseFirestore.instance
                  .collection('ai_tech_journeys')
                  .doc(journeyId)
                  .get();
              if (jdoc.exists) {
                final sid = (jdoc.data()?['sessionId'] as String?) ?? '';
                if (sid.isNotEmpty) {
                  targetUnitId = sid;
                  // try to read session doc title/context
                  try {
                    final sdoc = await FirebaseFirestore.instance
                        .collection('ai_tech_sessions')
                        .doc(targetUnitId)
                        .get();
                    if (sdoc.exists) {
                      unitTitle = (sdoc.data()?['title'] as String?) ??
                          (sdoc.data()?['goal'] as String?);
                    }
                  } catch (e) {
                    if (kDebugMode) {
                      print('Failed to read session doc for title: $e');
                    }
                  }
                }
                // If we weren't able to get a session title, fall back to the
                // journey's goal/title so we don't create a generic
                // "Lernreise" document when attaching the bite.
                unitTitle ??= (jdoc.data()?['goal'] as String?) ??
                    (jdoc.data()?['context'] as String?) ??
                    (jdoc.data()?['title'] as String?);
              }
            } catch (e) {
              if (kDebugMode) {
                print('Failed to read journey doc: $e');
              }
            }

            // derive bite title from the found doc when possible
            String? biteTitle;
            try {
              final data = d.data();
              biteTitle =
                  (data['name'] as String?) ?? (data['title'] as String?);
            } catch (e) {
              // Ignore format errors; biteTitle remains null
              biteTitle = null;
            }

            // attach to session-level unit with a readable unitTitle when possible
            try {
              await _progressService.startOrAttachBite(uid,
                  biteId: learningBiteId,
                  biteTitle: biteTitle,
                  unitId: targetUnitId,
                  unitTitle: unitTitle ?? '',
                  subjectId: null,
                  journeyId: journeyId,
                  initialProgress: 100);
              attached = true;
              break;
            } catch (e) {
              if (kDebugMode) {
                print('Failed to attach bite to session/journey: $e');
              }
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Failed to query ai_tech_journeys for bite: $e');
        }
      }
    }

    // 4) Last resort: attach to a synthetic unit so HomePage reflects completion.
    if (!attached) {
      try {
        await _progressService.startOrAttachBite(uid,
            biteId: learningBiteId, biteTitle: null, initialProgress: 100);
      } catch (e) {
        if (kDebugMode) {
          print('Failed to attach generic bite progress: $e');
        }
      }
    }

    // Persist completed id on user doc (keeps existing UI and provider expectations)
    await FirebaseFirestore.instance.collection('Users').doc(uid).set({
      'completedLearningBiteIds': FieldValue.arrayUnion([learningBiteId])
    }, SetOptions(merge: true));
  }

  Future<void> updateResumeStatus(
      String subjectId,
      String learningBiteId,
      String categoryId,
      String topicId,
      String unitId,
      String conceptId) async {
    String? biteTitle;
    try {
      final lb = await _contentService.getLearningBite(
          subjectId, categoryId, topicId, unitId, conceptId, learningBiteId);
      biteTitle = lb.name;
    } catch (_) {
      biteTitle = null;
    }
    // store resume pointer (attach into unit doc) and include title when available
    await _progressService.setResumePointer(_firebaseAuth.currentUser!.uid,
        learningBiteId: learningBiteId,
        subjectId: subjectId,
        categoryId: categoryId,
        topicId: topicId,
        unitId: unitId,
        conceptId: conceptId,
        biteTitle: biteTitle);
  }

  /// Remove the resume pointer for a specific learning bite id.
  Future<void> removeResumeStatus(String learningBiteId) async {
    await _progressService.removeResumePointer(
        _firebaseAuth.currentUser!.uid, learningBiteId);
  }

  Future<void> unblockUser(String receiverId) async {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(_firebaseAuth.currentUser!.uid)
        .update({
      'blockedUsers': FieldValue.arrayRemove([receiverId]),
    });
  }

  void reportContent(String contentId, String uid, String type,
      isLearningMaterialId, ReportReason reason) async {
    await FirebaseFirestore.instance.collection('reported_content').add({
      'contentId': contentId,
      'uid': uid,
      'type': type,
      'isLearningMaterialId': isLearningMaterialId,
      'reason': reason.name,
      'timestamp': Timestamp.now(),
      'reporter': _firebaseAuth.currentUser!.uid,
    });
    informAdmin();
  }

  void reportUser(String uid, ReportReason reason) async {
    await FirebaseFirestore.instance.collection('reported_users').add({
      'uid': uid,
      'reason': reason.name,
      'timestamp': Timestamp.now(),
      'reporter': _firebaseAuth.currentUser!.uid,
    });
    informAdmin();
  }

  void informAdmin() async {
    try {
      await FirebaseAuth.instance.setLanguageCode("de");
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: "techknowledgeconnect@jenslemke.com",
      );
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
