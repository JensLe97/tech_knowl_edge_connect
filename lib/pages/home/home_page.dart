import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/models/learning/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/learning/learning_bite_result.dart';
import 'package:tech_knowl_edge_connect/models/learning/task.dart';
import 'package:tech_knowl_edge_connect/models/content/subject.dart';
import 'package:tech_knowl_edge_connect/pages/search/learning_bite_page.dart';
import 'package:tech_knowl_edge_connect/services/content/content_service.dart';
import 'package:tech_knowl_edge_connect/services/user/user_service.dart';
import 'package:tech_knowl_edge_connect/pages/search/unit_overview_page.dart';
import 'package:tech_knowl_edge_connect/models/content/unit.dart';
import 'package:tech_knowl_edge_connect/pages/ai_tech/ai_tech_page.dart';
import 'package:tech_knowl_edge_connect/services/content/progress_service.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/ai_tech_service.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/agents/ai_tech_agent.dart';
import 'package:tech_knowl_edge_connect/components/dialogs/completion_dialog.dart';
import 'package:tech_knowl_edge_connect/components/home/home_greeting_header.dart';
import 'package:tech_knowl_edge_connect/components/home/home_empty_state.dart';
import 'package:tech_knowl_edge_connect/components/home/unit_progress_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ContentService _contentService = ContentService();
  final ProgressService _progressService = ProgressService();
  late final AiTechOrchestrator _orchestrator =
      AiTechOrchestrator(AiTechService());

  User? _user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? _userData;
  StreamSubscription<List<UnitProgress>>? _unitsSub;
  StreamSubscription<List<Subject>>? _subjectsSub;
  List<UnitProgress> _units = [];
  bool _isLoadingUnits = true;
  final Map<String, Color> _subjectColors = {};
  bool _isDisposed = false;

  void _safeSetState(VoidCallback fn) {
    if (!mounted || _isDisposed) return;
    setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _listenAuth();
    _subscribeUnits();
    _subjectsSub = _contentService.getSubjects().listen((subjects) {
      if (mounted) {
        setState(() {
          for (final s in subjects) {
            _subjectColors[s.id] = s.color;
          }
        });
      }
    });
  }

  void _listenAuth() {
    FirebaseAuth.instance.authStateChanges().listen((u) {
      _safeSetState(() {
        _user = u;
        _userData = null;
      });
      if (u != null) _loadUserData(u.uid);
      _subscribeUnits();
    });
    if (_user != null) _loadUserData(_user!.uid);
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('Users').doc(uid).get();
      _safeSetState(() => _userData = doc.data());
    } catch (_) {}
  }

  void _subscribeUnits() {
    _unitsSub?.cancel();
    final uid = _user?.uid;
    if (uid == null) {
      _safeSetState(() {
        _units = [];
        _isLoadingUnits = false;
      });
      return;
    }
    _safeSetState(() => _isLoadingUnits = true);
    _unitsSub = _progressService.subscribeUserUnits(uid).listen((list) {
      _safeSetState(() {
        _units = list;
        _isLoadingUnits = false;
      });
    }, onError: (_) {
      _safeSetState(() => _isLoadingUnits = false);
    });
  }

  @override
  void dispose() {
    _unitsSub?.cancel();
    _subjectsSub?.cancel();
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _openUnitOverview(UnitProgress unit) async {
    // Try to locate the unit document in the content tree so we can open
    // the `UnitOverviewPage`. If the unit is an AI session or we cannot find
    // the content unit, show a snackbar informing the user.
    if (unit.subjectId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Einheiten-Übersicht nicht verfügbar')));
      return;
    }
    try {
      final q = await FirebaseFirestore.instance.collectionGroup('units').get();
      final d = q.docs.firstWhere((doc) => doc.id == unit.unitId,
          orElse: () =>
              throw Exception('Unit document not found for id ${unit.unitId}'));
      final path = d.reference
          .path; // content_subjects/{subject}/categories/{cat}/topics/{topic}/units/{unitId}
      final segments = path.split('/');
      final idx = segments.indexOf('content_subjects');
      if (idx == -1 || segments.length <= idx + 6) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Einheiten-Übersicht nicht verfügbar')));
        return;
      }
      final subjectId = segments[idx + 1];
      final categoryId = segments[idx + 3];
      final topicId = segments[idx + 5];
      final unitModel = Unit.fromMap(d.data(), d.id);
      if (!mounted) return;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => UnitOverviewPage(
                  subjectId: subjectId,
                  categoryId: categoryId,
                  topicId: topicId,
                  unit: unitModel)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Einheiten-Übersicht nicht verfügbar')));
    }
  }

  Future<void> _openBiteFromUnit(
      UnitProgress unit, UnitBiteProgress bite) async {
    try {
      showDialog(
          context: context,
          builder: (_) => const Center(child: CircularProgressIndicator()));
      final path = await _contentService.findLearningBitePath(bite.biteId);
      if (path == null) {
        final genDoc = await FirebaseFirestore.instance
            .collection('ai_generated_bites')
            .doc(bite.biteId)
            .get();
        if (genDoc.exists) {
          final lb = LearningBite.fromMap(genDoc.data()!, genDoc.id);
          final taskDocs = await genDoc.reference
              .collection('tasks')
              .orderBy('createdAt')
              .get();
          final genTasks =
              taskDocs.docs.map((d) => Task.fromMap(d.data(), d.id)).toList();
          if (!mounted) return;
          Navigator.pop(context);
          final result = await Navigator.push<LearningBiteResult>(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      LearningBitePage(learningBite: lb, tasks: genTasks)));
          if (result != null && result.completed) {
            try {
              await UserService().markLearningBiteComplete(bite.biteId);
            } catch (_) {}
          }
          return;
        }
        // if this bite belongs to an AI journey unit, try the journey path
        try {
          final journeyId = bite.journeyId ?? unit.unitId;
          var journeyDoc = await FirebaseFirestore.instance
              .collection('ai_tech_journeys')
              .doc(journeyId)
              .collection('learning_bites')
              .doc(bite.biteId)
              .get();

          if (!journeyDoc.exists && journeyId != unit.unitId) {
            // Fallback to unit.unitId
            journeyDoc = await FirebaseFirestore.instance
                .collection('ai_tech_journeys')
                .doc(unit.unitId)
                .collection('learning_bites')
                .doc(bite.biteId)
                .get();
          }

          if (journeyDoc.exists) {
            final lb = LearningBite.fromMap(journeyDoc.data()!, journeyDoc.id);
            final taskDocs = await journeyDoc.reference
                .collection('tasks')
                .orderBy('createdAt')
                .get();
            final genTasks =
                taskDocs.docs.map((d) => Task.fromMap(d.data(), d.id)).toList();
            if (!mounted) return;
            Navigator.pop(context);
            // Ensure resumeProgress exists for this journey bite so
            // markLearningBiteComplete updates the correct unit document.
            final userId = FirebaseAuth.instance.currentUser?.uid;
            final resolvedJourneyId =
                journeyDoc.reference.parent.parent?.id ?? unit.unitId;
            if (userId != null) {
              try {
                await _progressService.startOrAttachBite(userId,
                    biteId: lb.id,
                    biteTitle: lb.name,
                    unitId: unit.unitId,
                    unitTitle: unit.title,
                    subjectId: null,
                    journeyId: resolvedJourneyId,
                    initialProgress: 0);
              } catch (_) {}
            }
            if (!mounted) return;
            final result = await Navigator.push<LearningBiteResult>(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        LearningBitePage(learningBite: lb, tasks: genTasks)));
            if (result != null && result.completed) {
              try {
                await _handlePostCompletionForContent(
                  '',
                  '',
                  '',
                  unit.unitId,
                  '',
                  lb.id,
                  journeyId: resolvedJourneyId,
                  points: result.points,
                  maxPoints: result.maxPoints,
                );
              } catch (_) {}
            }
            return;
          }
        } catch (_) {}
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Inhalt nicht gefunden')));
        return;
      }

      final learningBite = await _contentService.getLearningBite(
          path['subjectId']!,
          path['categoryId']!,
          path['topicId']!,
          path['unitId']!,
          path['conceptId']!,
          path['learningBiteId']!);
      final tasks = await _contentService.getTasks(
          path['subjectId']!,
          path['categoryId']!,
          path['topicId']!,
          path['unitId']!,
          path['conceptId']!,
          path['learningBiteId']!);
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        try {
          await _contentService.startLearningBiteForUser(
              userId: userId,
              subjectId: path['subjectId']!,
              categoryId: path['categoryId']!,
              topicId: path['topicId']!,
              unitId: path['unitId']!,
              conceptId: path['conceptId']!,
              learningBiteId: path['learningBiteId']!);
        } catch (_) {}
      }
      if (!mounted) return;
      Navigator.pop(context);
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  LearningBitePage(learningBite: learningBite, tasks: tasks)));
      if (result is Map && result['completed'] == true) {
        try {
          await _handlePostCompletionForContent(
              path['subjectId']!,
              path['categoryId']!,
              path['topicId']!,
              path['unitId']!,
              path['conceptId']!,
              path['learningBiteId']!,
              points: result['points'] as int? ?? 0,
              maxPoints: result['maxPoints'] as int? ?? 0);
        } catch (_) {}
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Fehler beim Laden: $e')));
    }
  }

  Future<void> _openAiTechJourneyLearningBite(
      UnitProgress unit, String learningBiteId,
      {String? journeyId}) async {
    try {
      showDialog(
          context: context,
          builder: (_) => const Center(child: CircularProgressIndicator()));
      final resolvedJourneyId = journeyId ?? unit.unitId;
      final docRef = FirebaseFirestore.instance
          .collection('ai_tech_journeys')
          .doc(resolvedJourneyId)
          .collection('learning_bites')
          .doc(learningBiteId);
      final snap = await docRef.get();
      if (!snap.exists) {
        // If not found under provided journeyId, attempt fallback to unit.unitId
        if (journeyId != null && journeyId != unit.unitId) {
          try {
            final fallbackRef = FirebaseFirestore.instance
                .collection('ai_tech_journeys')
                .doc(unit.unitId)
                .collection('learning_bites')
                .doc(learningBiteId);
            final fallbackSnap = await fallbackRef.get();
            if (fallbackSnap.exists) {
              if (!mounted) return;
              Navigator.pop(context);
              final lb =
                  LearningBite.fromMap(fallbackSnap.data()!, fallbackSnap.id);
              final taskDocs = await fallbackRef
                  .collection('tasks')
                  .orderBy('createdAt')
                  .get();
              final tasks = taskDocs.docs
                  .map((d) => Task.fromMap(d.data(), d.id))
                  .toList();
              if (!mounted) return;
              // Ensure resumeProgress exists so completion updates unit state
              final userId = FirebaseAuth.instance.currentUser?.uid;
              if (userId != null) {
                try {
                  await _progressService.startOrAttachBite(userId,
                      biteId: lb.id,
                      biteTitle: lb.name,
                      unitId: unit.unitId,
                      unitTitle: unit.title,
                      subjectId: null,
                      journeyId: unit.unitId,
                      initialProgress: 0);
                } catch (_) {}
              }
              if (!mounted) return;
              final result = await Navigator.push<LearningBiteResult>(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          LearningBitePage(learningBite: lb, tasks: tasks)));
              if (result != null && result.completed) {
                try {
                  await _handlePostCompletionForContent(
                    '',
                    '',
                    '',
                    unit.unitId,
                    '',
                    lb.id,
                    journeyId: unit.unitId,
                    points: result.points,
                    maxPoints: result.maxPoints,
                  );
                } catch (_) {}
              }
              return;
            }
          } catch (_) {}
        }
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Inhalt nicht gefunden')));
        return;
      }
      final lb = LearningBite.fromMap(snap.data()!, snap.id);
      final taskDocs =
          await docRef.collection('tasks').orderBy('createdAt').get();
      final tasks =
          taskDocs.docs.map((d) => Task.fromMap(d.data(), d.id)).toList();
      if (!mounted) return;
      Navigator.pop(context);
      // Ensure resumeProgress exists so completion updates the unit state
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        try {
          await _progressService.startOrAttachBite(userId,
              biteId: lb.id,
              biteTitle: lb.name,
              unitId: unit.unitId,
              unitTitle: unit.title,
              subjectId: null,
              journeyId: resolvedJourneyId,
              initialProgress: 0);
        } catch (_) {}
      }
      if (!mounted) return;
      final result = await Navigator.push<LearningBiteResult>(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  LearningBitePage(learningBite: lb, tasks: tasks)));
      if (result != null && result.completed) {
        try {
          await _handlePostCompletionForContent(
            '',
            '',
            '',
            unit.unitId,
            '',
            lb.id,
            journeyId: resolvedJourneyId,
            points: result.points,
            maxPoints: result.maxPoints,
          );
        } catch (_) {}
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Fehler beim Laden: $e')));
    }
  }

  Future<void> _openLearningBitePath(
      String subjectId,
      String categoryId,
      String topicId,
      String unitId,
      String conceptId,
      String learningBiteId) async {
    try {
      showDialog(
          context: context,
          builder: (_) => const Center(child: CircularProgressIndicator()));
      final learningBite = await _contentService.getLearningBite(
          subjectId, categoryId, topicId, unitId, conceptId, learningBiteId);
      final tasks = await _contentService.getTasks(
          subjectId, categoryId, topicId, unitId, conceptId, learningBiteId);
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        try {
          await _contentService.startLearningBiteForUser(
              userId: userId,
              subjectId: subjectId,
              categoryId: categoryId,
              topicId: topicId,
              unitId: unitId,
              conceptId: conceptId,
              learningBiteId: learningBiteId);
        } catch (_) {}
      }
      if (!mounted) return;
      Navigator.pop(context);
      final result = await Navigator.push<LearningBiteResult>(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  LearningBitePage(learningBite: learningBite, tasks: tasks)));
      if (result != null && result.completed) {
        try {
          await _handlePostCompletionForContent(
              subjectId, categoryId, topicId, unitId, conceptId, learningBiteId,
              points: result.points, maxPoints: result.maxPoints);
        } catch (_) {}
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Fehler beim Laden: $e')));
    }
  }

  Future<void> _handlePostCompletionForContent(
      String subjectId,
      String categoryId,
      String topicId,
      String unitId,
      String conceptId,
      String learningBiteId,
      {String? journeyId,
      int points = 0,
      int maxPoints = 0}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // snapshot user's completed ids before marking to detect transition
    final userDoc =
        await FirebaseFirestore.instance.collection('Users').doc(uid).get();
    final beforeCompleted =
        (userDoc.data()?['completedLearningBiteIds'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            <String>[];

    // fetch all bites in this concept or journey
    List<LearningBite> learningBites = [];
    try {
      if (journeyId != null) {
        final snap = await FirebaseFirestore.instance
            .collection('ai_tech_journeys')
            .doc(journeyId)
            .collection('learning_bites')
            .get();
        learningBites = snap.docs.map((d) {
          try {
            return LearningBite.fromMap(d.data(), d.id);
          } catch (_) {
            return LearningBite(
              id: d.id,
              name: d.data()['title'] ?? '',
              type: d.data()['type'] ?? 'text',
              content: (d.data()['content'] as List<dynamic>?)
                      ?.map((e) => e.toString())
                      .toList() ??
                  [],
            );
          }
        }).toList();
      } else {
        learningBites = await _contentService
            .getLearningBites(subjectId, categoryId, topicId, unitId, conceptId)
            .first;
      }
    } catch (_) {}

    final allCompletedBefore = learningBites.isNotEmpty
        ? learningBites.every((lb) => beforeCompleted.contains(lb.id))
        : false;

    // mark current bite complete (also updates resume/completed server-side)
    try {
      await UserService().markLearningBiteComplete(learningBiteId);
    } catch (_) {}

    // Save score into resumeProgress so FeedbackAgent can read points/maxPoints.
    if (journeyId != null && (points > 0 || maxPoints > 0)) {
      try {
        await _progressService.updateBiteProgress(uid,
            unitId: unitId,
            biteId: learningBiteId,
            progress: 100,
            status: 'completed',
            points: points,
            maxPoints: maxPoints);
      } catch (_) {}
    }

    // Optimistically update local UI state so the HomePage shows the
    // completed checkbox immediately without waiting for Firestore round-trips.
    // If this bite was already completed before marking it here, avoid
    // changing the aggregate unit progress.
    if (!beforeCompleted.contains(learningBiteId)) {
      _safeSetState(() {
        final uidx = _units.indexWhere((u) => u.unitId == unitId);
        if (uidx != -1) {
          final unit = _units[uidx];
          final bitesMap = Map<String, UnitBiteProgress>.from(unit.bites);
          final existing = bitesMap[learningBiteId];
          final updatedBite = UnitBiteProgress(
            biteId: learningBiteId,
            conceptId: existing?.conceptId ?? conceptId,
            journeyId: existing?.journeyId,
            categoryId: existing?.categoryId ?? categoryId,
            topicId: existing?.topicId ?? topicId,
            biteTitle: existing?.biteTitle ?? '',
            status: 'completed',
            progress: 100,
            lastUpdated: Timestamp.now(),
            createdAt: existing?.createdAt,
            currentTaskIndex: existing?.currentTaskIndex ?? 0,
            tasks: existing?.tasks ?? {},
          );
          bitesMap[learningBiteId] = updatedBite;
          // recalc aggregate progress using expectedBiteCount as denominator
          // so the local estimate matches what ProgressService will write.
          final biteValues = bitesMap.values.map((b) => b.progress).toList();
          final denom = unit.expectedBiteCount > 0
              ? unit.expectedBiteCount
              : biteValues.length;
          final agg = biteValues.isEmpty
              ? 0
              : (biteValues.reduce((a, b) => a + b) / denom).round();
          final updatedUnit = UnitProgress(
              unitId: unit.unitId,
              subjectId: unit.subjectId,
              title: unit.title,
              source: unit.source,
              status: agg >= 100 ? 'completed' : 'in_progress',
              progress: agg,
              expectedBiteCount: unit.expectedBiteCount,
              bites: bitesMap,
              lastUpdated: Timestamp.now());
          _units[uidx] = updatedUnit;
        }
      });
    }

    // advance resume pointer to next bite or clear it
    if (learningBites.isNotEmpty) {
      final idx = learningBites.indexWhere((lb) => lb.id == learningBiteId);
      if (idx != -1) {
        if (idx < learningBites.length - 1) {
          final nextLB = learningBites[idx + 1];
          try {
            if (journeyId != null) {
              await _progressService.startOrAttachBite(uid,
                  biteId: nextLB.id,
                  biteTitle: nextLB.name,
                  unitId: unitId,
                  subjectId: null,
                  journeyId: journeyId,
                  initialProgress: 0);
            } else {
              await UserService().updateResumeStatus(
                  subjectId, nextLB.id, categoryId, topicId, unitId, conceptId);
            }
          } catch (_) {}
        } else {
          try {
            await UserService().removeResumeStatus(learningBiteId);
          } catch (_) {}
        }
      }
    }

    // determine if all bites are completed now (treat current as completed)
    final allCompleted = learningBites.isNotEmpty
        ? learningBites.every(
            (lb) => lb.id == learningBiteId || beforeCompleted.contains(lb.id))
        : false;

    if (allCompleted && !allCompletedBefore) {
      // fetch concept name for dialog
      String conceptName = conceptId;
      if (journeyId != null) {
        try {
          final journeyDoc = await FirebaseFirestore.instance
              .collection('ai_tech_journeys')
              .doc(journeyId)
              .get();
          conceptName = (journeyDoc.data()?['goal'] as String?) ??
              (journeyDoc.data()?['title'] as String?) ??
              'Lernreise';

          // Trigger the feedback agent in the background — do not await so
          // the completion dialog is not blocked by the AI response.
          final sessionId = journeyDoc.data()?['sessionId'] as String?;
          if (sessionId != null && sessionId.isNotEmpty) {
            _orchestrator
                .triggerFeedback(
                  journeyId: journeyId,
                  userId: uid,
                  sessionId: sessionId,
                )
                .catchError((_) {});
          }
        } catch (_) {}
      } else {
        try {
          final conceptDoc = await FirebaseFirestore.instance
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
          conceptName = (conceptDoc.data()?['name'] as String?) ?? conceptName;
        } catch (_) {}
      }

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => CompletionDialog(
            conceptName: conceptName, isJourney: journeyId != null),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          HomeGreetingHeader(
            username: _userData?['username'],
            isLoading: _userData == null && _user != null,
          ),
          if (_isLoadingUnits)
            const Padding(
              padding: EdgeInsets.only(top: 32.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_units.isNotEmpty) ...[
            const Text('In Bearbeitung',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _units.length,
              itemBuilder: (context, idx) {
                final unit = _units[idx];
                return UnitProgressCard(
                  unit: unit,
                  subjectColor: _subjectColors[unit.subjectId],
                  onOpenUnit: () => _openUnitOverview(unit),
                  onOpenAiSession: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => AiTechPage(
                              sessionId: unit.unitId, unitTitle: unit.title))),
                  onBiteTap: _openBiteFromUnit,
                  onJourneyBiteTap: (u, lb, {required journeyId}) =>
                      _openAiTechJourneyLearningBite(u, lb.id,
                          journeyId: journeyId),
                  onContentBiteTap: (u, lb,
                          {required categoryId,
                          required topicId,
                          required conceptId}) =>
                      _openLearningBitePath(u.subjectId, categoryId, topicId,
                          u.unitId, conceptId, lb.id),
                );
              },
            ),
          ] else ...[
            const SizedBox(height: 12),
            const HomeEmptyState(),
          ],
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}
