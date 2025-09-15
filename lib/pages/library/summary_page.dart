import 'package:flutter/material.dart';
import 'package:tech_knowl_edge_connect/services/summary_service.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class SummaryPage extends StatelessWidget {
  final String name;
  final List<String> urls;
  final List<String> mimeTypes;
  final SummaryService _summaryService;

  const SummaryPage({
    super.key,
    required this.name,
    required this.urls,
    required this.mimeTypes,
    required SummaryService summaryService,
  }) : _summaryService = summaryService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Tech Zusammenfassung'),
      ),
      body: StreamBuilder<GenerateContentResponse>(
        stream: _summaryService.summarizeMultipleData(
          urls: urls,
          mimeTypes: mimeTypes,
        ),
        builder: (context, snapshot) {
          // Accumulate all streamed text parts
          // Use a ValueNotifier to store the full summary
          return _SummaryStreamAccumulator(snapshot: snapshot);
        },
      ),
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
          ),
        ),
      );
    }
  }
}
