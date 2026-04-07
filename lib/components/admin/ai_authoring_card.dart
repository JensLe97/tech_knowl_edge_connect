import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_storage/firebase_storage.dart' hide Task;
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/models/learning/task.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/ai_tech_gen_service.dart';
import 'package:tech_knowl_edge_connect/services/content/content_admin_service.dart';
import 'package:tech_knowl_edge_connect/components/library/learning_material_type.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AiAuthoringCard extends StatefulWidget {
  final String userId;
  final ContentAdminService adminService;
  final AiTechGenService aiTechGenService;
  final String? selectedSubjectId;
  final String? selectedCategoryId;
  final String? selectedTopicId;
  final String? selectedUnitId;
  final String? selectedConceptId;
  final String? selectedLearningBiteId;
  final Map<String, dynamic>? selectedLearningBiteData;
  final VoidCallback? onUpdate;

  const AiAuthoringCard({
    super.key,
    required this.userId,
    required this.adminService,
    required this.aiTechGenService,
    required this.selectedSubjectId,
    required this.selectedCategoryId,
    required this.selectedTopicId,
    required this.selectedUnitId,
    required this.selectedConceptId,
    required this.selectedLearningBiteId,
    this.selectedLearningBiteData,
    this.onUpdate,
  });

  @override
  State<AiAuthoringCard> createState() => _AiAuthoringCardState();
}

class _AiAuthoringCardState extends State<AiAuthoringCard> {
  final TextEditingController _manualSourceController = TextEditingController();
  final TextEditingController _aiTitleController = TextEditingController();

  List<PlatformFile> _pickedFiles = [];
  List<Map<String, dynamic>> _uploadedResources = [];
  bool _uploading = false;
  String _uploadSource = '';
  String _uploadNotes = '';
  String _manualSourceText = '';

  bool _generating = false;
  List<String> _aiContentParts = [];
  List<Task> _aiTasks = [];
  String _aiTitle = '';

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void didUpdateWidget(AiAuthoringCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedLearningBiteId != oldWidget.selectedLearningBiteId) {
      _initData();
    }
  }

  void _initData() {
    if (widget.selectedLearningBiteData != null) {
      _aiTitle = widget.selectedLearningBiteData!['title'] ?? '';
      _aiTitleController.text = _aiTitle;
      _uploadedResources = List<Map<String, dynamic>>.from(
          widget.selectedLearningBiteData!['resources'] ?? []);
    } else {
      _aiTitle = '';
      _aiTitleController.text = '';
      _uploadedResources = [];
    }
    _pickedFiles = [];
    _uploadNotes = '';
    _uploadSource = '';
    _aiContentParts = [];
    _aiTasks = [];
    // Manual source text is intentionally NOT cleared to persist across selections if desired?
    // The original code didn't clear it in _generateWithAi but typically we might want to clear it on new selection.
    // I'll stick to clearing inputs on new selection for cleaner UX.
    _manualSourceText = '';
    _manualSourceController.text = '';
  }

  @override
  void dispose() {
    _manualSourceController.dispose();
    _aiTitleController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.custom,
      allowedExtensions: LearningMaterialType.supportedTypes,
    );
    if (result == null) return;
    setState(() {
      _pickedFiles = [..._pickedFiles, ...result.files];
    });
  }

  Future<void> _uploadFiles() async {
    setState(() => _uploading = true);
    try {
      final resources = await widget.adminService.uploadFiles(
        userId: widget.userId,
        files: _pickedFiles,
        metadata: {
          if (_uploadSource.trim().isNotEmpty) 'source': _uploadSource.trim(),
          if (_uploadNotes.trim().isNotEmpty) 'notes': _uploadNotes.trim(),
        },
      );
      final merged = [..._uploadedResources, ...resources];
      if (!mounted) return;
      setState(() {
        _uploadedResources = merged;
        _pickedFiles = [];
        _uploadNotes = '';
        _uploadSource = '';
      });
      if (widget.selectedSubjectId != null &&
          widget.selectedCategoryId != null &&
          widget.selectedTopicId != null &&
          widget.selectedUnitId != null &&
          widget.selectedConceptId != null &&
          widget.selectedLearningBiteId != null) {
        await widget.adminService.updateLearningBite(
          subjectId: widget.selectedSubjectId!,
          categoryId: widget.selectedCategoryId!,
          topicId: widget.selectedTopicId!,
          unitId: widget.selectedUnitId!,
          conceptId: widget.selectedConceptId!,
          learningBiteId: widget.selectedLearningBiteId!,
          data: {
            'resources': merged,
          },
        );
        widget.onUpdate?.call();
      }
    } finally {
      if (mounted) {
        setState(() => _uploading = false);
      }
    }
  }

  Future<void> _generateWithAi() async {
    final hasFiles = _uploadedResources.isNotEmpty;
    final hasText = _manualSourceText.trim().isNotEmpty;

    if (!hasFiles && !hasText) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Bitte Dateien hochladen oder Textquelle angeben.')),
      );
      return;
    }

    setState(() {
      _generating = true;
      _aiTasks = [];
      // Don't clear manual source text
    });

    // Sync title again just in case
    // _aiTitleController.text = _aiTitle; // Already synced

    final urls = _uploadedResources
        .map((res) => res['url'] as String)
        .where((url) => url.isNotEmpty)
        .toList();
    final mimeTypes = _uploadedResources
        .map((res) => res['mimeType'] as String)
        .where((type) => type.isNotEmpty)
        .toList();

    // Download uploaded files and convert to inline parts.
    final List<Part> fileParts = [];
    for (int i = 0; i < urls.length; i++) {
      try {
        final data =
            await FirebaseStorage.instance.refFromURL(urls[i]).getData();
        if (data != null) fileParts.add(InlineDataPart(mimeTypes[i], data));
      } catch (_) {}
    }

    try {
      final tasks = await widget.aiTechGenService.generateLearningBiteTasks(
        fileParts: fileParts,
        additionalText: _manualSourceText.trim(),
      );
      final summaryBuffer = StringBuffer();
      await for (final chunk in widget.aiTechGenService.summarizeMultipleData(
        fileParts: fileParts,
        additionalText: _manualSourceText.trim(),
        splitIntoParts: true,
      )) {
        if (chunk.text != null) {
          summaryBuffer.write(chunk.text);
        }
      }

      String rawJson = summaryBuffer.toString();
      rawJson = rawJson
          .replaceAll(RegExp(r'^```json\s*'), '')
          .replaceAll(RegExp(r'\s*```$'), '')
          .trim();

      List<String> parts = [];
      try {
        final decoded = jsonDecode(rawJson);
        if (decoded is Map && decoded.containsKey('parts')) {
          parts = List<String>.from(decoded['parts']);
        }
      } catch (e) {
        parts = [rawJson]; // Fallback
        if (!mounted) return;
      }

      if (mounted) {
        setState(() {
          _aiTasks = tasks;
          _aiContentParts = parts;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler bei der KI-Generierung: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _generating = false);
      }
    }
  }

  Future<void> _applyAiToLearningBite() async {
    if (widget.selectedSubjectId == null ||
        widget.selectedCategoryId == null ||
        widget.selectedTopicId == null ||
        widget.selectedUnitId == null ||
        widget.selectedConceptId == null ||
        widget.selectedLearningBiteId == null) {
      return;
    }

    try {
      await widget.adminService.updateLearningBite(
        subjectId: widget.selectedSubjectId!,
        categoryId: widget.selectedCategoryId!,
        topicId: widget.selectedTopicId!,
        unitId: widget.selectedUnitId!,
        conceptId: widget.selectedConceptId!,
        learningBiteId: widget.selectedLearningBiteId!,
        data: {
          'content': FieldValue.arrayUnion(_aiContentParts),
        },
      );

      // Add tasks
      for (final t in _aiTasks) {
        await widget.adminService.createTask(
          subjectId: widget.selectedSubjectId!,
          categoryId: widget.selectedCategoryId!,
          topicId: widget.selectedTopicId!,
          unitId: widget.selectedUnitId!,
          conceptId: widget.selectedConceptId!,
          learningBiteId: widget.selectedLearningBiteId!,
          type: t.type.name,
          question: t.question,
          correctAnswer: t.correctAnswer,
          answers: t.answers,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('KI-Inhalte erfolgreich gespeichert!')),
        );
        setState(() {
          _aiContentParts = [];
          _aiTasks = [];
        });
      }
      widget.onUpdate?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Speichern: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canUseAi = widget.selectedLearningBiteId != null;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // File selection & upload
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: canUseAi ? _pickFiles : null,
                icon: const Icon(Icons.attach_file),
                label: const Text('Dateien auswählen'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primaryContainer,
                  foregroundColor: cs.onPrimaryContainer,
                  side: BorderSide(color: cs.outlineVariant.withAlpha(76)),
                ),
                onPressed: canUseAi && _pickedFiles.isNotEmpty && !_uploading
                    ? _uploadFiles
                    : null,
                icon: const Icon(Icons.cloud_upload),
                label: _uploading
                    ? const Text('Upload läuft...')
                    : const Text('Upload starten'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // AI Generation Trigger
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _manualSourceController,
          builder: (context, value, _) {
            final hasText = value.text.trim().isNotEmpty;
            final canTrigger =
                canUseAi && (_uploadedResources.isNotEmpty || hasText);

            return Container(
              decoration: BoxDecoration(
                color: canTrigger
                    ? cs.surfaceContainer
                    : cs.surfaceContainerHighest.withAlpha(128),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: canTrigger
                        ? cs.primary.withAlpha(51)
                        : cs.outlineVariant.withAlpha(128)),
              ),
              padding: const EdgeInsets.all(4),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: canTrigger ? _generateWithAi : null,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: canTrigger
                                ? cs.primary
                                : cs.onSurface.withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: canTrigger
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(25),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Icon(Icons.auto_awesome,
                              color: canTrigger
                                  ? cs.onPrimary
                                  : cs.onSurface.withAlpha(100),
                              size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _generating
                              ? 'KI arbeitet...'
                              : 'KI-Inhalte erzeugen',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: canTrigger
                                ? cs.primary
                                : cs.onSurface.withAlpha(100),
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.chevron_right,
                          color: canTrigger
                              ? cs.outline
                              : cs.outlineVariant.withAlpha(100),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        // Selected files overview
        if (!canUseAi)
          const Text(
              'Bitte wähle zuerst einen Learning Bite aus, um KI-Funktionen zu nutzen.'),
        if (_pickedFiles.isNotEmpty) ...[
          Row(
            children: [
              Text('Ausgewählte Dateien: ${_pickedFiles.length}'),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() => _pickedFiles = []),
                child: const Text('Alle entfernen'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _pickedFiles
                .map((file) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainer,
                        borderRadius: BorderRadius.circular(24),
                        border:
                            Border.all(color: cs.outlineVariant.withAlpha(40)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: cs.primary.withAlpha(26),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: cs.outlineVariant.withAlpha(51)),
                            ),
                            child: Center(
                              child: Icon(Icons.insert_drive_file,
                                  color: cs.primary, size: 24),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              file.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline,
                                color: cs.onSurfaceVariant),
                            tooltip: 'Entfernen',
                            style: IconButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => setState(() {
                              _pickedFiles.removeWhere((f) => f == file);
                            }),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
        ],
        if (_uploadedResources.isNotEmpty) ...[
          Row(
            children: [
              Text('Uploads: ${_uploadedResources.length}'),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() => _uploadedResources = []);
                  if (widget.selectedSubjectId != null &&
                      widget.selectedCategoryId != null &&
                      widget.selectedTopicId != null &&
                      widget.selectedUnitId != null &&
                      widget.selectedConceptId != null &&
                      widget.selectedLearningBiteId != null) {
                    widget.adminService.updateLearningBite(
                      subjectId: widget.selectedSubjectId!,
                      categoryId: widget.selectedCategoryId!,
                      topicId: widget.selectedTopicId!,
                      unitId: widget.selectedUnitId!,
                      conceptId: widget.selectedConceptId!,
                      learningBiteId: widget.selectedLearningBiteId!,
                      data: {'resources': []},
                    );
                  }
                },
                child: const Text('Alle entfernen'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _uploadedResources
                .map((res) => Chip(
                      label: Text(res['name'] ?? 'Datei'),
                      onDeleted: () async {
                        final newResources =
                            List<Map<String, dynamic>>.from(_uploadedResources);
                        newResources.removeWhere((r) => r == res);
                        setState(() => _uploadedResources = newResources);
                        if (widget.selectedSubjectId != null &&
                            widget.selectedCategoryId != null &&
                            widget.selectedTopicId != null &&
                            widget.selectedUnitId != null &&
                            widget.selectedConceptId != null &&
                            widget.selectedLearningBiteId != null) {
                          await widget.adminService.updateLearningBite(
                            subjectId: widget.selectedSubjectId!,
                            categoryId: widget.selectedCategoryId!,
                            topicId: widget.selectedTopicId!,
                            unitId: widget.selectedUnitId!,
                            conceptId: widget.selectedConceptId!,
                            learningBiteId: widget.selectedLearningBiteId!,
                            data: {'resources': newResources},
                          );
                          widget.onUpdate?.call();
                        }
                      },
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
        ],
        // Inputs
        TextField(
          decoration: const InputDecoration(
            labelText: 'Titel der hochgeladenen Datei (optional)',
          ),
          onChanged: (value) => _uploadSource = value,
        ),
        const SizedBox(height: 16),
        TextField(
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Datei-Notizen/Metadaten (optional)',
          ),
          onChanged: (value) => _uploadNotes = value,
        ),
        const SizedBox(height: 16),
        TextField(
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Zusätzliche Textquelle (optional)',
          ),
          onChanged: (value) => _manualSourceText = value,
          controller: _manualSourceController,
        ),
        const SizedBox(height: 24),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'KI-Vorschlag',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Titel',
              ),
              style: const TextStyle(fontWeight: FontWeight.bold),
              onChanged: (value) => _aiTitle = value,
              controller: _aiTitleController,
            ),
            if (_aiContentParts.isNotEmpty || _aiTasks.isNotEmpty) ...[
              const SizedBox(height: 16),
              if (_aiContentParts.isNotEmpty) ...[
                Text('Generierte Lernabschnitte: ${_aiContentParts.length}',
                    style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ..._aiContentParts.asMap().entries.map((entry) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainer,
                        borderRadius: BorderRadius.circular(24),
                        border:
                            Border.all(color: cs.outlineVariant.withAlpha(40)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: cs.primary.withAlpha(26),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: cs.outlineVariant.withAlpha(51),
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.description,
                                color: cs.primary,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Teil ${entry.key + 1}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  entry.value,
                                  style: TextStyle(
                                      fontSize: 14, color: cs.onSurface),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
              if (_aiTasks.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('Generierte Aufgaben: ${_aiTasks.length}',
                    style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ..._aiTasks.map((task) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainer,
                        borderRadius: BorderRadius.circular(24),
                        border:
                            Border.all(color: cs.outlineVariant.withAlpha(40)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: cs.primary.withAlpha(26),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: cs.outlineVariant.withAlpha(51),
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.quiz,
                                color: cs.primary,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.question,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${task.type.name}\nAntwort: ${task.correctAnswer}',
                                  style: TextStyle(
                                      fontSize: 13, color: cs.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: canUseAi ? _applyAiToLearningBite : null,
                  icon: const Icon(Icons.save),
                  label: const Text('KI-Inhalte speichern'),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hinweis: KI-Inhalte müssen vor Veröffentlichung geprüft werden.',
                style: TextStyle(color: cs.onSecondaryContainer, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ],
    );
  }
}
