import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/components/library/personal_library.dart';
import 'package:tech_knowl_edge_connect/components/tiles/subject_tile.dart';
import 'package:tech_knowl_edge_connect/components/user/dialogs/subject_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tech_knowl_edge_connect/components/chat/attachment_picker_sheet.dart';
import 'package:tech_knowl_edge_connect/components/chat/chat_input_bar.dart';
import 'package:tech_knowl_edge_connect/pages/ai_tech/ai_tech_page.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/ai_tech_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:tech_knowl_edge_connect/models/ai_tech/session_type.dart';
import 'package:tech_knowl_edge_connect/services/content/content_service.dart';
import 'package:tech_knowl_edge_connect/models/content/subject.dart';
import 'package:tech_knowl_edge_connect/pages/search/subject_overview_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final subjectController = TextEditingController();
  final searchController = TextEditingController();
  final ContentService _contentService = ContentService();
  final AiTechService _aiTechService = AiTechService();
  final TextEditingController _messageController = TextEditingController();
  List<PlatformFile> _pickedFiles = [];

  Future<void> _pickFiles() async {
    await showAttachmentPickerSheet(
      context,
      onFilesAdded: (files) => setState(() {
        _pickedFiles = [..._pickedFiles, ...files];
      }),
    );
  }

  void navigateToSubjectPage(Subject subject) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubjectOverviewPage(subject: subject),
        )).then((value) => {subjectController.clear()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("Suche"),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: _aiTechService.streamSessions(
                            FirebaseAuth.instance.currentUser?.uid ?? ''),
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const SizedBox.shrink();
                          }
                          if (snap.hasError) return const SizedBox.shrink();
                          final docs = snap.data?.docs ?? [];
                          if (docs.isEmpty) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Meine Lernreisen',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900)),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 150,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: docs.length,
                                  itemBuilder: (context, i) {
                                    final doc = docs[i];
                                    final data = doc.data();
                                    final sessionId = doc.id;
                                    final ts =
                                        data['lastTimestamp'] as Timestamp?;
                                    final last = ts != null
                                        ? ts.toDate()
                                        : DateTime.now();
                                    final fmt = DateTime.now()
                                                .difference(last)
                                                .inDays >=
                                            1
                                        ? DateFormat('dd.MM.yyyy')
                                        : DateFormat('HH:mm');
                                    final lastStr = fmt.format(last);
                                    final unit =
                                        (data['unit'] as String?) ?? '';
                                    final sessionTitle =
                                        unit.isNotEmpty ? unit : 'Session';
                                    final colorScheme =
                                        Theme.of(context).colorScheme;

                                    return Card(
                                      margin: const EdgeInsets.only(right: 12),
                                      clipBehavior: Clip.antiAlias,
                                      elevation: 0,
                                      color: colorScheme.surfaceContainerHigh,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side: BorderSide(
                                          color: colorScheme.outlineVariant
                                              .withAlpha(51),
                                          width: 1,
                                        ),
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => AiTechPage(
                                                sessionId: sessionId,
                                                sessionTitle: sessionTitle,
                                              ),
                                            ),
                                          );
                                        },
                                        child: SizedBox(
                                          width: 160,
                                          height: double.infinity,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                top: -20,
                                                right: -20,
                                                child: Icon(
                                                  Icons.lightbulb,
                                                  size: 100,
                                                  color: colorScheme.primary
                                                      .withAlpha(15),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 6,
                                                          vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: colorScheme
                                                            .primaryContainer,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                      ),
                                                      child: Text(
                                                        lastStr,
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: colorScheme
                                                              .onPrimaryContainer,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      sessionTitle,
                                                      maxLines: 3,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: colorScheme
                                                            .onSurface,
                                                        height: 1.2,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          "Session öffnen",
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: colorScheme
                                                                .onSurfaceVariant,
                                                          ),
                                                        ),
                                                        Icon(
                                                          Icons
                                                              .arrow_forward_ios,
                                                          size: 14,
                                                          color: colorScheme
                                                              .primary,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          );
                        },
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Meine Fächer",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      child: Column(
                        children: [
                          StreamBuilder<List<Subject>>(
                            stream: _contentService.getSubjects(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return Center(
                                    child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("Fehler: ${snapshot.error}"),
                                ));
                              }
                              final subjects = snapshot.data ?? [];
                              if (subjects.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: subjects.length,
                                itemBuilder:
                                    (BuildContext context, int subjectIndex) {
                                  final subject = subjects[subjectIndex];
                                  return SubjectTile(
                                    onTap: () => navigateToSubjectPage(subject),
                                    subject: subject,
                                  );
                                },
                              );
                            },
                          ),
                          Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            clipBehavior: Clip.antiAlias,
                            elevation: 0,
                            color:
                                Theme.of(context).colorScheme.surfaceContainer,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant
                                    .withAlpha(51),
                                width: 1,
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => const SubjectDialog(),
                                );
                              },
                              child: SizedBox(
                                width: double.infinity,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withAlpha(26),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outlineVariant
                                                .withAlpha(51),
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.add_circle_outline,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Text(
                                        "Neues Fach erstellen",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Meine Lerninhalte",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const PersonalLibrary(),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 10.0, right: 10.0, bottom: 8.0, top: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ChatInputBar(
                      controller: _messageController,
                      hintText: 'Was möchtest du lernen?',
                      onSend: _startSessionFromMessage,
                      onAttachmentTap: _pickFiles,
                      pickedFiles: _pickedFiles,
                      onRemoveFile: (file) =>
                          setState(() => _pickedFiles.remove(file)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startSessionFromMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty && _pickedFiles.isEmpty) return;
    try {
      final sid = await _aiTechService.startSession(
          type: SessionType.study, concept: text);

      final passedFiles = List<PlatformFile>.from(_pickedFiles);
      _messageController.clear();
      setState(() {
        _pickedFiles = [];
      });

      if (!mounted) return;
      final navigator = Navigator.of(context);

      // Try to read the session doc via AiTechService to obtain an authoritative title.
      String? sessionTitle;
      try {
        sessionTitle = await _aiTechService.fetchSessionTitle(sid);
      } catch (_) {}

      navigator.push(MaterialPageRoute(
        builder: (_) => AiTechPage(
          sessionId: sid,
          initialUserMessage: text,
          initialPickedFiles: passedFiles,
          sessionTitle: sessionTitle,
        ),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Fehler beim Starten: $e')));
    }
  }

  @override
  void dispose() {
    subjectController.dispose();
    searchController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
