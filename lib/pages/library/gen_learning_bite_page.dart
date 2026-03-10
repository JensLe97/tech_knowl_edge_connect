import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/models/learning/learning_bite.dart';
import 'package:tech_knowl_edge_connect/models/learning/task.dart';
import 'package:tech_knowl_edge_connect/pages/search/learning_bite_page.dart';
import 'package:tech_knowl_edge_connect/services/ai_tech/ai_tech_gen_service.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tech_knowl_edge_connect/components/library/markdown_support.dart';

class GenLearningBitePage extends StatelessWidget {
  final String name;
  final List<Part> fileParts;
  final AiTechGenService _aiTechGenService;

  const GenLearningBitePage({
    super.key,
    required this.name,
    this.fileParts = const [],
    required AiTechGenService aiTechGenService,
  }) : _aiTechGenService = aiTechGenService;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Task>>(
      future: _aiTechGenService.generateLearningBiteTasks(
        fileParts: fileParts,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text(name),
              centerTitle: true,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text(name),
              centerTitle: true,
            ),
            body: Center(
              child: Text(
                'Fehler bei der Generierung des Learning Bites: ${snapshot.error}',
              ),
            ),
          );
        } else if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text(name),
              centerTitle: true,
            ),
            body: const Center(child: Text('Kein Learning Bite verfügbar.')),
          );
        } else {
          final tasks = snapshot.data!;
          final learningBite = LearningBite(
            id: FirebaseFirestore.instance
                .collection('learning_bites')
                .doc()
                .id,
            name: name,
            type: 'lesson',
            iconData: Icons.checklist,
            content: [
              'Das Learning Bite "$name" wurde automatisch generiert. Es enthält ${tasks.length} Aufgaben, die dir helfen sollen, das Thema besser zu verstehen.',
            ],
          );
          return LearningBitePage(learningBite: learningBite, tasks: tasks);
        }
      },
    );
  }
}

class _SummaryStreamAccumulator extends StatefulWidget {
  final AsyncSnapshot<GenerateContentResponse> snapshot;
  const _SummaryStreamAccumulator({required this.snapshot});

  @override
  State<_SummaryStreamAccumulator> createState() =>
      _SummaryStreamAccumulatorState();
}

class _SummaryStreamAccumulatorState extends State<_SummaryStreamAccumulator> {
  final StringBuffer _buffer = StringBuffer();
  GenerateContentResponse? _lastResponse;

  @override
  void didUpdateWidget(covariant _SummaryStreamAccumulator oldWidget) {
    super.didUpdateWidget(oldWidget);
    final response = widget.snapshot.data;
    if (response != null && response != _lastResponse) {
      if (response.text != null) {
        _buffer.write(response.text);
      }
      _lastResponse = response;
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = widget.snapshot;
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      return Center(
        child: Text(
          'Fehler bei der Generierung der Zusammenfassung: ${snapshot.error}',
        ),
      );
    } else if (!snapshot.hasData && _buffer.isEmpty) {
      return const Center(child: Text('Keine Zusammenfassung verfügbar.'));
    } else {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: MarkdownBody(
            data: _buffer.isEmpty
                ? 'Keine Antwort erhalten.'
                : _buffer.toString(),
            styleSheet: createMarkdownStyleSheet(context),
            extensionSet: getMarkdownExtensionSet(),
            builders: getMarkdownColorBuilders(),
          ),
        ),
      );
    }
  }
}
