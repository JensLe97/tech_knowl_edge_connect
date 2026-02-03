import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/models/task.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech_service.dart';
import 'package:tech_knowl_edge_connect/services/content_admin_service.dart';
import 'package:tech_knowl_edge_connect/components/learning_material_type.dart';

class AiAuthoringCard extends StatefulWidget {
  final String userId;
  final ContentAdminService adminService;
  final AiTechService aiService;
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
    required this.aiService,
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

    try {
      final tasks = await widget.aiService.generateLearningBite(
        urls: urls,
        mimeTypes: mimeTypes,
        additionalText: _manualSourceText.trim(),
      );
      final summaryBuffer = StringBuffer();
      await for (final chunk in widget.aiService.summarizeMultipleData(
        urls: urls,
        mimeTypes: mimeTypes,
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
          'content': _aiContentParts,
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Learning Bite: ${widget.selectedLearningBiteData?['title'] ?? 'Nicht ausgewählt'}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: canUseAi ? _pickFiles : null,
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Dateien auswählen'),
                ),
                ElevatedButton.icon(
                  onPressed: canUseAi && _pickedFiles.isNotEmpty && !_uploading
                      ? _uploadFiles
                      : null,
                  icon: const Icon(Icons.cloud_upload),
                  label: _uploading
                      ? const Text('Upload läuft...')
                      : const Text('Upload starten'),
                ),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _manualSourceController,
                  builder: (context, value, _) {
                    final hasText = value.text.trim().isNotEmpty;
                    return ElevatedButton.icon(
                      onPressed:
                          canUseAi && (_uploadedResources.isNotEmpty || hasText)
                              ? _generateWithAi
                              : null,
                      icon: const Icon(Icons.auto_fix_high),
                      label: _generating
                          ? const Text('KI arbeitet...')
                          : const Text('KI-Inhalte erzeugen'),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Titel der hochgeladenen Datei (optional)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _uploadSource = value,
            ),
            const SizedBox(height: 12),
            TextField(
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Datei-Notizen/Metadaten (optional)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _uploadNotes = value,
            ),
            const SizedBox(height: 12),
            if (!canUseAi)
              const Text(
                  'Bitte wähle zuerst einen Learning Bite aus, um KI-Funktionen zu nutzen.'),
            if (_pickedFiles.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('Ausgewählte Dateien: ${_pickedFiles.length}'),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _pickedFiles = [];
                      });
                    },
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Alle entfernen'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: _pickedFiles
                    .map((file) => Chip(
                          label: Text(file.name),
                          onDeleted: () {
                            setState(() {
                              _pickedFiles.removeWhere((f) => f == file);
                            });
                          },
                        ))
                    .toList(),
              ),
            ],
            if (_uploadedResources.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('Uploads: ${_uploadedResources.length}'),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _uploadedResources = [];
                      });
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
                          data: {
                            'resources': [],
                          },
                        );
                        // Updating resources list in DB happens here immediately
                      }
                    },
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Alle entfernen'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: _uploadedResources
                    .map((res) => Chip(
                          label: Text(res['name'] ?? 'Datei'),
                          onDeleted: () async {
                            final newResources =
                                List<Map<String, dynamic>>.from(
                                    _uploadedResources);
                            newResources.removeWhere((r) => r == res);
                            setState(() {
                              _uploadedResources = newResources;
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
                                  'resources': newResources,
                                },
                              );
                              widget.onUpdate?.call();
                            }
                          },
                        ))
                    .toList(),
              ),
            ],
            const Divider(height: 24),
            TextField(
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Zusätzliche Textquelle (optional)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _manualSourceText = value,
              controller: _manualSourceController,
            ),
            const Divider(height: 24),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Titel (KI-Vorschlag)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _aiTitle = value,
              controller: _aiTitleController,
            ),
            const SizedBox(height: 12),
            if (_aiContentParts.isNotEmpty) ...[
              Text('Generierte Lernabschnitte: ${_aiContentParts.length}'),
              const SizedBox(height: 6),
              ..._aiContentParts.asMap().entries.map((entry) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Teil ${entry.key + 1}:\n${entry.value}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  )),
            ],
            const SizedBox(height: 12),
            if (_aiTasks.isNotEmpty) ...[
              Text('Generierte Aufgaben: ${_aiTasks.length}'),
              const SizedBox(height: 6),
              ..._aiTasks.map((task) => ListTile(
                    isThreeLine: true,
                    title: Text(task.question),
                    subtitle: Text(
                        '${task.type.name}\nAntwort: ${task.correctAnswer}'),
                  )),
            ],
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: canUseAi &&
                      (_aiContentParts.isNotEmpty || _aiTasks.isNotEmpty)
                  ? _applyAiToLearningBite
                  : null,
              icon: const Icon(Icons.save),
              label: const Text('KI-Inhalte speichern'),
            ),
            const SizedBox(height: 8),
            Text(
              'Hinweis: KI-Inhalte müssen vor Veröffentlichung geprüft werden.',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
          ],
        ),
      ),
    );
  }
}
