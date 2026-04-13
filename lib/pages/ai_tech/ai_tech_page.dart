import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tech_knowl_edge_connect/components/chat/attachment_picker_sheet.dart';
import 'package:intl/intl.dart';
import 'package:tech_knowl_edge_connect/components/chat/chat_bubble.dart';
import 'package:tech_knowl_edge_connect/components/library/learning_material_type.dart';
import 'package:tech_knowl_edge_connect/components/chat/chat_input_bar.dart';
import 'package:tech_knowl_edge_connect/models/learning/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/learning/learning_bite_result.dart';
import 'package:tech_knowl_edge_connect/models/learning/task.dart' as tk;
import 'package:tech_knowl_edge_connect/pages/search/learning_bite_page.dart';
import 'package:flutter/material.dart';

import 'package:tech_knowl_edge_connect/services/ai_tech/ai_tech_service.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/agents/ai_tech_agent.dart';
import 'package:tech_knowl_edge_connect/services/user/user_service.dart';
import 'package:tech_knowl_edge_connect/services/content/progress_service.dart';
import 'package:uuid/uuid.dart';
import 'package:tech_knowl_edge_connect/components/dialogs/completion_dialog.dart';
import 'package:tech_knowl_edge_connect/components/chat/typing_indicator.dart';
import 'package:tech_knowl_edge_connect/components/buttons/dialog_button.dart';

class AiTechPage extends StatefulWidget {
  final String sessionId;
  final String? initialUserMessage;
  final String? sessionTitle;
  final List<PlatformFile> initialPickedFiles;
  const AiTechPage(
      {Key? key,
      required this.sessionId,
      this.initialUserMessage,
      this.sessionTitle,
      this.initialPickedFiles = const []})
      : super(key: key);

  @override
  State<AiTechPage> createState() => _AiTechPageState();
}

class _AiTechPageState extends State<AiTechPage> {
  // --- State ---
  final TextEditingController _controller = TextEditingController();
  late List<PlatformFile> _pickedFiles;

  /// Displayed session title – starts empty and is replaced
  /// with an AI-generated title on the first message when the title is empty.
  String _sessionTitle = '';
  bool _sessionTitleGenerated = false;
  Future<void>? _titleGenerationFuture;

  late final AiTechOrchestrator _orchestrator;
  final AiTechService _service = AiTechService();
  final UserService _userService = UserService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ProgressService _progressService = ProgressService();

  /// Local cache of completed bite IDs – updated immediately on completion
  /// so the checkmark appears without a network round-trip.
  final Set<String> _completedBiteIds = {};

  /// True while the AI orchestrator is processing a response.
  bool _isAiThinking = false;

  /// Per-journey futures cached so that [setState] calls don't re-trigger
  /// the FutureBuilder loading state.
  final Map<String, Future<List<dynamic>>> _journeyFutures = {};

  /// Per-journey StreamBuilder streams cached so that each build cycle reuses
  /// the same Stream object. StreamBuilder re-subscribes when the stream
  /// object identity changes, so creating a new stream on every build would
  /// cause cascading rebuild loops (especially visible on Flutter Web).
  final Map<String, Stream<QuerySnapshot>> _biteStreams = {};
  late final Stream<QuerySnapshot> _messagesStream;
  Stream<String>? _sessionTitleStream;
  StreamSubscription<String>? _sessionTitleSub;

  @override
  void initState() {
    super.initState();
    _orchestrator = AiTechOrchestrator(_service);
    _sessionTitle = widget.sessionTitle ?? '';
    _pickedFiles = List<PlatformFile>.of(widget.initialPickedFiles);
    _messagesStream = _service.streamMessages(
        widget.sessionId, _firebaseAuth.currentUser!.uid);
    // Subscribe to authoritative session title updates so the UI reflects
    // the generated title (replaces the initial user input once available).
    _sessionTitleStream = _service.streamSessionTitle(widget.sessionId);
    _sessionTitleSub = _sessionTitleStream?.listen((title) {
      if (title.isNotEmpty) {
        // Only adopt the streamed title if we haven't already generated a
        // session title locally. This ensures the generated title replaces
        // the provisional user input.
        if (!_sessionTitleGenerated) {
          if (mounted) {
            setState(() {
              _sessionTitle = title;
              _sessionTitleGenerated = true;
            });
          }
        }
      }
    });
    _loadCompletedBiteIds();
    if (widget.initialUserMessage != null &&
        widget.initialUserMessage!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendMessage(
          widget.initialUserMessage!,
          files: widget.initialPickedFiles,
        );
      });
    }
  }

  Future<void> _loadCompletedBiteIds() async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();
      final ids = (doc.data()?['completedLearningBiteIds'] as List<dynamic>?)
              ?.cast<String>() ??
          <String>[];
      if (mounted) setState(() => _completedBiteIds.addAll(ids));
    } catch (_) {}
  }

  final Map<String, UnitProgress?> _unitProgressCache = {};

  @override
  void dispose() {
    _sessionTitleSub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startLearningBite(
      String journeyId, String learningBiteId) async {
    if (journeyId.isEmpty || learningBiteId.isEmpty) return;
    final learningBiteSnapshot =
        await _service.streamLearningBite(journeyId, learningBiteId).first;
    final tasksSnapshot =
        await _service.streamTasks(journeyId, learningBiteId).first;
    final learningBite =
        LearningBite.fromMap(learningBiteSnapshot.data() ?? {}, learningBiteId);
    final tasks = tasksSnapshot.docs
        .map((doc) => tk.Task.fromMap(doc.data(), doc.id))
        .toList();
    try {
      final userId = _firebaseAuth.currentUser?.uid;
      if (userId != null) {
        // Attach to the session-level unit so the resume document groups
        // all journeys of this session under one `unitId`. Include the
        // `journeyId` so UI can group bites by journey without extra queries.
        await _progressService.startOrAttachBite(userId,
            biteId: learningBiteId,
            unitId: widget.sessionId,
            subjectId: null,
            journeyId: journeyId,
            initialProgress: 0);
      }
    } catch (_) {}

    if (!mounted) return;
    final result =
        await Navigator.of(context).push<LearningBiteResult>(MaterialPageRoute(
      builder: (context) =>
          LearningBitePage(learningBite: learningBite, tasks: tasks),
    ));

    final bool completed = result?.completed == true;
    final int earnedPoints = result?.points ?? 0;
    final int totalPoints = result?.maxPoints ?? 0;

    if (completed) {
      // Snapshot completed IDs *before* marking so we can detect the
      // transition from incomplete → complete (prevents re-showing the
      // completion dialog for already-finished journeys).
      final userId = _firebaseAuth.currentUser?.uid;
      List<String> beforeCompleted = <String>[];
      try {
        if (userId != null) {
          final userDoc = await FirebaseFirestore.instance
              .collection('Users')
              .doc(userId)
              .get();
          beforeCompleted =
              (userDoc.data()?['completedLearningBiteIds'] as List<dynamic>?)
                      ?.map((e) => e.toString())
                      .toList() ??
                  <String>[];
        }
      } catch (_) {}

      // Update local cache immediately so the checkmark shows without reload.
      if (mounted) setState(() => _completedBiteIds.add(learningBiteId));

      try {
        await UserService().markLearningBiteComplete(learningBiteId);
      } catch (_) {}

      // Save score after marking complete (single write, preserves all fields).
      try {
        if (userId != null && (earnedPoints > 0 || totalPoints > 0)) {
          await _progressService.updateBiteProgress(userId,
              unitId: widget.sessionId,
              biteId: learningBiteId,
              progress: 100,
              status: 'completed',
              points: earnedPoints,
              maxPoints: totalPoints);
        }
      } catch (_) {}

      // Advance resume pointer within the same journey: attach next bite if any,
      // otherwise remove the current resume pointer.
      try {
        final snap = await FirebaseFirestore.instance
            .collection('ai_tech_journeys')
            .doc(journeyId)
            .collection('learning_bites')
            .orderBy('createdAt')
            .get();
        final docs = snap.docs;
        final idx = docs.indexWhere((d) => d.id == learningBiteId);
        if (idx != -1 && userId != null) {
          if (idx < docs.length - 1) {
            final nextId = docs[idx + 1].id;
            try {
              await _progressService.startOrAttachBite(userId,
                  biteId: nextId,
                  unitId: widget.sessionId,
                  subjectId: null,
                  journeyId: journeyId,
                  initialProgress: 0);
            } catch (_) {}
          } else {
            try {
              await UserService().removeResumeStatus(learningBiteId);
            } catch (_) {}
          }
        }
      } catch (_) {}

      try {
        if (_firebaseAuth.currentUser != null) {
          // unit documents are session-scoped (unit == sessionId)
          final updated = await _progressService.getUnitProgress(
              _firebaseAuth.currentUser!.uid, widget.sessionId);
          _unitProgressCache[widget.sessionId] = updated;
          if (mounted) setState(() {});
        }
      } catch (_) {}

      // Check if all bites in journey are completed to show Confetti Dialog.
      // Only show when transitioning from incomplete → complete (not on re-play).
      try {
        if (userId != null) {
          final snap = await FirebaseFirestore.instance
              .collection('ai_tech_journeys')
              .doc(journeyId)
              .collection('learning_bites')
              .get();

          final allCompletedBefore = snap.docs.isNotEmpty &&
              snap.docs.every((d) => beforeCompleted.contains(d.id));

          // Treat the current bite as completed even if the server write
          // hasn't propagated yet (same pattern as HomePage).
          final allCompleted = snap.docs.isNotEmpty &&
              snap.docs.every((d) =>
                  d.id == learningBiteId || beforeCompleted.contains(d.id));

          if (allCompleted && !allCompletedBefore) {
            String journeyName = 'Lernreise';
            try {
              final jdoc = await FirebaseFirestore.instance
                  .collection('ai_tech_journeys')
                  .doc(journeyId)
                  .get();
              if (jdoc.exists) {
                final ctx = (jdoc.data()?['goal'] ?? jdoc.data()?['context'])
                    as String?;
                if (ctx != null && ctx.isNotEmpty) {
                  journeyName = ctx;
                }
              }
            } catch (_) {}

            // Show completion dialog immediately.
            if (mounted) {
              showDialog(
                context: context,
                builder: (context) =>
                    CompletionDialog(conceptName: journeyName, isJourney: true),
              );
            }

            // Trigger feedback loop in the background — do not await so the
            // dialog is not blocked by the AI response.
            _orchestrator
                .triggerFeedback(
                  journeyId: journeyId,
                  userId: userId,
                  sessionId: widget.sessionId,
                )
                .catchError((_) {});
          }
        }
      } catch (_) {}
    }
  }

  // _startLearningJourney removed (unused)

  /// Delegates the full orchestration turn to [AiTechOrchestrator.chat].
  ///
  /// On the first message with an empty title, also generates and persists
  /// an AI-derived session title from the user's message.
  Future<void> _sendMessage(String text,
      {List<PlatformFile> files = const []}) async {
    if (text.trim().isEmpty && files.isEmpty) return;

    // Convert picked files to inline parts for the AI model.
    final fileParts = files.where((f) => f.bytes != null).map((f) {
      final ext = (f.extension ?? '').toLowerCase();
      final mime = LearningMaterialType.getMimeType(ext);
      return InlineDataPart(mime, f.bytes!);
    }).toList();

    // Upload files to Firebase Storage and collect download URLs for display.
    final uid = _firebaseAuth.currentUser?.uid ?? 'anonymous';
    final fileAttachments = <Map<String, dynamic>>[];
    for (final f in files) {
      final ext = (f.extension ?? '').toLowerCase();
      String? url;
      if (f.bytes != null) {
        try {
          final uniqueName = '${const Uuid().v4()}_${f.name}';
          final ref = FirebaseStorage.instance
              .ref('ai_tech_attachments/$uid/${widget.sessionId}/$uniqueName');
          final mime = LearningMaterialType.getMimeType(ext);
          await ref.putData(
              f.bytes!,
              SettableMetadata(
                  contentType:
                      mime.isEmpty ? 'application/octet-stream' : mime));
          url = await ref.getDownloadURL();
        } catch (_) {}
      }
      // Replace generic image_picker names with readable timestamp names.
      final isImagePicker = f.name.startsWith('image_picker');
      final isVideo = LearningMaterialType.videoTypes.contains(ext);
      final displayName = isImagePicker
          ? '${isVideo ? 'Video' : 'Foto'}_${DateFormat('dd.MM.yy_HH:mm').format(DateTime.now())}.$ext'
          : f.name;

      fileAttachments.add({
        'name': displayName,
        'ext': ext,
        if (url != null) 'url': url,
      });
    }

    // On the first message without a generated title, generate one and
    // await it so the orchestrator already receives the correct
    // `sessionTitle` on this turn. Treat an existing title that exactly
    // matches the user's initial input as provisional and regenerate.
    if (!_sessionTitleGenerated &&
        (_sessionTitle.isEmpty || _sessionTitle == text)) {
      _titleGenerationFuture ??= _orchestrator
          .generateSessionTitle(
              text.isNotEmpty
                  ? text
                  : fileAttachments.map((a) => a['name']).join(', '),
              fallback: text.isNotEmpty ? text : 'Dateien')
          .then((title) {
        _service.updateSessionUnit(widget.sessionId, title);
        if (mounted) {
          setState(() {
            _sessionTitle = title;
            _sessionTitleGenerated = true;
          });
        }
      }).catchError((_) {
        _titleGenerationFuture = null;
      });
      await _titleGenerationFuture;
    }

    _controller.clear();
    if (mounted) setState(() => _isAiThinking = true);
    try {
      await _orchestrator.chat(
        userMessage: text.isNotEmpty
            ? text
            : 'Bitte analysiere die beigefügten Dateien.',
        userId: _firebaseAuth.currentUser?.uid ?? 'user',
        sessionId: widget.sessionId,
        sessionTitle: _sessionTitle.isNotEmpty ? _sessionTitle : text,
        fileParts: fileParts,
        fileAttachments: fileAttachments,
      );
    } finally {
      if (mounted) setState(() => _isAiThinking = false);
    }
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Heute';
    } else if (messageDate == yesterday) {
      return 'Gestern';
    } else {
      // Format: "Mo. 7. Dez. 25"
      return DateFormat('E d. MMM yy', 'de').format(date);
    }
  }

  Widget _buildDateSeparator(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _formatDateHeader(date),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _messagesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2)),
          );
        } else if (snapshot.hasError) {
          return Text("Ein Fehler ist aufgetreten: ${snapshot.error}");
        } else if (snapshot.hasData) {
          final docs = snapshot.data!.docs.toList(); // oldest first
          List<Widget> messageWidgets = [];
          DateTime? lastDate;

          for (var document in docs) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            Timestamp timestamp = data['ts'];
            DateTime messageDate = timestamp.toDate();
            DateTime messageDayOnly =
                DateTime(messageDate.year, messageDate.month, messageDate.day);

            if (lastDate == null || lastDate != messageDayOnly) {
              messageWidgets.add(_buildDateSeparator(messageDate));
              lastDate = messageDayOnly;
            }

            messageWidgets.add(_buildMessageItem(document));

            if (data['type'] == 'journey.create' ||
                data['type'] == 'journey.update' ||
                data['type'] == 'journey.addBite') {
              messageWidgets.add(_buildJourneyCard(data['journeyId'] ?? ''));
            }
          }

          ListView messageList = ListView(
              reverse: true,
              cacheExtent: 1500,
              padding: EdgeInsets.only(
                top: 8,
                bottom: MediaQuery.of(context).padding.bottom + 85,
              ),
              children: [
                if (_isAiThinking) const TypingIndicator(),
                ...messageWidgets.reversed,
              ]);
          return TextFieldTapRegion(child: messageList);
        } else {
          return const Text("Noch keine Nachrichten vorhanden.");
        }
      },
    );
  }

  Widget _buildJourneyCard(String journeyId) {
    // Use a cached future so that setState calls don't re-trigger the loading
    // state. The user document is no longer fetched here – completion status
    // is read from the locally-maintained [_completedBiteIds] set instead.
    final journeyFuture = _journeyFutures.putIfAbsent(
      journeyId,
      () => Future.wait([
        _service.getJourney(journeyId).first,
        // also fetch the journey's learning_bites snapshot so we can render the list
        _service.streamLearningBites(journeyId).first,
      ]),
    );
    return FutureBuilder<List<dynamic>>(
      future: journeyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(12.0),
            child: Center(
              child: SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Text("Fehler beim Laden der Lernreise: ${snapshot.error}");
        } else if (snapshot.hasData && snapshot.data != null) {
          final journeyDoc = snapshot.data![0] as DocumentSnapshot;
          final journeyData = journeyDoc.data() as Map<String, dynamic>;
          // second element is the QuerySnapshot of the journey's learning_bites
          final bitesSnapshot = snapshot.data!.length > 1
              ? snapshot.data![1] as QuerySnapshot
              : null;
          final bitesDocs = bitesSnapshot?.docs ?? <QueryDocumentSnapshot>[];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light
                  ? Theme.of(context).colorScheme.surfaceContainerLowest
                  : Theme.of(context).colorScheme.secondary.withAlpha(40),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    Theme.of(context).colorScheme.outlineVariant.withAlpha(26),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(12),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  children: [
                    ListTile(
                      title: Text(journeyData['goal'] ??
                          journeyData['context'] ??
                          'Lernreise'),
                      trailing: StreamBuilder<QuerySnapshot>(
                        stream: _biteStreams.putIfAbsent(journeyId,
                            () => _service.streamLearningBites(journeyId)),
                        initialData: bitesSnapshot,
                        builder: (context, biteCountSnapshot) {
                          final countDocs =
                              biteCountSnapshot.data?.docs ?? bitesDocs;
                          final completedIds = _completedBiteIds.toList();
                          final int totalBites = countDocs.length;
                          final int completedBites = countDocs
                              .where((d) => completedIds.contains(d.id))
                              .length;
                          final bool journeyCompleted =
                              totalBites > 0 && completedBites == totalBites;
                          return Padding(
                            padding: const EdgeInsets.only(right: 14.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (totalBites > 0) ...[
                                  Text(
                                    '$completedBites/$totalBites',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withAlpha(191),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Icon(
                                  journeyCompleted
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: journeyCompleted
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withAlpha(191),
                                  size: 26,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 4.0),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _biteStreams.putIfAbsent(journeyId,
                            () => _service.streamLearningBites(journeyId)),
                        // reuse the QuerySnapshot we already fetched in the
                        // enclosing FutureBuilder so the UI renders immediately
                        initialData: bitesSnapshot,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.waiting &&
                              snapshot.data == null) {
                            return const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2)),
                            );
                          }
                          if (!snapshot.hasData || snapshot.data == null) {
                            return const Text('Keine Lernbites gefunden.');
                          }
                          final bitesSnapshotLocal = snapshot.data!;
                          final bites = bitesSnapshotLocal.docs;
                          if (bites.isEmpty) {
                            return const Text('Keine Lernbites gefunden.');
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: bites.map((doc) {
                              final biteData =
                                  doc.data() as Map<String, dynamic>;
                              final docId = doc.id;
                              // determine completion from locally-cached set
                              final bool biteCompleted =
                                  _completedBiteIds.contains(docId);
                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 6.0),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surface
                                      .withAlpha(230),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outlineVariant
                                        .withAlpha(51),
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () =>
                                        _startLearningBite(journeyId, docId),
                                    child: ListTile(
                                      title:
                                          Text(biteData['title'] ?? 'Lernbite'),
                                      subtitle:
                                          Text(biteData['description'] ?? ''),
                                      trailing: Icon(
                                        biteCompleted
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        color: biteCompleted
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withAlpha(191),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Future<void> _pickFiles() async {
    await showAttachmentPickerSheet(
      context,
      onFilesAdded: (files) => setState(() {
        _pickedFiles = [..._pickedFiles, ...files];
      }),
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    final isUser = data['role'] == 'user';
    final text = (data['text'] as String?) ?? '';
    final attachments = ((data['meta'] as Map<String, dynamic>?)?['attachments']
        as List<dynamic>?);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Use Flexible so text doesn't overflow
            Flexible(
              child: Column(
                crossAxisAlignment:
                    isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (text.isNotEmpty)
                    ChatBubble(
                      uid: data['userId'] ?? '',
                      message: text,
                      type: data['type'] ?? 'text',
                      isMe: isUser,
                      time: data['ts'],
                      userService: _userService,
                    ),
                  if (attachments != null && attachments.isNotEmpty)
                    ...attachments.map<Widget>((att) {
                      final a = att as Map<String, dynamic>;
                      final name = (a['name'] as String?) ?? 'Datei';
                      final ext = (a['ext'] as String?) ?? '';
                      final url = (a['url'] as String?) ?? '';
                      if (url.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ChatBubble(
                          uid: data['userId'] ?? '',
                          message: url,
                          type: ext,
                          fileName: name,
                          isMe: isUser,
                          time: data['ts'],
                          userService: _userService,
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return ChatInputBar(
      controller: _controller,
      hintText: 'Was möchtest du lernen?',
      onSend: () {
        final text = _controller.text;
        final files = List<PlatformFile>.of(_pickedFiles);
        setState(() => _pickedFiles = []);
        _sendMessage(text, files: files);
      },
      onAttachmentTap: _pickFiles,
      pickedFiles: _pickedFiles,
      onRemoveFile: (f) => setState(() => _pickedFiles.remove(f)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _sessionTitle.isNotEmpty ? _sessionTitle : 'Lernsession',
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Session löschen',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (c) {
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
                        Icons.delete_outline,
                        size: 32,
                        color: cs.error,
                      ),
                    ),
                    title: const Text(
                      'Session löschen',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: const Text(
                        'Möchtest du diese Session und alle zugehörigen Daten wirklich löschen? Dies kann nicht rückgängig gemacht werden.'),
                    actions: [
                      Row(
                        children: [
                          DialogButton(
                            text: 'Abbrechen',
                            onTap: () => Navigator.of(c).pop(false),
                          ),
                          const SizedBox(width: 8),
                          DialogButton(
                            text: 'Löschen',
                            isDestructive: true,
                            onTap: () => Navigator.of(c).pop(true),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
              if (confirmed == true && mounted) {
                try {
                  await _service.deleteSession(
                    widget.sessionId,
                    userId: _firebaseAuth.currentUser?.uid,
                  );
                  if (context.mounted) Navigator.of(context).pop();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Fehler beim Löschen: $e')));
                  }
                }
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: SizedBox.expand(
          child: Stack(
            children: [
              // --- Chat Section ---
              Positioned.fill(child: _buildMessageList()),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Theme.of(context).colorScheme.surface,
                        Theme.of(context).colorScheme.surface.withAlpha(230),
                        Theme.of(context).colorScheme.surface.withAlpha(0),
                      ],
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    10,
                    24,
                    10,
                    MediaQuery.of(context).padding.bottom + 16,
                  ),
                  child: _buildMessageInput(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
